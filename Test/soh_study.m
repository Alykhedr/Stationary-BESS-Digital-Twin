% SOH_STUDY  Does the BMS SOH estimator actually track real capacity fade?
%
% Runs the offline BMS chain (sensors -> R -> SOC -> SOH) against the
% multi-year plant fixture and compares belief vs truth:
%   - SOC_est vs SOC_true   (does staleness of Q_est rot SOC over life?)
%   - Q_est   vs Q_actual   (does SOH estimation track the fade?)
%   - counts OCV snaps (SOC corrections) and capacity updates (anchor pairs)
%
% Truth signals are used for COMPARISON ONLY, never fed into a BMS function.

clear; clc;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'BMS'));
addpath(fullfile(root, 'Data'));

cfg = bms_config();
T  = load(fullfile(root, 'Data', 'ocv_table.mat'));
oS = T.ocv.SOC_grid; oV = T.ocv.V_grid; hS = T.hys.SOC_grid; hV = T.hys.V_grid;

F = load(fullfile(root, 'Data', 'fixture_long.mat')); fx = F.fixture;
n = numel(fx.t_h); dt = 1;   % 1-hour ticks
fprintf('Fixture: %d samples (%.1f years)\n', n, fx.t_h(end)/8760);

% --- init (frozen biases from seed file; seed SOC from OCV at t0) ---
states = bms_init(cfg, fx.V_true(1), oS, oV, hS, hV, false);
Q_est_prev = states.soh.Q_est;

% --- logs ---
SOC_est = zeros(n,1); Q_est = zeros(n,1); SOH_est = zeros(n,1);
V_meas_log = zeros(n,1); I_meas_log = zeros(n,1);
snap = false(n,1); capupd = false(n,1);

for k = 1:n
    [Vm, states.sens_V] = bms_sensor_model(fx.V_true(k), states.sens_V, dt);
    [Im, states.sens_I] = bms_sensor_model(fx.I_true(k), states.sens_I, dt);
    [Tm, states.sens_T] = bms_sensor_model(fx.T_true(k), states.sens_T, dt); %#ok<NASGU>

    [~, ~, states.r] = bms_r_estimator(Vm, Im, states.r, cfg);

    [soc, corrected, states.est] = bms_soc_estimator(Im, Vm, states.est, ...
                                        Q_est_prev, oS, oV, hS, hV, cfg, dt);
    Qprev = states.soh.Q_est;
    [soh, Q, states.soh] = bms_soh_estimator(soc, corrected, Im, states.soh, cfg, dt);

    SOC_est(k) = soc; Q_est(k) = Q; SOH_est(k) = soh;
    V_meas_log(k) = Vm; I_meas_log(k) = Im;
    snap(k)   = corrected;
    capupd(k) = abs(Q - Qprev) > 1e-9;   % a valid anchor-pair update happened
    Q_est_prev = Q;
end

% =====================================================================
% Analysis
% =====================================================================
soc_err = SOC_est - fx.SOC_true;
soh_err = SOH_est - fx.SOH_true;
q_err   = Q_est   - fx.Q_actual;

fprintf('\n========== SOH STUDY RESULTS ==========\n');
fprintf('OCV snaps (SOC corrections) : %d  (%.1f per year)\n', ...
        sum(snap), sum(snap)/(fx.t_h(end)/8760));
fprintf('Capacity updates (anchor pairs >=50%% span, plausible) : %d  (%.1f per year)\n', ...
        sum(capupd), sum(capupd)/(fx.t_h(end)/8760));

fprintf('\n-- True vs estimated capacity at end of life --\n');
fprintf('  Q_actual(end) = %.4f Ah   (faded %.2f%%)\n', fx.Q_actual(end), (1-fx.SOH_true(end))*100);
fprintf('  Q_est(end)    = %.4f Ah   (believes faded %.2f%%)\n', Q_est(end), (1-SOH_est(end))*100);
fprintf('  Q_est error   = %+.4f Ah  (%+.2f%% of nominal)\n', q_err(end), q_err(end)/cfg.cell.Q_nom*100);

fprintf('\n-- Per-year summary --\n');
fprintf('  yr | SOH_true SOH_est  Qerr[Ah] | SOCerr mean/max | snaps capupd\n');
for yr = 1:floor(fx.t_h(end)/8760)
    idx = fx.t_h >= (yr-1)*8760 & fx.t_h < yr*8760;
    fprintf('  %2d |  %.4f  %.4f  %+.4f  |  %.3f / %.3f  |  %4d   %3d\n', ...
        yr, mean(fx.SOH_true(idx)), mean(SOH_est(idx)), mean(q_err(idx)), ...
        mean(abs(soc_err(idx))), max(abs(soc_err(idx))), ...
        sum(snap(idx)), sum(capupd(idx)));
end

fprintf('\n-- Overall --\n');
fprintf('  SOC_est error: mean |e| = %.3f, max |e| = %.3f\n', mean(abs(soc_err)), max(abs(soc_err)));
fprintf('  SOH_est error: mean |e| = %.4f, final = %+.4f\n', mean(abs(soh_err)), soh_err(end));

% =====================================================================
% Plot
% =====================================================================
yr = fx.t_h/8760;
fig = figure('Visible','off','Position',[100 100 900 700]);

subplot(3,1,1);
plot(yr, fx.Q_actual, 'k-', 'LineWidth', 1.5); hold on;
plot(yr, Q_est, 'r-', 'LineWidth', 1);
ylabel('Capacity [Ah]'); legend('Q\_actual (truth)','Q\_est (BMS belief)','Location','best');
title('SOH estimation vs true capacity fade'); grid on;

subplot(3,1,2);
plot(yr, soc_err*100, 'b-'); hold on;
ylabel('SOC\_est - SOC\_true [%]'); title('SOC estimation error over life'); grid on;

subplot(3,1,3);
plot(yr, q_err, 'm-'); hold on;
yline(0,'k:'); ylabel('Q\_est - Q\_actual [Ah]'); xlabel('Years');
title('Capacity estimation error'); grid on;

exportgraphics(fig, fullfile(root, 'Test', 'soh_study.png'), 'Resolution', 120);
fprintf('\nPlot saved: Test/soh_study.png\n');
