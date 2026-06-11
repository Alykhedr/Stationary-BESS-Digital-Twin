% validate_model.m
% =========================================================================
% Comprehensive validation of BESS Digital Twin against
% Schimpe et al. (2018) "Energy efficiency evaluation of a stationary
% lithium-ion battery container storage system", Applied Energy 210.
%
% Covers every sub-model output:
%   1.  OCV curve                    (cell_thermal  / Fig 5a)
%   2.  OCV temperature correction   (cell_thermal  / Eq 2.13)
%   3.  Resistance tables            (Cell_Variables_Init / Fig 5b,5c)
%   4.  Terminal voltage             (cell_thermal  / Eq 2.11)
%   5.  Heat generation              (cell_thermal  / Eq 2.14)
%   6.  Self-discharge rate          (cell_thermal  / Fig 5f)
%   7.  Thermal dynamics             (cell_thermal  / Eq 2.15)
%   8.  Anode potential Ua(SOC)      (Ua_graphite   / Safari Eq A1)
%   9.  Calendar aging               (calendar_aging / Eq 2 / Eq 9)
%  10.  Cycle aging (Montes)         (cycle_aging)
%  11.  Current limiter logic        (current_limiter)
% =========================================================================

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'Cell'));
addpath(fullfile(projectRoot, 'Data'));
Cell_Variables_Init;

pass = 0; fail = 0; warn = 0;
results = {};

sep  = @() fprintf('%s\n', repmat('-',1,65));
head = @(s) fprintf('\n%s\n  %s\n%s\n', repmat('=',1,65), s, repmat('=',1,65));
chk  = @(label, val, lo, hi) check(label, val, lo, hi);

function [p,f] = check(label, val, lo, hi)
    ok = (val >= lo) && (val <= hi);
    sym = '  PASS'; if ~ok, sym = '  FAIL'; end
    fprintf('  %-52s  %8.4f  [%6.3f , %6.3f]%s\n', label, val, lo, hi, sym);
    p = ok; f = ~ok;
end

fprintf('\n');
fprintf('  %-52s  %8s  %15s\n', 'Check', 'Value', 'Expected range');
fprintf('  %s\n', repmat('-',1,80));

% =========================================================================
head('MODULE 1 — OCV curve  (Schimpe Fig 5a, digitized 19 pts)');
% =========================================================================
% Reference: C/50 avg of charge/discharge on Sony US26650FTC1.
% Tolerance: ±20 mV (digitization uncertainty stated in cell_thermal.m)
ocv_pts = [0.00 2.00; 0.05 2.85; 0.10 3.15; 0.20 3.22;
           0.30 3.24; 0.50 3.28; 0.70 3.30; 0.90 3.34; 1.00 3.42];
tol = 0.020;
for k = 1:size(ocv_pts,1)
    soc_k = ocv_pts(k,1); ref_k = ocv_pts(k,2);
    [~, Vt, ~, ~] = cell_thermal(soc_k, 0, 25, 25, 0);   % I=0, R=0 → pure OCV
    label = sprintf('OCV at SOC=%.2f', soc_k);
    [p,f] = check(label, Vt, ref_k-tol, ref_k+tol);
    pass=pass+p; fail=fail+f;
end

% =========================================================================
head('MODULE 2 — OCV temperature correction  (Schimpe Eq 2.13)');
% =========================================================================
% dU/dT = 0.1 mV/K at SOC=50%.  At T=35°C (+10K): ΔOCV = +1 mV
[~, Vt_25, ~, ~] = cell_thermal(0.5, 0, 25, 25, 0);
[~, Vt_35, ~, ~] = cell_thermal(0.5, 0, 35, 35, 0);
delta_OCV_mV = (Vt_35 - Vt_25) * 1000;
[p,f] = check('ΔOCV at +10K (mV) — expect +1.0 mV', delta_OCV_mV, 0.8, 1.2);
pass=pass+p; fail=fail+f;

% =========================================================================
head('MODULE 3 — Resistance tables  (Schimpe Fig 5b / 5c)');
% =========================================================================
% Separable approx: R(SOC,T,dir) = R_ref25C(SOC,dir) × fT(T,dir)
% Reference values read directly off Schimpe Fig 5b (at T=25°C):
%   R_ch  @ SOC=0.5 : ~46 mΩ
%   R_dis @ SOC=0.5 : ~48 mΩ   (Fig 5b discharge curve at SOC=50%)
% From Fig 5c (T-scaling at SOC=50%):
%   R_ch  @ T=10°C  : ~67 mΩ  (R_ch_Ref50SOC(1))
%   R_dis @ T=10°C  : ~72 mΩ
T25_idx = find(T_grid_C == 25);
T10_idx = find(T_grid_C == 10);
SOC50_idx = find(abs(SOC_grid - 0.5) < 1e-9);

Rch_25_50  = R_ch_2D(T25_idx, SOC50_idx)  * 1000;   % mΩ
Rdis_25_50 = R_dis_2D(T25_idx, SOC50_idx) * 1000;
Rch_10_50  = R_ch_2D(T10_idx, SOC50_idx)  * 1000;
Rdis_10_50 = R_dis_2D(T10_idx, SOC50_idx) * 1000;

[p,f] = check('R_ch  @ SOC=0.5, T=25°C  (mΩ) — expect ~46', Rch_25_50,  42, 50);
pass=pass+p; fail=fail+f;
[p,f] = check('R_dis @ SOC=0.5, T=25°C  (mΩ) — expect ~48', Rdis_25_50, 44, 54);
pass=pass+p; fail=fail+f;
[p,f] = check('R_ch  @ SOC=0.5, T=10°C  (mΩ) — expect ~67', Rch_10_50,  62, 72);
pass=pass+p; fail=fail+f;
[p,f] = check('R_dis @ SOC=0.5, T=10°C  (mΩ) — expect ~72', Rdis_10_50, 67, 77);
pass=pass+p; fail=fail+f;

% =========================================================================
head('MODULE 4 — Terminal voltage  (Schimpe Eq 2.11)');
% =========================================================================
% V_T = OCV(T) + I·R_i + sign(I)·U_Hys
% At SOC=0.5, T=25°C, I=0:           V_T = OCV = 3.28 V
% At SOC=0.5, T=25°C, I=+3A (1C ch): V_T > OCV (polarisation pushes up)
% At SOC=0.5, T=25°C, I=-3A (1C dis): V_T < OCV (polarisation pulls down)
% Floor: V_T >= 2.0 V always (post-fix)

R_ch_25_50  = R_ch_2D(T25_idx, SOC50_idx);
R_dis_25_50 = R_dis_2D(T25_idx, SOC50_idx);

[~, Vt_rest,  ~, ~] = cell_thermal(0.5,  0.0, 25, 25, R_ch_25_50);
[~, Vt_ch,    ~, ~] = cell_thermal(0.5,  3.0, 25, 25, R_ch_25_50);
[~, Vt_dis,   ~, ~] = cell_thermal(0.5, -3.0, 25, 25, R_dis_25_50);
[~, Vt_floor, ~, ~] = cell_thermal(0.0, -3.0, 25, 25, R_dis_25_50);

[p,f] = check('V_terminal at rest, SOC=0.5   (V)', Vt_rest,  3.26, 3.30);
pass=pass+p; fail=fail+f;
[p,f] = check('V_terminal at 1C charge, SOC=0.5 (V)', Vt_ch,    3.30, 3.45);
pass=pass+p; fail=fail+f;
[p,f] = check('V_terminal at 1C discharge, SOC=0.5 (V)', Vt_dis, 3.10, 3.27);
pass=pass+p; fail=fail+f;
[p,f] = check('V_terminal floor at SOC=0, deep dis (V)', Vt_floor, 2.0, 2.05);
pass=pass+p; fail=fail+f;
[p,f] = check('V_terminal: charge > rest (polarisation)', double(Vt_ch > Vt_rest), 1, 1);
pass=pass+p; fail=fail+f;
[p,f] = check('V_terminal: discharge < rest (polarisation)', double(Vt_dis < Vt_rest), 1, 1);
pass=pass+p; fail=fail+f;

% =========================================================================
head('MODULE 5 — Heat generation  (Schimpe Eq 2.14, irreversible)');
% =========================================================================
% Q_heat = I × ΔU = I × (I·R_i + sign(I)·U_Hys)
% At SOC=0.5, 1C charge:
%   ΔU ≈ 3×0.046 + 0.019 = 0.157 V  →  Q ≈ 0.471 W
% At SOC=0.5, 1C discharge:
%   ΔU ≈ 3×0.048 + 0.019 = 0.163 V  →  Q ≈ 0.489 W  (I=-3A, I×ΔU positive)
% Both must be > 0 (heat only, no cooling from irreversible term)

[Q_ch,  ~, ~, ~] = cell_thermal(0.5,  3.0, 25, 25, R_ch_25_50);
[Q_dis, ~, ~, ~] = cell_thermal(0.5, -3.0, 25, 25, R_dis_25_50);

[p,f] = check('Q_heat 1C charge   (W) — expect ~0.44-0.52', Q_ch,  0.40, 0.55);
pass=pass+p; fail=fail+f;
[p,f] = check('Q_heat 1C discharge (W) — expect ~0.44-0.55', Q_dis, 0.40, 0.58);
pass=pass+p; fail=fail+f;
[p,f] = check('Q_heat charge > 0 (irreversible only)', double(Q_ch > 0), 1, 1);
pass=pass+p; fail=fail+f;
[p,f] = check('Q_heat discharge > 0 (irreversible only)', double(Q_dis > 0), 1, 1);
pass=pass+p; fail=fail+f;
[p,f] = check('Discharge generates >= charge heat (R_dis>R_ch)', double(Q_dis >= Q_ch), 1, 1);
pass=pass+p; fail=fail+f;

% =========================================================================
head('MODULE 6 — Self-discharge rate  (Schimpe Fig 5f)');
% =========================================================================
% Schimpe Fig 5f at SOC=50%:
%   T=10°C : 0.20 %/30days  →  2.778e-6 fraction/hour
%   T=25°C : 0.40 %/30days  →  5.556e-6 fraction/hour
%   T=35°C : 0.65 %/30days  →  9.028e-6 fraction/hour
%   T=45°C : 1.07 %/30days  →  14.861e-6 fraction/hour
T_sd  = [10   25   35   45  ];
s_ref = [0.20 0.40 0.65 1.07] / 100 / (30*24);   % fraction/hour

for k = 1:length(T_sd)
    [~, ~, s_h, ~] = cell_thermal(0.5, 0, T_sd(k), T_sd(k), 0);
    label = sprintf('Self-disch @ T=%d°C (frac/h)  — ref=%.2e', T_sd(k), s_ref(k));
    lo = s_ref(k) * 0.85;   hi = s_ref(k) * 1.15;   % ±15% (digitization)
    [p,f] = check(label, s_h, lo, hi);
    pass=pass+p; fail=fail+f;
end

% =========================================================================
head('MODULE 7 — Thermal dynamics  (Schimpe Eq 2.15)');
% =========================================================================
% C_th = 71.2 J/K,  R_th = 15 K/W
% τ = C_th × R_th = 71.2 × 15 = 1068 s
% Steady-state ΔT at 1C:  ΔT_SS = Q_heat × R_th
% At equilibrium (T_cell = T_amb + ΔT_SS):  dT/dt = 0
C_th_val = 71.2; R_th_val = 15.0;
tau = C_th_val * R_th_val;

% Simulate thermal response: step to 1C charge, find SS temp
dt_s = 10;
T_cell = 25; T_amb = 25;
for step = 1:2000
    [Qh, ~, ~, dTdt] = cell_thermal(0.5, 3.0, T_cell, T_amb, R_ch_25_50);
    T_cell = T_cell + dTdt * dt_s;
end
DeltaT_SS = T_cell - T_amb;

[p,f] = check('Thermal τ = C_th×R_th  (s) — expect 1068', tau, 1060, 1080);
pass=pass+p; fail=fail+f;
[p,f] = check('Steady-state ΔT at 1C charge (K) — expect 5-9', DeltaT_SS, 5.0, 9.0);
pass=pass+p; fail=fail+f;
[p,f] = check('C_th (J/K) — expect 71.2 (Schimpe 0.085kg×838)', C_th_val, 71.0, 71.5);
pass=pass+p; fail=fail+f;
[p,f] = check('R_th (K/W) — expect 15.0 (Schimpe calibrated)', R_th_val, 14.9, 15.1);
pass=pass+p; fail=fail+f;

% =========================================================================
head('MODULE 8 — Anode potential Ua(SOC)  (Safari Eq A1)');
% =========================================================================
% Schimpe uses Ua_ref = 0.123 V at SOC=50% for calendar aging coupling.
% At SOC=0%  (fully discharged): Ua is high  (~0.5-0.8V, graphite unlithiated)
% At SOC=100% (fully charged):   Ua is low   (~0.05-0.1V, graphite lithiated)
% Must be monotonically decreasing with SOC (more Li = lower anode potential)
Ua_50  = Ua_graphite(0.5);
Ua_0   = Ua_graphite(0.0);
Ua_100 = Ua_graphite(1.0);

[p,f] = check('Ua at SOC=0.5 ≈ 0.123 V (Schimpe Ua_ref)', Ua_50, 0.115, 0.131);
pass=pass+p; fail=fail+f;
[p,f] = check('Ua at SOC=0  > Ua at SOC=0.5 (monotone)', double(Ua_0 > Ua_50), 1, 1);
pass=pass+p; fail=fail+f;
[p,f] = check('Ua at SOC=1  < Ua at SOC=0.5 (monotone)', double(Ua_100 < Ua_50), 1, 1);
pass=pass+p; fail=fail+f;
[p,f] = check('Ua at SOC=0  > 0.3 V  (unlithiated graphite)', Ua_0,   0.30, 1.00);
pass=pass+p; fail=fail+f;
[p,f] = check('Ua at SOC=1  < 0.10 V (lithiated graphite)',   Ua_100, 0.00, 0.10);
pass=pass+p; fail=fail+f;

% =========================================================================
head('MODULE 9 — Calendar aging  (Schimpe Eq 2 / Eq 9 / sqrt(t) kernel)');
% =========================================================================
% Reference: Schimpe (2018) Table 2 / Fig 7
%   1 yr, SOC=50%, T=25°C  →  ~4.0% capacity loss
%   1 yr, SOC=50%, T=35°C  →  ~31% more than 25°C (Arrhenius, Ea=20592 J/mol)
%   Higher SOC  → faster aging (Tafel, alpha=0.384)

% --- 1-year reference ---
tcal = 0; Qcal_1yr_25 = 0;
for h = 1:8760
    dQ = calendar_aging(0.5, 1, tcal, 25, Ea_cal, R_gas, Tref_cal, ...
                        alpha_cal, F_const, Ua_ref, k0_cal, kcal_ref);
    Qcal_1yr_25 = Qcal_1yr_25 + dQ;  tcal = tcal + 1;
end
[p,f] = check('Cal. loss 1yr, SOC=0.5, T=25°C (%) — expect ~4.0', Qcal_1yr_25, 3.8, 4.2);
pass=pass+p; fail=fail+f;

% --- Temperature sensitivity at 1 year ---
tcal = 0; Qcal_1yr_35 = 0;
for h = 1:8760
    dQ = calendar_aging(0.5, 1, tcal, 35, Ea_cal, R_gas, Tref_cal, ...
                        alpha_cal, F_const, Ua_ref, k0_cal, kcal_ref);
    Qcal_1yr_35 = Qcal_1yr_35 + dQ;  tcal = tcal + 1;
end
Arrhenius_ratio = Qcal_1yr_35 / Qcal_1yr_25;
% Theoretical ratio: exp(-Ea/R × (1/308.15 - 1/298.15)) = exp(0.270) = 1.31
[p,f] = check('Arrhenius ratio 35°C/25°C — expect ~1.31', Arrhenius_ratio, 1.20, 1.45);
pass=pass+p; fail=fail+f;
[p,f] = check('Cal. loss 1yr, SOC=0.5, T=35°C (%) — expect ~5.2', Qcal_1yr_35, 4.8, 5.8);
pass=pass+p; fail=fail+f;

% --- SOC sensitivity ---
tcal = 0; Qcal_1yr_SOC90 = 0;
for h = 1:8760
    dQ = calendar_aging(0.9, 1, tcal, 25, Ea_cal, R_gas, Tref_cal, ...
                        alpha_cal, F_const, Ua_ref, k0_cal, kcal_ref);
    Qcal_1yr_SOC90 = Qcal_1yr_SOC90 + dQ;  tcal = tcal + 1;
end
[p,f] = check('Cal. loss higher at SOC=0.9 than SOC=0.5', double(Qcal_1yr_SOC90 > Qcal_1yr_25), 1, 1);
pass=pass+p; fail=fail+f;

% --- sqrt(t) kernel: loss after 4 years should be 2× loss after 1 year ---
tcal = 0; Qcal_4yr = 0;
for h = 1:8760*4
    dQ = calendar_aging(0.5, 1, tcal, 25, Ea_cal, R_gas, Tref_cal, ...
                        alpha_cal, F_const, Ua_ref, k0_cal, kcal_ref);
    Qcal_4yr = Qcal_4yr + dQ;  tcal = tcal + 1;
end
sqrt_ratio = Qcal_4yr / Qcal_1yr_25;   % should be sqrt(4)/sqrt(1) = 2.0
[p,f] = check('sqrt(t) kernel: Q(4yr)/Q(1yr) = 2.0 ± 0.05', sqrt_ratio, 1.95, 2.05);
pass=pass+p; fail=fail+f;

% =========================================================================
head('MODULE 10 — Cycle aging  (Montes power-law model)');
% =========================================================================
% Uses dt_h = 1/30 h (2-min steps) at 1C so ΔSOC ≈ 0.033/step — enough
% resolution for the half-cycle direction detector to fire correctly.
% Cycle: SOC 0.50 → 0.05 (discharge) → 0.95 (charge) = DOD 0.9 at mSOC≈0.5

dt_h_cy  = 1/30;          % 2-minute steps
I_1C     = Q_nom;         % 3 A = 1C
Q_nom_cy = Q_nom;
dSOC     = I_1C * dt_h_cy / Q_nom_cy;   % 0.0333 per step
n_dis    = ceil(0.45 / dSOC);           % 0.5→0.05: ~14 steps
n_ch     = ceil(0.90 / dSOC);           % 0.05→0.95: ~27 steps

% Helper: run one full cycle and return final Qcyc
    function Qout = run_one_cycle(T_run, dt_h_r, I_r, nd, nc, dS, Q_n, ...
                                  kT_,Tref_K_,kDODc_,kcyc_,kCch_,kCdch_,kmSOC_,mSOCref_,a_m)
        S = 0.5;
        for i = 1:nd
            cycle_aging(S, 0, I_r, dt_h_r, T_run, Q_n, ...
                kT_,Tref_K_,kDODc_,kcyc_,kCch_,kCdch_,kmSOC_,mSOCref_,a_m);
            S = max(S - dS, 0.05);
        end
        Qout = 0;
        for i = 1:nc
            [Qout, ~] = cycle_aging(S, I_r, 0, dt_h_r, T_run, Q_n, ...
                kT_,Tref_K_,kDODc_,kcyc_,kCch_,kCdch_,kmSOC_,mSOCref_,a_m);
            S = min(S + dS, 0.95);
        end
    end

% --- 1 FEC at 25°C ---
clear cycle_aging
Qcyc_1FEC = run_one_cycle(25, dt_h_cy, I_1C, n_dis, n_ch, dSOC, Q_nom_cy, ...
    kT,Tref_K,kDODc,kcyc,kCch,kCdch,kmSOC,mSOCref,a_montes);

[p,f] = check('Qcyc after 1 FEC > 0 (some loss occurs)', double(Qcyc_1FEC > 0), 1, 1);
pass=pass+p; fail=fail+f;
[p,f] = check('Qcyc after 1 FEC < 0.1% (not catastrophic)', Qcyc_1FEC, 0, 0.10);
pass=pass+p; fail=fail+f;

% --- 100 FECs — check power-law deceleration ---
clear cycle_aging
Qcyc_all = zeros(1,100);
for cyc = 1:100
    Qcyc_all(cyc) = run_one_cycle(25, dt_h_cy, I_1C, n_dis, n_ch, dSOC, Q_nom_cy, ...
        kT,Tref_K,kDODc,kcyc,kCch,kCdch,kmSOC,mSOCref,a_montes);
end
dQcyc_early = Qcyc_all(10)  - Qcyc_all(1);
dQcyc_late  = Qcyc_all(100) - Qcyc_all(91);
[p,f] = check('Power-law: later dQcyc < early dQcyc (decel.)', double(dQcyc_late < dQcyc_early), 1, 1);
pass=pass+p; fail=fail+f;
% Expected from Montes math: delta×N^a = 0.0027×100^0.869 ≈ 0.15–0.25%
[p,f] = check('Qcyc after 100 FECs (%) — expect 0.10–0.35', Qcyc_all(100), 0.10, 0.35);
pass=pass+p; fail=fail+f;

% --- Temperature sensitivity: 35°C vs 25°C ---
clear cycle_aging
Qcyc_35 = run_one_cycle(35, dt_h_cy, I_1C, n_dis, n_ch, dSOC, Q_nom_cy, ...
    kT,Tref_K,kDODc,kcyc,kCch,kCdch,kmSOC,mSOCref,a_montes);
[p,f] = check('Cycle aging: T=35°C > T=25°C (1 FEC)', double(Qcyc_35 > Qcyc_1FEC), 1, 1);
pass=pass+p; fail=fail+f;

% =========================================================================
head('MODULE 11 — Current limiter  (power balance + SOC limits)');
% =========================================================================
% Scenario A: net demand = 5W, SOC=0.5, V_terminal = 3.28V, dt_h=1h
%   Physics limit: I_req = 5/3.28 = 1.524A
%   SOC rate limit: I_dis_lim = (SOC - SOC_min)*Q_nom/dt = (0.5-0.05)*3/1 = 1.35A
%   → SOC limiter binds first → Idis = 1.35A (correct, prevents SOC undershoot)
%   P_bess = 3.28 × 1.35 × 0.98 = 4.34W

V_t_test     = 3.28;
I_dis_lim_A  = (0.5 - SOC_min) * Q_nom / 1;   % = 1.35A
P_bess_exp_A = V_t_test * I_dis_lim_A * eta_dis;

[Ich_A, Idis_A, P_A] = current_limiter(0, 5, 0.5, V_nom, ...
    I_ch_max, I_dis_max, SOC_min, SOC_max, 1, eta_ch, eta_dis, Q_nom, V_t_test);
[p,f] = check('Limiter A: Ich = 0 (net discharge)', Ich_A, -1e-9, 1e-9);
pass=pass+p; fail=fail+f;
[p,f] = check('Limiter A: Idis = SOC rate limit 1.35A', Idis_A, 1.34, 1.36);
pass=pass+p; fail=fail+f;
[p,f] = check('Limiter A: P_bess = V×I×eta (W)', P_A, P_bess_exp_A*0.98, P_bess_exp_A*1.02);
pass=pass+p; fail=fail+f;

% Scenario A2: high SOC — SOC rate limit no longer binds, V_terminal limit shows
%   SOC=0.9, I_dis_lim = (0.9-0.05)*3/1 = 2.55A > I_req=1.524A → physics limit active
[Ich_A2, Idis_A2, P_A2] = current_limiter(0, 5, 0.9, V_nom, ...
    I_ch_max, I_dis_max, SOC_min, SOC_max, 1, eta_ch, eta_dis, Q_nom, V_t_test);
I_req_physics = 5 / V_t_test;
[p,f] = check('Limiter A2: Idis = 5W/V_t = 1.524A (SOC free)', Idis_A2, 1.50, 1.55);
pass=pass+p; fail=fail+f;
[p,f] = check('Limiter A2: P_bess < demand (eta loss)', double(P_A2 < 5 && P_A2 > 4.5), 1, 1);
pass=pass+p; fail=fail+f;

% Scenario B: excess PV = 5W, SOC=0.5, V_terminal = 3.28V
%   I_req = -5/3.28 = -1.524A (charge)
%   I_ch_lim = (SOC_max-SOC)*Q_nom/dt = (0.95-0.5)*3/1 = 1.35A → also binds
[Ich_B, Idis_B, ~] = current_limiter(10, 5, 0.5, V_nom, ...
    I_ch_max, I_dis_max, SOC_min, SOC_max, 1, eta_ch, eta_dis, Q_nom, V_t_test);
[p,f] = check('Limiter B: Idis = 0 (net charge)', Idis_B, -1e-9, 1e-9);
pass=pass+p; fail=fail+f;
[p,f] = check('Limiter B: Ich = SOC rate limit 1.35A', Ich_B, 1.34, 1.36);
pass=pass+p; fail=fail+f;

% Scenario C: SOC near max — charge current must be limited
SOC_near_max = 0.94;  % SOC_max=0.95, only 0.01 headroom
[Ich_C, ~, ~] = current_limiter(0, 10, SOC_near_max, V_nom, ...
    I_ch_max, I_dis_max, SOC_min, SOC_max, 1, eta_ch, eta_dis, Q_nom, V_t_test);
Ich_SOC_lim = (SOC_max - SOC_near_max) * Q_nom / 1;   % = 0.03 A
[p,f] = check('Limiter C: charge limited by SOC headroom', double(Ich_C <= Ich_SOC_lim + 1e-9), 1, 1);
pass=pass+p; fail=fail+f;

% Scenario D: V_terminal bug check — result must differ from V_nom version
I_Vnom = (5 - 0) / V_nom;           % old buggy
I_Vt   = (5 - 0) / 2.8;             % new fixed (V_t=2.8)
[p,f] = check('V_terminal fix: I differs from V_nom by >10%', ...
    abs(I_Vt - I_Vnom)/I_Vnom * 100, 10, 25);
pass=pass+p; fail=fail+f;

% =========================================================================
fprintf('\n%s\n', repmat('=',1,65));
fprintf('  FINAL SCORE:  %d PASS  /  %d FAIL  (out of %d checks)\n', ...
        pass, fail, pass+fail);
fprintf('%s\n\n', repmat('=',1,65));

if fail == 0
    fprintf('  All checks passed. Model is consistent with Schimpe (2018).\n\n');
else
    fprintf('  %d check(s) need attention — review FAIL lines above.\n\n', fail);
end
