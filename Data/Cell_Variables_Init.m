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

%Lookup tables for the Cell Thermal
SOC_grid = 0:0.10:1.00;
T_grid_C = [10 20 25 30 40 50 60];
R_ch_Ref25C  = [36 40 42 42 43 45 47 51 49 53 65] * 1e-3;
R_dis_Ref25C = [80 65 55 52 52 50 48 43 42 40 38] * 1e-3;
R_ch_Ref50SOC  = [67 51 46 43 36 33 30] * 1e-3;
R_dis_Ref50SOC = [72 55 48 45 40 36 33] * 1e-3;
R_ch_ref  = interp1(SOC_grid, R_ch_Ref25C,  0.50);
R_dis_ref = interp1(SOC_grid, R_dis_Ref25C, 0.50);

[SOC_mesh, T_mesh] = meshgrid(SOC_grid, T_grid_C);
R_ch_2D  = zeros(size(SOC_mesh));
R_dis_2D = zeros(size(SOC_mesh));
for i = 1:length(T_grid_C)
    R_ch_2D(i,:)  = R_ch_Ref25C  * (R_ch_Ref50SOC(i)  / R_ch_ref);
    R_dis_2D(i,:) = R_dis_Ref25C * (R_dis_Ref50SOC(i) / R_dis_ref);
end

% -------- Rest of main (unchanged) --------



