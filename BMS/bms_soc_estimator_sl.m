function [SOC_est, corrected, soc_out, t_rest_out, i_sign_out] = bms_soc_estimator_sl(I_meas, V_meas, soc_prev, t_rest_prev, i_sign_prev, Q_est, dt_h)
% BMS_SOC_ESTIMATOR_SL  Simulink wrapper — paste THIS into the MATLAB
% Function block. Scalar ports only; no struct ports, no persistent.
%
% Block wiring (all scalars):
%   inputs : I_meas, V_meas        from sensor blocks
%            soc_prev, t_rest_prev, i_sign_prev
%                                   each from its own Memory block fed by the
%                                   corresponding output below
%            Q_est                  from bms_soh_estimator_sl (via Memory)
%            dt_h                   Constant block / workspace var dt_h
%   outputs: SOC_est, corrected, and the three state scalars to feed the
%            Memory blocks
%
% Memory block initial conditions (= bms_init values):
%   soc_prev    -> SOC seed (e.g. 0.5, or OCV-inverted V at t0)
%   t_rest_prev -> 0
%   i_sign_prev -> 0
%
% cfg and tables come from function calls — nothing struct-typed crosses
% a port. The core logic lives in bms_soc_estimator.m (single source,
% offline-tested); this wrapper only packs/unpacks.

cfg = bms_config();
[ocv_SOC, ocv_V, hys_SOC, hys_V] = bms_tables();

est_state = struct('SOC', soc_prev, 't_rest_h', t_rest_prev, 'I_last_sign', i_sign_prev);

[SOC_est, corrected, est_state] = bms_soc_estimator(I_meas, V_meas, est_state, ...
    Q_est, ocv_SOC, ocv_V, hys_SOC, hys_V, cfg, dt_h);

soc_out    = est_state.SOC;
t_rest_out = est_state.t_rest_h;
i_sign_out = est_state.I_last_sign;
end
