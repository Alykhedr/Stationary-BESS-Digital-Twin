function [Q_heat, V_terminal] = cell_thermal(SOC, I, T_amb, map)
% CELL_THERMAL  Schimpe 2018 Applied Energy, Section 2.2.1-2.2.2
% Isothermal assumption — T_cell = T_amb (no dynamic heat balance)
% Q_heat logged for energy loss analysis only

if nargin < 4 || ~isstruct(map)
    map.xa0   = 8.5e-3;
    map.xa100 = 0.78;
    map.xc0   = 0.916;
    map.xc100 = 0.045;
end

T_ref = 298.15;
T_K   = T_amb + 273.15;

% OCV from half-cell potentials (Safari et al., Chapter 6)
soc_c = max(0, min(1, SOC));
xa    = map.xa0 + soc_c * (map.xa100 - map.xa0);
xc    = map.xc0 + soc_c * (map.xc100 - map.xc0);

Ua = 0.6379 ...
   + 0.5416  * exp(-305.5309 * xa) ...
   + 0.0440  * tanh(-(xa - 0.1958) / 0.1088) ...
   - 0.1978  * tanh((xa - 1.0571) / 0.0854) ...
   - 0.6875  * tanh((xa + 0.0117) / 0.0529) ...
   - 0.0175  * tanh((xa - 0.5692) / 0.0875);

Uc = 3.4323 ...
   - 0.8428   * exp(-80.2493 * (1 - xc)^1.3198) ...
   - 3.2474e-6 * exp(20.2645 * (1 - xc)^3.8003) ...
   + 3.2482e-6 * exp(20.2646 * (1 - xc)^3.7995);

OCV_ref = Uc - Ua;

% Temperature correction of OCV (Eq. 2, Schimpe 2018)
dUdT = -0.3e-3;
OCV  = OCV_ref + (T_K - T_ref) * dUdT;

% Internal resistance (Fig 5b, Schimpe 2018)
R0_ref = 0.03575;
R0     = R0_ref * exp(3000 * (1/T_K - 1/T_ref));

% Terminal voltage (Eq. 1, hysteresis neglected)
V_terminal = OCV - I * R0;

% Heat generation (Eq. 3)
Q_heat = I^2 * R0 + I * T_K * dUdT;
end