function [ocv_SOC, ocv_V, hys_SOC, hys_V] = bms_tables()
% BMS_TABLES  Shared OCV/hysteresis tables as plain arrays (Simulink-safe).
%
% Function-call access for MATLAB Function blocks (load() of .mat files is
% not allowed inside blocks). MUST stay numerically identical to
% Data/ocv_table.mat — test_estimators asserts this. The .mat remains the
% source for offline scripts; this is its codegen-compatible mirror.
%
% Source: Schimpe (2018) Fig. 5a / 5d, digitized (see cell_thermal.m).

ocv_SOC = [0.00 0.025 0.05 0.075 0.10 0.15 0.20 0.30 0.40 ...
           0.50 0.60 0.70 0.80 0.85 0.90 0.925 0.95 0.975 1.00];
ocv_V   = [2.00 2.45  2.85 3.05  3.15 3.20 3.22 3.24 3.26 ...
           3.28 3.29 3.30 3.31 3.32 3.34 3.36  3.38 3.40  3.42];

hys_SOC = 0:0.05:1.00;
hys_V   = [30.0 30.0 28.0 27.0 26.5 27.0 28.5 29.5 27.0 23.0 ...
           19.0 18.5 18.5 19.0 21.0 22.0 19.0 17.0 18.0 22.0 28.0] * 1e-3;
end
