function [mode, I_ch_max, I_dis_max, fault_code, mode_out, fault_out, dwell_out, latch_out, Tlim_out] = bms_mode_sl(I_meas, V_meas_max, V_meas_min, T_meas_max, T_meas_min, derate_active, I_ch_max_in, I_dis_max_in, mode_prev, fault_prev, dwell_prev, latch_prev, Tlim_prev, dt_h)
% BMS_MODE_SL  Simulink wrapper for the protection state machine. Scalar ports.
%
% Block wiring:
%   inputs : I_meas, V_meas_max/min, T_meas_max/min   from sensor blocks
%            derate_active, I_ch_max_in, I_dis_max_in from bms_limits_sl
%            mode_prev    Memory (init: 0 = INIT)
%            fault_prev   Memory (init: 0)
%            dwell_prev   Memory (init: 0)
%            latch_prev   Memory (init: 0)
%            Tlim_prev    Memory (init: 0)
%            dt_h         Constant
%   outputs: mode, I_ch_max, I_dis_max (GATED: 0 in FAULT — wire THESE to
%            dispatch, not the raw limits), fault_code, plus five state
%            scalars back to their Memory blocks
%
% Core logic: bms_mode.m.

cfg = bms_config();

mode_state = struct('mode', mode_prev, 'fault_code', fault_prev, ...
                    'dwell_h', dwell_prev, 'uv_latched', latch_prev, ...
                    'fault_T_limit', Tlim_prev);

[mode, I_ch_max, I_dis_max, fault_code, mode_state] = bms_mode(I_meas, ...
    V_meas_max, V_meas_min, T_meas_max, T_meas_min, derate_active, ...
    I_ch_max_in, I_dis_max_in, mode_state, cfg, dt_h);

mode_out  = mode_state.mode;
fault_out = mode_state.fault_code;
dwell_out = mode_state.dwell_h;
latch_out = mode_state.uv_latched;
Tlim_out  = mode_state.fault_T_limit;
end
