function [I_ch_max, I_dis_max, derate_active] = bms_limits_sl(V_meas_max, V_meas_min, T_meas_max, T_meas_min, SOC_est, Q_est, R_ch, R_dis, dt_h)
% BMS_LIMITS_SL  Simulink wrapper. Stateless — no Memory blocks needed.
%
% Block wiring:
%   inputs : V_meas_max/min, T_meas_max/min   single-cell phase: wire the
%                                             same V_meas / T_meas to both
%            SOC_est, Q_est                   from estimator blocks
%            R_ch, R_dis                      from bms_r_estimator_sl
%            dt_h                             Constant
%   outputs: I_ch_max, I_dis_max (raw, pre-gating), derate_active
%
% Core logic: bms_limits.m.

cfg = bms_config();

[I_ch_max, I_dis_max, derate_active] = bms_limits(V_meas_max, V_meas_min, ...
    T_meas_max, T_meas_min, SOC_est, Q_est, R_ch, R_dis, cfg, dt_h);
end
