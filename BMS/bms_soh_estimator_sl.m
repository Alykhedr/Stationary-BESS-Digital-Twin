function [SOH_est, Q_est, Q_out, Ah_out, anchor_out, has_anchor_out] = bms_soh_estimator_sl(SOC_est, corrected, I_meas, Q_prev, Ah_prev, anchor_prev, has_anchor_prev, dt_h)
% BMS_SOH_ESTIMATOR_SL  Simulink wrapper. Scalar ports only.
%
% Block wiring:
%   inputs : SOC_est, corrected   from bms_soc_estimator_sl block
%            I_meas               from current sensor block
%            Q_prev               Memory (init: Q_nom = 3.0)
%            Ah_prev              Memory (init: 0)
%            anchor_prev          Memory (init: 0)
%            has_anchor_prev      Memory (init: 0)
%            dt_h                 Constant
%   outputs: SOH_est, Q_est (Q_est also loops to bms_soc_estimator_sl via
%            Memory), plus the four state scalars back to their Memory blocks
%
% Core logic: bms_soh_estimator.m.

cfg = bms_config();

soh_state = struct('Q_est', Q_prev, 'Ah_acc', Ah_prev, ...
                   'anchor_soc', anchor_prev, 'has_anchor', has_anchor_prev);

[SOH_est, Q_est, soh_state] = bms_soh_estimator(SOC_est, corrected, I_meas, soh_state, cfg, dt_h);

Q_out          = soh_state.Q_est;
Ah_out         = soh_state.Ah_acc;
anchor_out     = soh_state.anchor_soc;
has_anchor_out = soh_state.has_anchor;
end
