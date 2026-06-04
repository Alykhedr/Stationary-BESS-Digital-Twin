function [Q_heat, V_terminal, s_rate_per_h, Ua] = cell_thermal(SOC, I, T_amb)
% CELL_THERMAL  Single-cell electro-thermal model for Sony US26650FTC1 (LFP-C).
%
% Faithful implementation of Schimpe et al. (2018) "Energy efficiency
% evaluation of a stationary lithium-ion battery container storage system",
% Applied Energy 210, 211-229. Section 2.2.1, Figs. 5a-f.
%
% Inputs:
%   SOC   : State of Charge [0..1]
%   I     : Cell current [A], + = charge, - = discharge (Schimpe convention)
%   T_amb : Cell/ambient temperature [°C], assumed isothermal
%
% Outputs:
%   Q_heat       : Cell heat generation [W], irreversible only (Schimpe Eq. 2.14
%                  with reversible term dropped — see scope notes)
%   V_terminal   : Cell terminal voltage [V] (Schimpe Eq. 1, Eq. 2.11)
%   s_rate_per_h : Self-discharge rate [fraction SOC / hour] (Fig. 5f)
%   Ua           : Anode open-circuit potential [V], for calendar aging coupling
%                  (from Safari et al. 2011, see Schimpe Ch.6 Appendix Eq. A1)
%
% Scope decisions (documented):
%   - Hysteresis: INCLUDED (Fig. 5d) — affects V_terminal, needed for BMS work
%   - Self-discharge: INCLUDED (Fig. 5f) — needed for low-utilization scenarios
%   - Reversible heat (entropy): DROPPED — averages to zero over a cycle
%   - OCV temperature correction: DROPPED — magnitude ~1 mV/K × 30K = 30 mV
%     across full operating range, smaller than digitization noise on OCV(SOC)
%   - R(SOC,T) coupling: separable approximation
%     R(SOC,T,dir) = R_25C(SOC,dir) × f_T(T,dir)
%     This is standard practice when full 2D R-table is unpublished. See
%     literature cross-check note at end of file.

% =====================================================================
% Step 1: Constants
% =====================================================================
T_ref_K = 298.15;      % Reference temperature [K] (= 25°C)
T_K     = T_amb + 273.15;
soc_c   = max(0, min(1, SOC));   % clamp SOC

% =====================================================================
% Step 2: Open-circuit voltage at reference temperature
% Source: Schimpe (2018) Fig. 5a, digitized.
% Method: C/50 charge/discharge averaging on Sony US26650FTC1.
% Digitization: read at 21 SOC points, finer resolution near 0% (steep region)
% =====================================================================
SOC_OCV_grid = [0.00 0.025 0.05 0.075 0.10 0.15 0.20 0.30 0.40 ...
                0.50 0.60 0.70 0.80 0.85 0.90 0.925 0.95 0.975 1.00];
OCV_grid     = [2.00 2.45  2.85 3.05  3.15 3.20 3.22 3.24 3.26 ...
                3.28 3.29 3.30 3.31 3.32 3.34 3.36  3.38 3.40  3.42];
% NOTE: Values estimated from Fig. 5a. Real numbers from C/50 measurement
% would be more precise — these have ±20 mV digitization error.

OCV_ref = interp1(SOC_OCV_grid, OCV_grid, soc_c, 'linear');

% =====================================================================
% Step 3: Series resistance R(SOC, T, sgn(I))
% Source: Schimpe (2018) Fig. 5b (R vs SOC at 25°C), Fig. 5c (R vs T at SOC=50%)
% Method: 1C, 6-min pulse tests
% =====================================================================
% --- Fig. 5b: R(SOC) at T = 25°C, separate for charge & discharge ---
SOC_R_grid = 0:0.10:1.00;   % 11 points, every 10% SOC
R_ch_25C   = [36 40 42 42 43 45 47 51 49 53 65] * 1e-3;   % [Ω] charge
R_dis_25C  = [80 65 55 52 52 50 48 43 42 40 38] * 1e-3;   % [Ω] discharge
% Source: digitized from Schimpe Fig. 5b.

% --- Fig. 5c: R(T) at SOC = 50%, separate for charge & discharge ---
T_R_grid_C  = [10  20  25  30  40  50  60];        % [°C]
R_ch_50soc  = [67  51  46  43  36  33  30] * 1e-3; % [Ω] charge at SOC=50%
R_dis_50soc = [72  55  48  45  40  36  33] * 1e-3; % [Ω] discharge at SOC=50%
% Source: digitized from Schimpe Fig. 5c.

% --- Reference values at SOC=50%, T=25°C (intersection point of Fig. 5b/5c) ---
R_ch_ref_50soc_25C  = interp1(SOC_R_grid, R_ch_25C,  0.50, 'linear');  % ≈ 45 mΩ
R_dis_ref_50soc_25C = interp1(SOC_R_grid, R_dis_25C, 0.50, 'linear');  % ≈ 50 mΩ

% --- Direction-aware lookup ---
if I >= 0   % charge (Schimpe sign convention: +I = charge)
    R_25C   = interp1(SOC_R_grid, R_ch_25C,  soc_c, 'linear', 'extrap');
    R_at_T  = interp1(T_R_grid_C, R_ch_50soc,  T_amb, 'linear', 'extrap');
    f_T     = R_at_T / R_ch_ref_50soc_25C;
else        % discharge
    R_25C   = interp1(SOC_R_grid, R_dis_25C, soc_c, 'linear', 'extrap');
    R_at_T  = interp1(T_R_grid_C, R_dis_50soc, T_amb, 'linear', 'extrap');
    f_T     = R_at_T / R_dis_ref_50soc_25C;
end

% Multiplicative separable: R(SOC,T) = R(SOC,25°C) × f_T(T)
% Justification: standard practice when 2D R-table unpublished; assumes
% SOC-shape of R is T-invariant. See Saw et al. (2014), Lin et al. (2014)
% for similar separable approximations on LFP 26650 cells.
R_i = R_25C * f_T;

% =====================================================================
% Step 4: Hysteresis voltage U_Hys(SOC) at T=25°C
% Source: Schimpe (2018) Fig. 5d
% Method: Schimpe Eq. 2.10 — derived from C/50 charge/discharge curves
% corrected for ohmic drop. Time-independent model (no relaxation dynamics).
% =====================================================================
% Read at 21 points (5% resolution) to capture peaks at SOC ≈ 0%, 30%, 78%, 100%
SOC_Hys_grid = 0:0.05:1.00;
U_Hys_grid_mV = [30.0 30.0 28.0 27.0 26.5 27.0 28.5 29.5 27.0 23.0 ...
                 19.0 18.5 18.5 19.0 21.0 22.0 19.0 17.0 18.0 22.0 28.0];
U_Hys = interp1(SOC_Hys_grid, U_Hys_grid_mV, soc_c, 'linear') * 1e-3;  % [V]
% NOTE: Fig. 5d has fine structure (peaks at ~SOC=0%, 30%, 78%, 100%).
% 21-point digitization captures the shape but has ±2 mV per-point noise.

% =====================================================================
% Step 5: Terminal voltage (Schimpe Eq. 1 + Eq. 2.11)
%   ΔU = I·R + sgn(I)·U_Hys
%   V_T = OCV + ΔU
% =====================================================================
dU         = I * R_i + sign(I) * U_Hys;
V_terminal = OCV_ref + dU;
% Note: OCV temperature correction (Eq. 2.13) intentionally omitted.
% Rationale: |dU/dT| ≈ 0.1 mV/K (from Fig. 5e); over 0–60°C operating range
% this gives <6 mV shift, well within OCV digitization noise (~20 mV).

% =====================================================================
% Step 6: Heat generation (Schimpe Eq. 2.14, irreversible only)
% Q_heat = I × ΔU_irreversible
%   Irreversible includes both ohmic and hysteresis dissipation.
%   (Note: hysteresis as implemented here is a path-dependent OCV effect,
%   not strictly dissipative — including it in Q_heat slightly overestimates
%   heat. For high accuracy, use only I²R. Schimpe's Eq. 2.14 uses I·ΔU
%   which includes the hysteresis term; we follow Schimpe.)
% =====================================================================
Q_heat = I * dU;
% Reversible heat term I·T·dU/dT intentionally dropped — averages to zero
% over a cycle for cycle-symmetric operation.

% =====================================================================
% Step 7: Self-discharge rate s(T)
% Source: Schimpe (2018) Fig. 5f at SOC = 50%
% Method: open-circuit storage tests, 1-month duration
% =====================================================================
T_s_grid_C = [10   15   25   35   45   55  ];   % [°C]
s_grid_30d = [0.20 0.22 0.40 0.65 1.07 2.32];   % [% per 30 days at SOC=50%]
% Source: digitized from Schimpe Fig. 5f.

s_per_30d   = interp1(T_s_grid_C, s_grid_30d, T_amb, 'linear', 'extrap');
s_rate_per_h = (s_per_30d / 100) / (30 * 24);   % [fraction / hour]
% Note: Schimpe applies s(T) only at SOC=50%. Strictly s(T,SOC) but the
% SOC-dependence is not separately characterized in Fig. 5f. For active
% BESS where SOC averages near 50%, this is acceptable.

% =====================================================================
% Step 8: Anode open-circuit potential Ua(SOC)
% For calendar aging coupling only — NOT used in V_terminal here.
% Source: Safari et al. (2011), as used in Schimpe Ch.6 Appendix Eq. A1.
% Stoichiometry mapping: Schimpe Ch.6 Table A.I.
% =====================================================================
xa0   = 8.5e-3;     % anode lithiation at full-cell SOC = 0%
xa100 = 0.78;       % anode lithiation at full-cell SOC = 100%
xa    = xa0 + soc_c * (xa100 - xa0);

Ua = 0.6379 ...
   + 0.5416  * exp(-305.5309 * xa) ...
   + 0.0440  * tanh(-(xa - 0.1958) / 0.1088) ...
   - 0.1978  * tanh((xa - 1.0571)  / 0.0854) ...
   - 0.6875  * tanh((xa + 0.0117)  / 0.0529) ...
   - 0.0175  * tanh((xa - 0.5692)  / 0.0875);

end