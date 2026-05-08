function [V_terminal, Q_heat] = cell_ecm(SOC, I, T)

% ── OCV LOOKUP TABLE ─────────────────────────────────────────────────────
% Source: PDF page 16, Figure 2.12a
% "OCV over SOC at T = 25°C" — measured on Sony US26650FTC1 LFP cell
% Method: C/50 charge + discharge averaged (page 15, Section 2.3.2)
soc_lp = [0  .05  .10  .20  .30  .40  .50  .60  .70  .80  .90  .95  1.0];
ocv_lp = [2.50 3.10 3.20 3.22 3.25 3.28 3.30 3.32 3.33 3.35 3.38 3.42 3.60];

% ── SERIES RESISTANCE WITH TEMPERATURE CORRECTION ────────────────────────
% R0_ref source: PDF page 32 (paper Table 2 embedded in dissertation)
% Cell resistance = 35.75 mΩ, measured at T=25°C, SOC=50%, 1C pulse test
% Temperature dependence: PDF page 16, Figure 2.12c
% "Cell resistance over temperature at SOC=50%" — resistance rises at low T
% Arrhenius scaling approximates the measured curve in Fig 2.12c
R0_ref = 0.03575;        % Ω — Table 2, measured Sony US26650FTC1
T_ref  = 298.15;         % K — 25°C reference temperature
T_K    = T + 273.15;     % convert input °C to Kelvin
R0     = R0_ref * exp(3000 * (1/T_K - 1/T_ref));
% 3000 K is activation energy / gas constant (Ea/R) for LFP
% fitted to match slope in Figure 2.12c

% ── OCV AT REFERENCE TEMPERATURE ─────────────────────────────────────────
% Source: PDF page 15, Section 2.3.2, Figure 2.12a
% U_OCV,Ref(SOC) — the measured OCV curve at Tref = 25°C
OCV_ref = interp1(soc_lp, ocv_lp, max(0, min(1, SOC)), 'pchip');

% ── TEMPERATURE CORRECTION OF OCV ────────────────────────────────────────
% Source: PDF page 18, Equation 2.13
% U_OCV(T,SOC) = U_OCV,Ref(SOC) + (T - T_Ref) × dU_OCV/dT
% dU_OCV/dT is the reaction entropy term — PDF page 16, Figure 2.12e
% "Reaction entropy over SOC at T=25°C" — averaged value ~-0.3 mV/K for LFP
dUdT = -0.3e-3;          % V/K — approximate average from Figure 2.12e
OCV  = OCV_ref + (T_K - T_ref) * dUdT;   % Eq. 2.13, page 18

% ── TERMINAL VOLTAGE ─────────────────────────────────────────────────────
% Source: PDF page 18, Equation 2.11
% ΔU = U_T - U_OCV = I × Ri(SOC,T) + sgn(I) × U_Hys(SOC)
% We skip hysteresis U_Hys for now (Figure 2.12d) — add in Phase 2
% So: V_terminal = OCV - I × R0
V_terminal = OCV - I * R0;               % Eq. 2.11 simplified, page 18

% ── HEAT GENERATION ──────────────────────────────────────────────────────
% Source: PDF page 18, Equation 2.14
% Q_cell = I × (ΔU + T × dU_OCV/dT)
% Two physical terms:
%   Q_irrev = I² × R0  → ohmic heating, always positive, always heats cell
%   Q_rev   = I × T × dUdT → entropic heat, changes sign with current:
%             positive during discharge (heats), negative during charge (cools)
Q_irrev = I^2 * R0;                      % Eq. 2.14 first term, page 18
Q_rev   = I * T_K * dUdT;               % Eq. 2.14 second term, page 18
Q_heat  = Q_irrev + Q_rev;              % total cell heat rate [W], Eq. 2.14

end