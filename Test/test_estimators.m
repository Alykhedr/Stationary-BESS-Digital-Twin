% TEST_ESTIMATORS  Self-test suite for the BMS sensor + estimation functions.
% Run standalone: results printed, asserts fire on regression.
% Each section unit-tests one function.

clear; clc;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'BMS'));
cfg = bms_config();
T = load(fullfile(root, 'Data', 'ocv_table.mat'));
oS = T.ocv.SOC_grid; oV = T.ocv.V_grid; hS = T.hys.SOC_grid; hV = T.hys.V_grid;
fprintf('=== test_estimators ===\n');

%% ---------------------------------------------------------------------
%% Section 1: bms_sensor_model
%% ---------------------------------------------------------------------
st.bias = 1.5e-3; st.gain_err = 0; st.noise_sig = cfg.sens.V_noise_sigma;
st.quant = cfg.sens.V_quant; st.lag_tau_h = 0; st.y_lag = 0; st.noise_seed = 12345;

% 1.1 zero-error passthrough
st0 = st; st0.bias = 0; st0.noise_sig = 0; st0.quant = 0;
[y, ~] = bms_sensor_model(3.3, st0, 1);
assert(abs(y - 3.3) < 1e-12, '1.1 passthrough failed');

% 1.2 bias + noise statistics (10k samples)
N = 1e4; e = zeros(N,1); s = st;
for k = 1:N, [y, s] = bms_sensor_model(3.3, s, 1); e(k) = y - 3.3; end
assert(abs(mean(e) - st.bias) < 0.1e-3, '1.2 mean error off');
assert(abs(std(e) - st.noise_sig) < 0.05e-3, '1.2 noise sigma off');

% 1.3 quantization grid
g = mod(e + 3.3, st.quant);
assert(all(g < 1e-9 | abs(g - st.quant) < 1e-9), '1.3 quantization failed');

% 1.4 first-order lag step response (high-rate context, 1 s steps)
stT = struct('bias',0,'gain_err',0,'noise_sig',0,'quant',0, ...
             'lag_tau_h',30/3600,'y_lag',0,'noise_seed',1);
dt = 1/3600; sT = stT; yv = zeros(120,1);
for k = 1:120, [yv(k), sT] = bms_sensor_model(1.0, sT, dt); end
assert(abs(yv(30) - (1 - exp(-1))) < 0.01, '1.4 lag tau wrong');

% 1.5 reproducibility from identical seed
[a1, ~] = bms_sensor_model(3.3, st, 1);
[a2, ~] = bms_sensor_model(3.3, st, 1);
assert(a1 == a2, '1.5 not reproducible');
fprintf('Section 1 (bms_sensor_model): all PASS\n');

%% ---------------------------------------------------------------------
%% Section 2: bms_ocv_inverse
%% ---------------------------------------------------------------------
% 2.1 steep-zone round-trip + valid flag
for soc = [0.02 0.05 0.08 0.92 0.95 0.99]
    V = interp1(oS, oV, soc);
    [sres, v] = bms_ocv_inverse(V, 0, soc, oS, oV, hS, hV, cfg);
    assert(v && abs(sres - soc) < 1e-9, '2.1 round-trip failed at %.2f', soc);
end

% 2.2 plateau NEVER validates
for V = 3.225:0.001:3.335
    [~, v] = bms_ocv_inverse(V, 0, 0.5, oS, oV, hS, hV, cfg);
    assert(~v, '2.2 snap fired on plateau at V=%.3f', V);
end

% 2.3 hysteresis compensation (post-charge rest sits ABOVE OCV)
soc_t = 0.95;
V_ch  = interp1(oS,oV,soc_t) + interp1(hS,hV,soc_t);
V_dis = interp1(oS,oV,soc_t) - interp1(hS,hV,soc_t);
[s_ch, ~]  = bms_ocv_inverse(V_ch,  +1, soc_t, oS, oV, hS, hV, cfg);
[s_dis, ~] = bms_ocv_inverse(V_dis, -1, soc_t, oS, oV, hS, hV, cfg);
assert(abs(s_ch - soc_t) < 1e-6 && abs(s_dis - soc_t) < 1e-6, '2.3 hysteresis comp failed');

% 2.4 2 mV sensor error stays < 1 % SOC error in steep zones
[s_lo, ~] = bms_ocv_inverse(interp1(oS,oV,0.05)+2e-3, 0, 0.05, oS, oV, hS, hV, cfg);
[s_hi, ~] = bms_ocv_inverse(interp1(oS,oV,0.95)+2e-3, 0, 0.95, oS, oV, hS, hV, cfg);
assert(abs(s_lo-0.05) < 0.01 && abs(s_hi-0.95) < 0.01, '2.4 steep-zone error too large');

% 2.5 out-of-range clamps, never NaN
[s_a, ~] = bms_ocv_inverse(1.5, 0, 0.5, oS, oV, hS, hV, cfg);
[s_b, ~] = bms_ocv_inverse(4.0, 0, 0.5, oS, oV, hS, hV, cfg);
assert(s_a == 0 && s_b == 1 && ~any(isnan([s_a s_b])), '2.5 clamping failed');
fprintf('Section 2 (bms_ocv_inverse): all PASS\n');

%% ---------------------------------------------------------------------
%% Section 3: bms_soc_estimator
%% ---------------------------------------------------------------------
dt = 1;  % longevity-twin tick [h]
Q_true = 3.0;

% Synthetic 200 h profile: discharge to ~5 %, rest 8 h, charge to ~95 %, rest 8 h, repeat
I_prof = [];
I_prof = [I_prof, -0.45*ones(1,6)];   % 90% -> 5% area approx; start SOC 0.95
I_prof = [I_prof, zeros(1,8)];
I_prof = [I_prof, +0.45*ones(1,6)];
I_prof = [I_prof, zeros(1,8)];
I_prof = repmat(I_prof, 1, 7);        % 196 h
SOC0 = 0.95;

% True SOC (perfect coulomb integration, no self-discharge for simplicity)
SOC_true = SOC0 + cumsum(I_prof) * dt / Q_true;
SOC_true = min(max(SOC_true, 0), 1);
% Rest voltages from OCV + hysteresis memory of last current direction
V_prof = zeros(size(I_prof)); lastsgn = 0;
for k = 1:numel(I_prof)
    if abs(I_prof(k)) >= cfg.est.rest_current_thr, lastsgn = sign(I_prof(k)); end
    V_prof(k) = interp1(oS, oV, SOC_true(k)) + lastsgn * interp1(hS, hV, SOC_true(k));
end

% 3.1 bias-free coulomb counting == manual integration (corrector disabled
%     by feeding plateau voltage so snaps can't fire; s_rate included)
es = struct('SOC', SOC0, 't_rest_h', 0, 'I_last_sign', 0);
soc_manual = SOC0; ok31 = true;
for k = 1:numel(I_prof)
    [se, ~, es] = bms_soc_estimator(I_prof(k), 3.28, es, Q_true, oS, oV, hS, hV, cfg, dt);
    soc_manual = min(max(soc_manual + I_prof(k)*dt/Q_true - cfg.est.s_rate_nom_per_h*dt, 0), 1);
    ok31 = ok31 && abs(se - soc_manual) < 1e-12;
end
assert(ok31, '3.1 bias-free CC drifted from manual integration');

% 3.2 with +10 mA bias: drift between anchors < 5 %, snap recovers < 1 %
b_I = 10e-3;
es = struct('SOC', SOC0, 't_rest_h', 0, 'I_last_sign', 0);
err = zeros(size(I_prof)); corr_count = 0;
for k = 1:numel(I_prof)
    [se, c, es] = bms_soc_estimator(I_prof(k) + b_I, V_prof(k), es, Q_true, oS, oV, hS, hV, cfg, dt);
    err(k) = se - SOC_true(k);
    if c
        corr_count = corr_count + 1;
        % lambda ramps 0->1 between t_min and 2*t_min rest; full-reset
        % accuracy is only guaranteed once lambda = 1
        if es.t_rest_h >= 2 * cfg.est.rest_time_min
            assert(abs(err(k)) < 0.01, '3.2 full-lambda post-snap error >= 1%% (%.3f)', err(k));
        end
    end
end
assert(corr_count > 0, '3.2 no snaps fired on profile with steep-zone rests');
assert(max(abs(err)) < 0.05, '3.2 drift exceeded 5%% between anchors (max %.3f)', max(abs(err)));

% 3.3 snap NEVER fires when rests happen on the plateau
es = struct('SOC', 0.5, 't_rest_h', 0, 'I_last_sign', 0);
for k = 1:50   % 50 h of rest at SOC 50 %
    [~, c, es] = bms_soc_estimator(0, interp1(oS,oV,0.5), es, Q_true, oS, oV, hS, hV, cfg, dt);
    assert(~c, '3.3 snap fired on plateau');
end
fprintf('Section 3 (bms_soc_estimator): all PASS (%d snaps on cycling profile)\n', corr_count);

%% ---------------------------------------------------------------------
%% Section 4: bms_soh_estimator
%% ---------------------------------------------------------------------
% Direct anchor-pair arithmetic: true capacity 2.7 Ah, anchors at 5 % / 95 %
ss = struct('Q_est', 3.0, 'Ah_acc', 0, 'anchor_soc', 0, 'has_anchor', 0);
% anchor 1 at SOC=0.05
[~, ~, ss] = bms_soh_estimator(0.05, true, 0, ss, cfg, dt);
% charge 0.9 SOC-span on a 2.7 Ah cell = 2.43 Ah over 9 ticks
for k = 1:9, [~, ~, ss] = bms_soh_estimator(0.5, false, 0.27, ss, cfg, dt); end
% anchor 2 at SOC=0.95 -> Q_new = 2.43/0.9 = 2.7; Q_est <- 0.9*3.0+0.1*2.7 = 2.97
[SOH_e, Q_e, ss] = bms_soh_estimator(0.95, true, 0, ss, cfg, dt);
assert(abs(Q_e - 2.97) < 1e-9, '4.1 anchor-pair Q update wrong (got %.4f)', Q_e);
assert(abs(SOH_e - 0.99) < 1e-9, '4.1 SOH wrong');

% 4.2 narrow span (< 0.5) must NOT update Q
ss2 = struct('Q_est', 3.0, 'Ah_acc', 0, 'anchor_soc', 0, 'has_anchor', 0);
[~, ~, ss2] = bms_soh_estimator(0.05, true, 0, ss2, cfg, dt);
for k = 1:3, [~, ~, ss2] = bms_soh_estimator(0.1, false, 0.1, ss2, cfg, dt); end
[~, Q_e2, ~] = bms_soh_estimator(0.15, true, 0, ss2, cfg, dt);
assert(Q_e2 == 3.0, '4.2 Q updated on narrow span');

% 4.3 implausible anchor (Q_new outside 0.5..1.5x nominal) rejected
ss3 = struct('Q_est', 3.0, 'Ah_acc', 0, 'anchor_soc', 0, 'has_anchor', 0);
[~, ~, ss3] = bms_soh_estimator(0.05, true, 0, ss3, cfg, dt);
for k = 1:9, [~, ~, ss3] = bms_soh_estimator(0.5, false, 1.0, ss3, cfg, dt); end  % 9 Ah!
[~, Q_e3, ~] = bms_soh_estimator(0.95, true, 0, ss3, cfg, dt);
assert(Q_e3 == 3.0, '4.3 implausible Q accepted');
fprintf('Section 4 (bms_soh_estimator): all PASS\n');

%% ---------------------------------------------------------------------
%% Section 5: bms_r_estimator
%% ---------------------------------------------------------------------
% Known plant: V = 3.28 + I*R with R_true = 60 mOhm (charge direction)
R_true = 0.060;
rs = struct('V_prev', 3.28, 'I_prev', 0, 'R_ch', cfg.rest.R_nominal_ch, 'R_dis', cfg.rest.R_nominal_dis);
% 5.1 initialized values come out before any step
[Rc0, Rd0, rs] = bms_r_estimator(3.28, 0, rs, cfg);
assert(Rc0 == cfg.rest.R_nominal_ch && Rd0 == cfg.rest.R_nominal_dis, '5.1 init values wrong');
% 5.2 repeated 0 -> 1.5 A steps converge toward R_true
for k = 1:60
    [Rc, ~, rs] = bms_r_estimator(3.28 + 1.5*R_true, 1.5, rs, cfg);   % step up
    [Rc, ~, rs] = bms_r_estimator(3.28, 0, rs, cfg);                  % step down (dI=-1.5, but I_meas=0 -> charge bin boundary)
end
assert(abs(rs.R_ch - R_true) < 0.002, '5.2 R_ch did not converge (got %.4f)', rs.R_ch);
% 5.3 small steps (< dI_min) never update
rs3 = struct('V_prev', 3.28, 'I_prev', 0, 'R_ch', cfg.rest.R_nominal_ch, 'R_dis', cfg.rest.R_nominal_dis);
[~, ~, rs3] = bms_r_estimator(3.30, 0.3, rs3, cfg);
assert(rs3.R_ch == cfg.rest.R_nominal_ch, '5.3 updated on sub-threshold step');
fprintf('Section 5 (bms_r_estimator): all PASS\n');

%% ---------------------------------------------------------------------
%% Section 6: bms_limits
%% ---------------------------------------------------------------------
Rn_ch = cfg.rest.R_nominal_ch; Rn_dis = cfg.rest.R_nominal_dis;
% 6.1 T = -5 degC: charge forbidden
[Ic, ~, ~] = bms_limits(3.30, 3.30, -5, -5, 0.5, 3.0, Rn_ch, Rn_dis, cfg, dt);
assert(Ic == 0, '6.1 charge allowed below 0 degC');
% 6.2 T = 42 degC: derated but nonzero, and continuous in T
Iprev = -inf; okc = true;
for Tq = 38:0.25:46
    [Ic, ~, ~] = bms_limits(3.30, 3.30, Tq, Tq, 0.5, 3.0, Rn_ch, Rn_dis, cfg, dt);
    okc = okc && (Iprev == -inf || abs(Ic - Iprev) < 0.2);  % no jumps
    Iprev = Ic;
end
[Ic42, ~, d42] = bms_limits(3.30, 3.30, 42, 42, 0.5, 3.0, Rn_ch, Rn_dis, cfg, dt);
assert(Ic42 > 0 && Ic42 < cfg.cell.I_chg_max_cont && d42, '6.2 derate at 42 degC wrong');
assert(okc, '6.2 derate not continuous');
% 6.3 SOC window taper: SOC_est = 0.94 -> charge tapers, 0 at 0.95
[Ic94, ~, ~] = bms_limits(3.30, 3.30, 25, 25, 0.94, 3.0, Rn_ch, Rn_dis, cfg, dt);
[Ic95, ~, ~] = bms_limits(3.30, 3.30, 25, 25, 0.95, 3.0, Rn_ch, Rn_dis, cfg, dt);
assert(Ic94 > 0 && Ic94 < cfg.cell.I_chg_max_cont && Ic95 == 0, '6.3 SOC taper wrong');
% 6.4 voltage headroom uses V_max_warn: at V_meas = 3.55 charge limit = 0
[IcV, ~, ~] = bms_limits(3.55, 3.55, 25, 25, 0.5, 3.0, Rn_ch, Rn_dis, cfg, dt);
assert(IcV == 0, '6.4 headroom not zero at V_max_warn');
% 6.5 discharge symmetric: V_min_warn floor
[~, IdV, ~] = bms_limits(2.50, 2.50, 25, 25, 0.5, 3.0, Rn_ch, Rn_dis, cfg, dt);
assert(IdV == 0, '6.5 discharge headroom not zero at V_min_warn');
fprintf('Section 6 (bms_limits, draft): all PASS\n');

fprintf('=== test_estimators: ALL SECTIONS PASS ===\n');
