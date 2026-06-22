% WITHIN_HOUR_AGING_STUDY  How much does within-hour current/T structure,
% which the 1-hour model smears away, change 10-year aging?
%
% Splits the effect into the two halves discussed:
%   (a) THERMAL TRANSIENT at the hourly-MEAN current — defensible, needs no
%       invented data (T still moves within the hour even at constant current).
%   (b) CURRENT-PULSE reconstruction (each hour's charge delivered as a 1C
%       pulse + rest) — the WORST-CASE bound on the part we cannot calibrate
%       without sub-hourly data. Two mechanisms: the exp(k*C) cycle-aging
%       convexity (Jensen), and extra I^2R heating during the pulse.
%
% Uses the real aging functions + validated thermal rise (7.07 K at 1C, dT~C^2).

clear; clc;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'Cell')); addpath(fullfile(root,'Data'));
run(fullfile(root,'Data','Workspace_set.m'));
root = fileparts(fileparts(mfilename('fullpath')));
load(fullfile(root,'WS_Variables.mat'));
F = load(fullfile(root,'Data','fixture_long.mat')); fx = F.fixture;

I = fx.I_true; SOC = fx.SOC_true; T = fx.T_true; n = numel(I); dt_h = 1;

% Aging T-factor helpers (exact forms from the aging functions)
fTcal = @(Tc) exp(-Ea_cal/R_gas .* (1./(Tc+273.15) - 1/Tref_cal));   % calendar
fTcyc = @(Tc) exp(kT .* (Tc+273.15 - Tref_K) ./ (Tc+273.15));        % cycle
dT_1C = 7.07;                      % validated steady rise at 1C [K]
dTss  = @(C) dT_1C .* C.^2;        % I^2R steady rise scales with C^2

% =====================================================================
% PART A — baseline calendar/cycle split over the 10-yr fixture
% =====================================================================
clear cycle_aging                 % reset rainflow persistent state
Qcal = 0; tcal = 0; Qcyc = 0;
for k = 1:n
    Qcal = Qcal + calendar_aging(SOC(k), dt_h, tcal, T(k), ...
        Ea_cal, R_gas, Tref_cal, alpha_cal, F_const, Ua_ref, k0_cal, kcal_ref);
    tcal = tcal + dt_h;
    Ich = max(I(k),0); Idis = max(-I(k),0);
    [Qcyc, ~] = cycle_aging(SOC(k), Ich, Idis, dt_h, T(k), Q_nom, ...
        kT, Tref_K, kDODc, kcyc, kCch, kCdch, kmSOC, mSOCref, a_montes);
end
fade = Qcal + Qcyc;               % match fixture: SOH loss in %-points
fprintf('=== PART A: baseline split (10 yr) ===\n');
fprintf('  Calendar : %.3f %%   (%.0f%% of fade)\n', Qcal, 100*Qcal/fade);
fprintf('  Cycle    : %.3f %%   (%.0f%% of fade)\n', Qcyc, 100*Qcyc/fade);
fprintf('  Total    : %.3f %%   (fixture SOH loss = %.2f %%)\n', fade, (1-fx.SOH_true(end))*100);

% =====================================================================
% PART B(i) — current-pulse CONVEXITY on cycle aging (exp(k*C), Jensen)
% throughput-weighted severity ratio: deliver each hour's charge at 1C
% =====================================================================
num = 0; den = 0; Cbar_active = [];
for k = 1:n
    Ich = max(I(k),0); Idis = max(-I(k),0);
    thru = (Ich + Idis) * dt_h;
    if thru <= 0, continue; end
    if Idis > 0, Cbar = Idis/Q_nom; kC = kCdch; else, Cbar = Ich/Q_nom; kC = kCch; end
    Cbar = min(Cbar, 1);                       % cap mean at 1C (can't exceed pulse)
    den = den + thru * exp(kC * Cbar);         % baseline severity
    num = num + thru * exp(kC * 1.0);          % 1C-pulse severity, same charge
    Cbar_active(end+1) = Cbar; %#ok<SAGROW>
end
cyc_amp_C = num / den;
fprintf('\n=== PART B(i): cycle convexity (current pulse, Jensen) ===\n');
fprintf('  Active-hour mean C-rate: median %.2f C, 95th pct %.2f C\n', ...
        median(Cbar_active), prctile(Cbar_active,95));
fprintf('  Cycle-aging amplification (deliver as 1C pulse): x%.3f\n', cyc_amp_C);

% =====================================================================
% PART B(ii) — extra I^2R HEATING during the 1C pulse, on BOTH agings
% pulse at 1C for fraction f=Cbar (worst-case full 7.07 K rise), rest cools
% =====================================================================
calw_base=0; calw_pulse=0; cycw_base=0; cycw_pulse=0;
for k = 1:n
    Ich = max(I(k),0); Idis = max(-I(k),0); thru=(Ich+Idis)*dt_h;
    if thru<=0, continue; end
    Cbar = min((Ich+Idis)/Q_nom,1); f = Cbar;          % pulse fraction
    Tk = T(k);
    Tpulse = Tk + (dT_1C - dTss(Cbar));                % extra rise vs mean heating
    % weight by throughput (cycle) and by dwell (calendar ~ time, but use thru
    % here as the within-active-hour proxy for where heating coincides with use)
    calw_base  = calw_base  + fTcal(Tk);
    calw_pulse = calw_pulse + f*fTcal(Tpulse) + (1-f)*fTcal(Tk);
    cycw_base  = cycw_base  + thru*fTcyc(Tk);
    cycw_pulse = cycw_pulse + thru*(f*fTcyc(Tpulse) + (1-f)*fTcyc(Tk));
end
cal_amp_heat = calw_pulse/calw_base;
cyc_amp_heat = cycw_pulse/cycw_base;
fprintf('\n=== PART B(ii): pulse I^2R heating on aging ===\n');
fprintf('  Calendar T-amplification: x%.4f\n', cal_amp_heat);
fprintf('  Cycle    T-amplification: x%.4f\n', cyc_amp_heat);

% =====================================================================
% PART A(thermal) — half (a): thermal transient at MEAN current
% ΔT_mean = 7.07*Cbar^2 (small). Effect on calendar+cycle T-factors.
% =====================================================================
cal_a=0; cal_a0=0; cyc_a=0; cyc_a0=0;
for k=1:n
    Ich=max(I(k),0); Idis=max(-I(k),0); thru=(Ich+Idis)*dt_h;
    Cbar=min((Ich+Idis)/Q_nom,1);
    Tmean = T(k) + 0.5*dTss(Cbar);     % avg within-hour extra rise (~half of ss)
    cal_a0=cal_a0+fTcal(T(k));        cal_a=cal_a+fTcal(Tmean);
    if thru>0, cyc_a0=cyc_a0+thru*fTcyc(T(k)); cyc_a=cyc_a+thru*fTcyc(Tmean); end
end
cal_amp_a = cal_a/cal_a0; cyc_amp_a = cyc_a/cyc_a0;

% =====================================================================
% COMBINE -> two decision numbers
% =====================================================================
% (a) thermal transient at mean current (defensible, no invented data)
fade_a = Qcal*cal_amp_a + Qcyc*cyc_amp_a;
% (b) full current-pulse worst-case bound (convexity + pulse heating)
fade_b = Qcal*cal_amp_heat + Qcyc*cyc_amp_C*cyc_amp_heat;

fprintf('\n========================================================\n');
fprintf('  DECISION NUMBERS (10-yr SOH loss)\n');
fprintf('  Baseline (1-h mean model)           : %.3f %%\n', fade);
fprintf('  (a) + thermal transient @ mean I    : %.3f %%  (Delta %+.3f pp, %+.1f%% rel)\n', ...
        fade_a, fade_a-fade, 100*(fade_a-fade)/fade);
fprintf('  (b) + 1C-pulse worst-case bound     : %.3f %%  (Delta %+.3f pp, %+.1f%% rel)\n', ...
        fade_b, fade_b-fade, 100*(fade_b-fade)/fade);
fprintf('========================================================\n');
fprintf('Half (a) needs NO invented data (defensible). Half (b) is the\n');
fprintf('UNCALIBRATABLE upper bound (needs sub-hourly data we do not have).\n');
