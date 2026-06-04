function [Q_heat, V_terminal, s_rate_per_h, Ua, dTcell_dt] = ...
         cell_thermal(SOC, I, T_cell, T_amb)
% CELL_THERMAL  Single-cell electro-thermal model for Sony US26650FTC1 (LFP-C).
%
% Faithful implementation of Schimpe et al. (2018) "Energy efficiency
% evaluation of a stationary lithium-ion battery container storage system",
% Applied Energy 210, 211-229. Section 2.2.1, Figs. 5a-f.
%
% Inputs:
%   SOC    : State of Charge [0..1]
%   I      : Cell current [A], + = charge, - = discharge (Schimpe convention)
%   T_cell : Current cell temperature [°C] (state variable, from integrator)
%   T_amb  : Ambient temperature surrounding the cell [°C]
%
% Outputs:
%   Q_heat       : Cell heat generation [W], irreversible only (Schimpe Eq. 2.14
%                  with reversible term dropped — see scope notes)
%   V_terminal   : Cell terminal voltage [V] (Schimpe Eq. 1, Eq. 2.11)
%   s_rate_per_h : Self-discharge rate [fraction SOC / hour] (Fig. 5f)
%   Ua           : Anode open-circuit potential [V], for calendar aging coupling
%                  (from Safari et al. 2011, see Schimpe Ch.6 Appendix Eq. A1)
%   dTcell_dt    : Cell temperature derivative [°C/s], for external integration
%
% Scope decisions (documented):
%   - Hysteresis: INCLUDED (Fig. 5d)
%   - Self-discharge: INCLUDED (Fig. 5f)
%   - OCV temperature correction: INCLUDED (Eq. 2.13, using dU/dT at SOC=50%)
%   - 0D dynamic thermal: INCLUDED (Eq. 2.15, lumped cell heat capacity)
%   - Reversible heat (entropy): DROPPED — averages to zero over a cycle
%   - R(SOC,T) coupling: separable approximation
%     R(SOC,T,dir) = R_25C(SOC,dir) × f_T(T,dir)
%     This is standard practice when full 2D R-table is unpublished.

% =====================================================================
% Step 1: Constants
% =====================================================================
T_ref_K = 298.15;                       % Reference temperature [K] (= 25°C)
T_K     = T_cell + 273.15;              % Cell temperature [K], for Arrhenius etc.
soc_c   = max(0, min(1, SOC));          % clamp SOC to [0, 1]

% =====================================================================
% Step 2: Open-circuit voltage at reference temperature
% Source: Schimpe (2018) Fig. 5a, digitized.
% Method: C/50 charge/discharge averaging on Sony US26650FTC1.
% =====================================================================
SOC_OCV_grid = [0.00 0.025 0.05 0.075 0.10 0.15 0.20 0.30 0.40 ...
                0.50 0.60 0.70 0.80 0.85 0.90 0.925 0.95 0.975 1.00];
OCV_grid     = [2.00 2.45  2.85 3.05  3.15 3.20 3.22 3.24 3.26 ...
                3.28 3.29 3.30 3.31 3.32 3.34 3.36  3.38 3.40  3.42];
% NOTE: ±20 mV digitization error.

OCV_ref = interp1(SOC_OCV_grid, OCV_grid, soc_c, 'linear');

% =====================================================================
% Step 3: OCV temperature correction (Schimpe Eq. 2.13)
%   OCV(T) = OCV_ref + (T - T_ref) × dU/dT
% Source: dU/dT taken as the SOC=50% value from Fig. 5e
%   (interpreted in mV/K, consistent with Forgez 2010, Lin 2014 literature).
% Note: Schimpe uses full SOC-dependent dU/dT(SOC). We use a single
% representative value at SOC=50% to avoid digitizing Fig. 5e while keeping
% the temperature correction. Effect: ≤6 mV across operating T range.
% =====================================================================
dUdT_50soc = 0.1e-3;                    % [V/K] at SOC=50%, from Fig. 5e
OCV        = OCV_ref + (T_K - T_ref_K) * dUdT_50soc;

% =====================================================================
% Step 4: Series resistance R(SOC, T, sgn(I))
% Source: Schimpe (2018) Fig. 5b (R vs SOC at 25°C), Fig. 5c (R vs T at SOC=50%)
% Method: 1C, 6-min pulse tests
% =====================================================================
% Fig. 5b: R(SOC) at T = 25°C
SOC_R_grid = 0:0.10:1.00;
R_ch_25C   = [36 40 42 42 43 45 47 51 49 53 65] * 1e-3;   % [Ω] charge
R_dis_25C  = [80 65 55 52 52 50 48 43 42 40 38] * 1e-3;   % [Ω] discharge

% Fig. 5c: R(T) at SOC = 50%
T_R_grid_C  = [10  20  25  30  40  50  60];
R_ch_50soc  = [67  51  46  43  36  33  30] * 1e-3;
R_dis_50soc = [72  55  48  45  40  36  33] * 1e-3;

% Reference values at SOC=50%, T=25°C
R_ch_ref_50soc_25C  = interp1(SOC_R_grid, R_ch_25C,  0.50, 'linear');
R_dis_ref_50soc_25C = interp1(SOC_R_grid, R_dis_25C, 0.50, 'linear');

% Direction-aware lookup (using T_cell, not T_amb)
if I >= 0   % charge
    R_25C   = interp1(SOC_R_grid, R_ch_25C,  soc_c,  'linear', 'extrap');
    R_at_T  = interp1(T_R_grid_C, R_ch_50soc, T_cell, 'linear', 'extrap');
    f_T     = R_at_T / R_ch_ref_50soc_25C;
else        % discharge
    R_25C   = interp1(SOC_R_grid, R_dis_25C, soc_c,  'linear', 'extrap');
    R_at_T  = interp1(T_R_grid_C, R_dis_50soc, T_cell, 'linear', 'extrap');
    f_T     = R_at_T / R_dis_ref_50soc_25C;
end

% Multiplicative separable
R_i = R_25C * f_T;

% =====================================================================
% Step 5: Hysteresis voltage U_Hys(SOC) at T=25°C
% Source: Schimpe (2018) Fig. 5d, digitized at 21 points (5% resolution).
% Method: Schimpe Eq. 2.10 — derived from C/50 charge/discharge curves.
% =====================================================================
SOC_Hys_grid  = 0:0.05:1.00;
U_Hys_grid_mV = [30.0 30.0 28.0 27.0 26.5 27.0 28.5 29.5 27.0 23.0 ...
                 19.0 18.5 18.5 19.0 21.0 22.0 19.0 17.0 18.0 22.0 28.0];
U_Hys = interp1(SOC_Hys_grid, U_Hys_grid_mV, soc_c, 'linear') * 1e-3;  % [V]

% =====================================================================
% Step 6: Terminal voltage (Schimpe Eq. 1 + Eq. 2.11, with OCV(T))
%   ΔU = I·R + sgn(I)·U_Hys
%   V_T = OCV(T) + ΔU
% =====================================================================
dU         = I * R_i + sign(I) * U_Hys;
V_terminal = OCV + dU;

% =====================================================================
% Step 7: Heat generation (Schimpe Eq. 2.14, irreversible only)
%   Q_heat = I × ΔU
% Reversible heat term I·T·dU/dT intentionally dropped.
% =====================================================================
Q_heat = I * dU;

% =====================================================================
% Step 8: Self-discharge rate s(T)
% Source: Schimpe (2018) Fig. 5f at SOC = 50%
% Uses T_cell (not T_amb) for consistency with cell thermodynamic state.
% =====================================================================
T_s_grid_C = [10   15   25   35   45   55  ];
s_grid_30d = [0.20 0.22 0.40 0.65 1.07 2.32];   % [% per 30 days at SOC=50%]

s_per_30d    = interp1(T_s_grid_C, s_grid_30d, T_cell, 'linear', 'extrap');
s_rate_per_h = (s_per_30d / 100) / (30 * 24);   % [fraction / hour]

% =====================================================================
% Step 9: Anode open-circuit potential Ua(SOC)
% For calendar aging coupling only.
% Source: Safari et al. (2011), Schimpe Ch.6 Appendix Eq. A1.
% =====================================================================
xa0   = 8.5e-3;
xa100 = 0.78;
xa    = xa0 + soc_c * (xa100 - xa0);

Ua = 0.6379 ...
   + 0.5416  * exp(-305.5309 * xa) ...
   + 0.0440  * tanh(-(xa - 0.1958) / 0.1088) ...
   - 0.1978  * tanh((xa - 1.0571)  / 0.0854) ...
   - 0.6875  * tanh((xa + 0.0117)  / 0.0529) ...
   - 0.0175  * tanh((xa - 0.5692)  / 0.0875);

% =====================================================================
% Step 10: 0D lumped thermal dynamics (Schimpe Eq. 2.15)
%   C_th × dT_cell/dt = Q_heat - (T_cell - T_amb) / R_th
% Parameters:
%   C_th = m_cell × c_p,cell = 0.085 kg × 838 J/(kg·K) = 71.2 J/K
%     Source: Schimpe Section 2.2.1 (m measured; c_p from literature)
%   R_th = 15 K/W (effective thermal resistance, free-air convection)
%     Calibration: produces ~6 K rise at 1C continuous (matches Schimpe
%     mean module measurement of ~5-12 K rise per cell block at 1C).
%     This is a single-cell isolated value; pack-level R_th will differ.
% =====================================================================
C_th = 71.2;                            % [J/K]
R_th = 15.0;                            % [K/W]

Q_cooling = (T_cell - T_amb) / R_th;
dTcell_dt = (Q_heat - Q_cooling) / C_th;   % [°C/s]

end