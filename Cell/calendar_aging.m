
function dQcal = calendar_aging(SOC, dt_h, tcal_h, T_degC, ...
    Ea_cal, R_gas, Tref_cal, alpha_cal, F_const, Ua_ref, k0_cal, kcal_ref)

% Arrhenius temperature factor
fTcal = exp(-Ea_cal/R_gas * (1/(T_degC+273.15) - 1/Tref_cal));

% SOC dependence via anode potential
Ua   = Ua_graphite(max(0, min(1, SOC)));
expo = exp((alpha_cal*F_const/R_gas) * ((Ua_ref - Ua)/Tref_cal));
fSOC = (expo + k0_cal) / (1 + k0_cal);

% sqrt(t) increment
dsqrt = sqrt(tcal_h + dt_h) - sqrt(tcal_h);

% capacity loss increment (percent-points)
dQcal = 100 * (kcal_ref * fTcal * fSOC * dsqrt);
end