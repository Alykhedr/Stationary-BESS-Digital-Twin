% TEST_MODE  Self-test for bms_mode (Ali's validation table from the plan).
clear; clc;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'BMS'));
cfg = bms_config();
dt = 1;
M = cfg.mode;
fresh = @() struct('mode', M.INIT, 'fault_code', 0, 'dwell_h', 0, 'uv_latched', 0, 'fault_T_limit', 0);
% args: (I, Vmax, Vmin, Tmax, Tmin, derate, Ich_in, Idis_in, state, cfg, dt)
fprintf('=== test_mode ===\n');

% 1. INIT -> STANDBY on first tick
ms = fresh();
[m, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.STANDBY, '1 INIT->STANDBY failed');

% 2. STANDBY -> CHARGE / DISCHARGE / back
[m, ~, ~, ~, ms] = bms_mode(+1.0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.CHARGE, '2 ->CHARGE failed');
[m, ~, ~, ~, ms] = bms_mode(-1.0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.DISCHARGE, '2 ->DISCHARGE failed');
[m, ~, ~, ~, ms] = bms_mode(0.001, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.STANDBY, '2 ->STANDBY failed');

% 3. DERATE label when active + derate_active
[m, ~, ~, ~, ms] = bms_mode(+1.0, 3.3, 3.3, 42, 42, true, 1.2, 3, ms, cfg, dt);
assert(m == M.DERATE, '3 DERATE failed');

% 4. V forced below 2.0 -> FAULT, both limits zeroed
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, Ic, Id, fc, ms] = bms_mode(-1.0, 3.3, 1.99, 25, 25, false, 3, 20, ms, cfg, dt);
assert(m == M.FAULT && Ic == 0 && Id == 0 && fc == 2, '4 UV FAULT failed');

% 5. V recovers above 2.80 -> STANDBY after 1-tick dwell
[m, ~, ~, ~, ms] = bms_mode(0, 3.3, 2.85, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.STANDBY, '5 UV recovery failed');

% 6. OV fault + hysteresis: no release until V <= 3.45
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, ~, ~, fc, ms] = bms_mode(+1.0, 3.61, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.FAULT && fc == 1, '6 OV FAULT failed');
[m, ~, ~, ~, ms] = bms_mode(0, 3.50, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.FAULT, '6 released above reconnect threshold');
[m, ~, ~, ~, ms] = bms_mode(0, 3.44, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.STANDBY, '6 OV hysteresis release failed');

% 7. No chattering at threshold + noise: hysteresis band holds
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, ~, ~, ~, ms] = bms_mode(+1.0, 3.601, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);  % enter
transitions = 0; prev = m;
rng(7);
for k = 1:50   % V noisy around 3.55: inside [3.45, 3.60] band -> must stay FAULT
    Vn = 3.55 + 2e-3*randn;
    [m, ~, ~, ~, ms] = bms_mode(0, Vn, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
    if m ~= prev, transitions = transitions + 1; end
    prev = m;
end
assert(transitions == 0, '7 chattering inside hysteresis band');

% 8. Charge at T = -1 degC -> UT FAULT (charging forbidden below 0)
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, ~, ~, fc, ms] = bms_mode(+1.0, 3.3, 3.3, -1, -1, false, 3, 3, ms, cfg, dt);
assert(m == M.FAULT && fc == 4, '8 cold-charge FAULT failed');
% ...but discharge at -1 degC is fine (range -20..60)
ms2 = fresh(); [~, ~, ~, ~, ms2] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms2, cfg, dt);
[m2, ~, ~, ~, ~] = bms_mode(-1.0, 3.3, 3.3, -1, -1, false, 3, 20, ms2, cfg, dt);
assert(m2 == M.DISCHARGE, '8 cold discharge wrongly faulted');

% 9. UV at low temperature -> LATCHED, no auto-recovery
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, ~, ~, ~, ms] = bms_mode(-1.0, 3.3, 1.95, 25, 2, false, 3, 20, ms, cfg, dt);  % UV at 2 degC
assert(m == M.FAULT && ms.uv_latched == 1, '9 UV-low-T latch not set');
for k = 1:10
    [m, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.2, 25, 25, false, 3, 3, ms, cfg, dt);  % fully recovered V
end
assert(m == M.FAULT, '9 latched fault auto-recovered');

% 10. A1: must NOT release from FAULT while a DIFFERENT fault is live
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, ~, ~, fc, ms] = bms_mode(+1.0, 3.61, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);   % enter OV
assert(m == M.FAULT && fc == 1, '10 setup OV fault failed');
% OV hysteresis satisfied (Vmax 3.40 <= 3.45) BUT live UV (Vmin 1.90 <= 2.0)
[m, Ic, Id, ~, ms] = bms_mode(0, 3.40, 1.90, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.FAULT && Ic == 0 && Id == 0, '10 released into a live UV (A1 regression)');
% clear the UV too -> now all clear -> release
[m, ~, ~, ~, ms] = bms_mode(0, 3.40, 2.85, 25, 25, false, 3, 3, ms, cfg, dt);
assert(m == M.STANDBY, '10 failed to release once all faults cleared');

% 11. A2: over/under-temperature must fault even when IDLE (no current)
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, Ic, Id, fc, ~] = bms_mode(0, 3.3, 3.3, 65, 65, false, 3, 3, ms, cfg, dt);   % idle, 65 degC
assert(m == M.FAULT && fc == 3 && Ic == 0 && Id == 0, '11 idle over-temp not faulted (A2)');
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, ~, ~, fc, ~] = bms_mode(0, 3.3, 3.3, -25, -25, false, 3, 3, ms, cfg, dt);  % idle, -25 degC
assert(m == M.FAULT && fc == 4, '11 idle under-temp not faulted (A2)');
% ...but idle at 3 degC (below charge-min 0, inside discharge range) must NOT fault
ms = fresh(); [~, ~, ~, ~, ms] = bms_mode(0, 3.3, 3.3, 25, 25, false, 3, 3, ms, cfg, dt);
[m, ~, ~, ~, ~] = bms_mode(0, 3.3, 3.3, 3, 3, false, 3, 3, ms, cfg, dt);
assert(m == M.STANDBY, '11 idle at 3 degC wrongly faulted (idle uses widest envelope)');

fprintf('=== test_mode: ALL PASS ===\n');
