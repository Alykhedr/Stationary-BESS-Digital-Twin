function [soc_ocv, valid] = bms_ocv_inverse(V_meas_rest, I_last_sign, SOC_hint, ocv_SOC, ocv_V, hys_SOC, hys_V, cfg)
% BMS_OCV_INVERSE  Invert OCV(SOC) at rest, with hysteresis compensation
% and LFP steep-zone guard rails.
%
% Inputs:
%   V_meas_rest  measured terminal voltage after rest [V]
%   I_last_sign  sign of last nonzero current (+1 charge / -1 discharge / 0)
%   SOC_hint     current SOC estimate, used only to look up U_Hys [-]
%   ocv_SOC/V    shared OCV table (from Data/ocv_table.mat -> ocv.SOC_grid/V_grid)
%   hys_SOC/V    shared hysteresis table (hys.SOC_grid/V_grid) [V]
%   cfg          bms_config struct (uses cfg.est.ocv_corr_zones)
%
% Outputs:
%   soc_ocv      SOC inferred from OCV [-] (clamped to [0,1]; NaN-free)
%   valid        true only if the result lies inside a steep correction zone
%                — caller must NOT apply a correction when valid is false
%
% Notes:
% - Table args are passed in (not loaded here): MATLAB Function blocks can't
%   load() at runtime; the tables are attached as Parameters in the .slx,
%   the offline harness loads Data/ocv_table.mat once and passes them.
% - Tables are the raw 25 degC reference (no dUdT correction, <=6 mV effect).
% - On the flat plateau a 2 mV error maps to >10 % SOC -> guard rails.

% --- remove hysteresis using last current direction ---
U_Hys = interp1(hys_SOC, hys_V, min(max(SOC_hint, 0), 1), 'linear');
V_ocv = V_meas_rest - I_last_sign * U_Hys;

% --- invert the monotonic OCV table (clamp outside range) ---
V_ocv = min(max(V_ocv, ocv_V(1)), ocv_V(end));
soc_ocv = interp1(ocv_V, ocv_SOC, V_ocv, 'linear');
soc_ocv = min(max(soc_ocv, 0), 1);

% --- steep-zone guard: correction only allowed in configured zones ---
valid = false;
zones = cfg.est.ocv_corr_zones;          % [n x 2], e.g. [0 0.10; 0.90 1.00]
for k = 1:size(zones, 1)
    if soc_ocv >= zones(k,1) && soc_ocv <= zones(k,2)
        valid = true;
    end
end
end
