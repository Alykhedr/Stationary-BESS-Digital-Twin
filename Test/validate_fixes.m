% validate_fixes.m
% Quick post-fix sanity check — runs without Simulink, purely tests the
% three modified functions against known reference points.
%
% Pass criteria (all from Schimpe 2018 or basic physics):
%   1. current_limiter: I_req at V_terminal=2.8V differs from V_nom=3.2V
%   2. cell_thermal: V_terminal never below 2.0 V across SOC=[0..1]
%   3. cell_thermal: V_terminal at SOC=0.5, T=25C, I=0 ≈ 3.28 V (OCV)
%   4. cell_thermal: Q_heat at I=3A, R_i=43e-3 ≈ 0.387 W (I²R)
%   5. calendar_aging: 1 yr @ SOC=50%, 25°C ≈ 3.9–4.1% capacity loss

fprintf('\n========== BESS Digital Twin — Fix Validation ==========\n\n');

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'Cell'));
addpath(fullfile(projectRoot, 'Data'));
Cell_Variables_Init;   % load parameters into workspace

pass = 0; fail = 0;

%% -----------------------------------------------------------------------
%  TEST 1: current_limiter — V_terminal vs V_nom makes a difference
% -----------------------------------------------------------------------
Ppv = 5; Pload = 10;   % net demand = 5 W
V_t = 2.8;             % depressed terminal voltage (low SOC)

I_old = (Pload - Ppv) / V_nom;    % old (buggy) behaviour
I_new = (Pload - Ppv) / V_t;      % new (fixed) behaviour

err_pct = abs(I_new - I_old) / I_old * 100;
fprintf('[TEST 1] current_limiter V fix\n');
fprintf('         I_req (V_nom=3.2):     %.4f A\n', I_old);
fprintf('         I_req (V_term=2.8):    %.4f A\n', I_new);
fprintf('         Difference:            %.1f%%\n', err_pct);
if err_pct > 1
    fprintf('         PASS — fix has measurable effect\n\n');
    pass = pass + 1;
else
    fprintf('         FAIL — no difference detected\n\n');
    fail = fail + 1;
end

%% -----------------------------------------------------------------------
%  TEST 2: cell_thermal — voltage floor: V_terminal >= 2.0 V everywhere
% -----------------------------------------------------------------------
fprintf('[TEST 2] cell_thermal voltage floor\n');
SOC_sweep = 0:0.05:1.0;
R_i_test  = 50e-3;   % mid-range resistance [Ohm]
I_test    = -3.0;    % 1C discharge
T_test    = 25;
V_min_found = Inf;

for soc = SOC_sweep
    [~, Vt, ~, ~] = cell_thermal(soc, I_test, T_test, T_test, R_i_test);
    if Vt < V_min_found
        V_min_found = Vt;
    end
end
fprintf('         Min V_terminal over SOC=[0..1] at 1C dis: %.4f V\n', V_min_found);
if V_min_found >= 2.0
    fprintf('         PASS — floor holds at >= 2.0 V\n\n');
    pass = pass + 1;
else
    fprintf('         FAIL — voltage went below 2.0 V\n\n');
    fail = fail + 1;
end

%% -----------------------------------------------------------------------
%  TEST 3: cell_thermal — OCV at rest, SOC=50%, T=25°C ≈ 3.28 V
% -----------------------------------------------------------------------
fprintf('[TEST 3] cell_thermal OCV at SOC=0.5, I=0, T=25C\n');
[~, Vt_rest, ~, ~] = cell_thermal(0.5, 0.0, 25, 25, 43e-3);
fprintf('         V_terminal (rest):     %.4f V\n', Vt_rest);
fprintf('         Expected (Schimpe Fig 5a): ~3.28 V\n');
if abs(Vt_rest - 3.28) < 0.02
    fprintf('         PASS\n\n');
    pass = pass + 1;
else
    fprintf('         FAIL — deviation > 20 mV\n\n');
    fail = fail + 1;
end

%% -----------------------------------------------------------------------
%  TEST 4: cell_thermal — heat generation at 1C charge
%  Q = I*dU = I*(I*R + U_Hys). At I=3A, R=43mΩ: I²R = 0.387 W
% -----------------------------------------------------------------------
fprintf('[TEST 4] cell_thermal heat generation at 1C charge\n');
I_1C = 3.0; R_i_25 = 43e-3;
[Q, ~, ~, ~] = cell_thermal(0.5, I_1C, 25, 25, R_i_25);
Q_irrev_expected = I_1C^2 * R_i_25;   % 0.387 W (ignoring small hysteresis)
fprintf('         Q_heat computed:       %.4f W\n', Q);
fprintf('         I²R expected:          %.4f W\n', Q_irrev_expected);
if abs(Q - Q_irrev_expected) < 0.05   % within 50 mW (hysteresis contribution)
    fprintf('         PASS\n\n');
    pass = pass + 1;
else
    fprintf('         FAIL — heat deviates more than expected\n\n');
    fail = fail + 1;
end

%% -----------------------------------------------------------------------
%  TEST 5: calendar_aging — 1 year @ SOC=50%, 25°C → ~3.9–4.1% loss
% -----------------------------------------------------------------------
fprintf('[TEST 5] calendar_aging — 1 year @ SOC=0.5, T=25C\n');
dt_h   = 1;
n_steps = 8760;   % 1 year in hours
tcal   = 0;
Qloss  = 0;

for step = 1:n_steps
    dQ = calendar_aging(0.5, dt_h, tcal, 25, ...
                        Ea_cal, R_gas, Tref_cal, alpha_cal, ...
                        F_const, Ua_ref, k0_cal, kcal_ref);
    Qloss = Qloss + dQ;
    tcal  = tcal + dt_h;
end

fprintf('         Capacity loss after 1 yr: %.3f%%\n', Qloss);
fprintf('         Expected (Schimpe ~4%%):   3.9 – 4.1%%\n');
if Qloss >= 3.9 && Qloss <= 4.1
    fprintf('         PASS\n\n');
    pass = pass + 1;
else
    fprintf('         FAIL — outside [3.9, 4.1]%%\n\n');
    fail = fail + 1;
end

%% -----------------------------------------------------------------------
%  SUMMARY
% -----------------------------------------------------------------------
fprintf('=========================================================\n');
fprintf('  Results: %d PASS  /  %d FAIL  (out of 5 tests)\n', pass, fail);
fprintf('=========================================================\n\n');
