%clear; clc;

% -------- Hardcoded params (model = B3) --------
V_nom     = 3.20;
Q_nom     = 3.00;
eta_ch    = 0.98;
eta_dis   = 0.98;
SOC_min   = 0.05;
SOC_max   = 0.95;
SOC0      = 0.50;
T_degC    = 25;
R_gas     = 8.314462618;
F_const   = 96485;

% Montes cycle-aging
kcyc      = 0.003414;
Tref_K    = 298.0;
kT        = 5.8755;
kDODc     = 0.0046;
kCch      = 0.1038;
kCdch     = 0.296;
kmSOC     = 0.0513;
a_montes  = 0.869;
mSOCref   = 0.42;
eta_ch  = 0.98;
eta_dis = 0.98;
Cth   = 0.085 * 838;

% Calendar aging
kcal_ref  = 3.694e-4;
Ea_cal    = 20592;
alpha_cal = 0.384;
k0_cal    = 0.142;
Tref_cal  = 298.15;
Ua_ref    = 0.123;

I_ch_max  = Q_nom;
I_dis_max = Q_nom;

% -------- Rest of main (unchanged) --------



