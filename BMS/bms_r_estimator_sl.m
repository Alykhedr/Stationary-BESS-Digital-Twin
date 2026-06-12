function [R_ch, R_dis, V_prev_out, I_prev_out, R_ch_out, R_dis_out] = bms_r_estimator_sl(V_meas, I_meas, V_prev, I_prev, R_ch_prev, R_dis_prev)
% BMS_R_ESTIMATOR_SL  Simulink wrapper. Scalar ports only.
%
% Block wiring:
%   inputs : V_meas, I_meas   from sensor blocks
%            V_prev, I_prev   Memory blocks (init: V at t0 / 0)
%            R_ch_prev        Memory (init: 43e-3  = cfg.rest.R_nominal_ch)
%            R_dis_prev       Memory (init: 50e-3  = cfg.rest.R_nominal_dis)
%   outputs: R_ch, R_dis (to bms_limits_sl), plus four state scalars back
%            to their Memory blocks
%
% Core logic: bms_r_estimator.m.

cfg = bms_config();

r_state = struct('V_prev', V_prev, 'I_prev', I_prev, ...
                 'R_ch', R_ch_prev, 'R_dis', R_dis_prev);

[R_ch, R_dis, r_state] = bms_r_estimator(V_meas, I_meas, r_state, cfg);

V_prev_out = r_state.V_prev;
I_prev_out = r_state.I_prev;
R_ch_out   = r_state.R_ch;
R_dis_out  = r_state.R_dis;
end
