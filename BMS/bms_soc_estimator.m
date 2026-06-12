function [SOC_est, corrected, est_state] = bms_soc_estimator(I_meas, V_meas, est_state, Q_est, ocv_SOC, ocv_V, hys_SOC, hys_V, cfg, dt_h)
% BMS_SOC_ESTIMATOR  Coulomb counting predictor + OCV-snap corrector.
%
% Predictor (every tick):
%   SOC += (eta_c * I_meas * dt) / Q_est  -  s_rate_nom * dt
%   Self-discharge uses the NOMINAL 25 degC value only — intentional
%   model mismatch vs the plant's T-dependent truth (a real BMS doesn't
%   know the true temperature-dependent rate either).
%
% Corrector (event-triggered OCV snap):
%   trigger: |I_meas| < rest_current_thr for >= rest_time_min
%            AND bms_ocv_inverse returns valid (steep zone)
%   blend:   lambda = min(1, (t_rest - t_min)/t_min)   [ramp policy]
%            SOC <- (1-lambda)*SOC + lambda*SOC_ocv
%
% Inputs:
%   I_meas      measured current [A], + = charge (Schimpe convention)
%   V_meas      measured terminal voltage [V]
%   est_state   state struct (from bms_init), fields:
%                 .SOC          current estimate [-]
%                 .t_rest_h     accumulated rest time [h]
%                 .I_last_sign  sign of last non-rest current (+1/-1/0)
%   Q_est       current capacity estimate [Ah] (from bms_soh_estimator)
%   ocv_*/hys_* shared tables (see bms_ocv_inverse)
%   cfg, dt_h   config struct / timestep [h]
%
% Outputs:
%   SOC_est     updated estimate [-], clamped [0,1]
%   corrected   true on ticks where an OCV snap was applied (lambda > 0)
%               — consumed by bms_soh_estimator as anchor events
%   est_state   updated state
%
% NO persistent. NO truth signals. Tables passed as args (Parameter in .slx).

% --- predictor ---
soc = est_state.SOC ...
    + (cfg.est.eta_coulombic * I_meas * dt_h) / max(Q_est, 1e-6) ...
    - cfg.est.s_rate_nom_per_h * dt_h;
soc = min(max(soc, 0), 1);

% --- rest detection ---
if abs(I_meas) < cfg.est.rest_current_thr
    est_state.t_rest_h = est_state.t_rest_h + dt_h;
else
    est_state.t_rest_h = 0;
    est_state.I_last_sign = sign(I_meas);
end

% --- corrector ---
corrected = false;
t_min = cfg.est.rest_time_min;
if est_state.t_rest_h >= t_min
    [soc_ocv, valid] = bms_ocv_inverse(V_meas, est_state.I_last_sign, soc, ...
                                       ocv_SOC, ocv_V, hys_SOC, hys_V, cfg);
    if valid
        lambda = min(1, (est_state.t_rest_h - t_min) / t_min);
        if lambda > 0
            soc = (1 - lambda) * soc + lambda * soc_ocv;
            corrected = true;
        end
    end
end

est_state.SOC = soc;
SOC_est = soc;
end
