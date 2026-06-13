function [mode, I_ch_max_out, I_dis_max_out, fault_code, mode_state] = bms_mode(I_meas, V_meas_max, V_meas_min, T_meas_max, T_meas_min, derate_active, I_ch_max_in, I_dis_max_in, mode_state, cfg, dt_h)
% BMS_MODE  Protection state machine (plain MATLAB function, int enums).
%
% States (cfg.mode.*): INIT=0 STANDBY=1 CHARGE=2 DISCHARGE=3 DERATE=4 FAULT=5
%
% This function also gates the limits: in FAULT both outputs are zeroed, so
% downstream dispatch needs no special-casing (request clamps to 0 -> I = 0).
%
% FAULT conditions (RAW measurements only — never SOC_est, see STATUS.md
% amendment #1):
%   OV: V_meas_max >= V_max_protect
%   UV: V_meas_min <= V_min_protect
%   OT/UT: T outside the protect range of the ACTIVE direction
% Recovery (hysteresis + min dwell):
%   OV -> V_meas_max <= V_reconnect_hi
%   UV -> V_meas_min >= V_reconnect_lo
%   T  -> back inside limit by T_fault_hyst
%   Exception: UV entered at low temperature stays LATCHED (operator flag)
%
% Inputs:
%   I_meas                  measured string current [A]
%   V_meas_max/min          worst-cell voltages [V]
%   T_meas_max/min          worst-cell temperatures [degC]
%   derate_active           from bms_limits
%   I_ch_max_in/I_dis_max_in  limits from bms_limits [A]
%   mode_state              state struct (from bms_init), fields:
%                             .mode        current mode enum
%                             .fault_code  0 none, 1 OV, 2 UV, 3 OT, 4 UT
%                             .dwell_h     time in FAULT [h]
%                             .uv_latched  0/1 UV-at-low-T latch
%   cfg, dt_h
%
% NO persistent. NO truth signals. NO SOC in fault logic.

m = mode_state.mode;

% --- direction of activity (for T-protect range selection) ---
charging    = I_meas >  cfg.mode.I_idle_thr;
discharging = I_meas < -cfg.mode.I_idle_thr;

% --- active thermal-protect envelope -------------------------------------
% A2 fix: temperature is checked in EVERY state, including idle. When
% charging, the tighter charge range applies (no charge below 0 degC); when
% discharging OR idle, the widest (discharge) range is the absolute safety
% bound — so an idle cell that is genuinely too hot/cold still faults.
if charging
    T_hi = cfg.cell.T_chg_max;   T_lo = cfg.cell.T_chg_min;
else
    T_hi = cfg.cell.T_dis_max;   T_lo = cfg.cell.T_dis_min;
end

% =====================================================================
% FAULT detection (evaluated every tick, every state)
% =====================================================================
new_fault = 0;
if V_meas_max >= cfg.cell.V_max_protect
    new_fault = 1;                                          % OV
elseif V_meas_min <= cfg.cell.V_min_protect
    new_fault = 2;                                          % UV
elseif T_meas_max >= T_hi
    new_fault = 3;                                          % OT
elseif T_meas_min <= T_lo
    new_fault = 4;                                          % UT
end

entered_fault = false;
if m ~= cfg.mode.FAULT && new_fault > 0
    m = cfg.mode.FAULT;
    entered_fault = true;
    mode_state.fault_code = new_fault;
    mode_state.dwell_h = 0;
    % remember WHICH limit was violated, so recovery checks the right one
    % (a charge fault at 0 degC must not "recover" against the -20 degC
    %  discharge limit)
    if new_fault == 3
        mode_state.fault_T_limit = T_hi;   % store the limit that tripped so
    elseif new_fault == 4                  % recovery checks the right one
        mode_state.fault_T_limit = T_lo;
    else
        mode_state.fault_T_limit = 0;
    end
    % UV entered at low temperature -> latch (plausible plating, no auto-recover)
    if new_fault == 2 && T_meas_min < cfg.cell.T_chg_min + cfg.cell.T_warn_band
        mode_state.uv_latched = 1;
    end
end

% =====================================================================
% State transitions
% =====================================================================
switch m
    case cfg.mode.INIT
        m = cfg.mode.STANDBY;   % SOC seeding happens in bms_init / first tick

    case cfg.mode.FAULT
        if ~entered_fault
            mode_state.dwell_h = mode_state.dwell_h + dt_h;
            % A1 fix: never release while ANY fault condition is currently
            % live (new_fault > 0), not only when the latched fault's recovery
            % band is met — guards against releasing straight into a different
            % active fault.
            can_release = mode_state.dwell_h >= cfg.mode.fault_dwell_min * dt_h ...
                          && ~mode_state.uv_latched ...
                          && new_fault == 0;
            if can_release
                fc = mode_state.fault_code;
                released = false;
                if fc == 1 && V_meas_max <= cfg.cell.V_reconnect_hi
                    released = true;
                elseif fc == 2 && V_meas_min >= cfg.cell.V_reconnect_lo
                    released = true;
                elseif fc == 3 && T_meas_max <= mode_state.fault_T_limit - cfg.cell.T_fault_hyst
                    released = true;
                elseif fc == 4 && T_meas_min >= mode_state.fault_T_limit + cfg.cell.T_fault_hyst
                    released = true;
                end
                if released
                    m = cfg.mode.STANDBY;
                    mode_state.fault_code = 0;
                    mode_state.dwell_h = 0;
                end
            end
        end

    otherwise   % STANDBY / CHARGE / DISCHARGE / DERATE
        if charging
            m = cfg.mode.CHARGE;
        elseif discharging
            m = cfg.mode.DISCHARGE;
        else
            m = cfg.mode.STANDBY;
        end
        % DERATE is a label on top of an active direction
        if derate_active && m ~= cfg.mode.STANDBY
            m = cfg.mode.DERATE;
        end
end

mode_state.mode = m;
mode = m;
fault_code = mode_state.fault_code;

% =====================================================================
% Limit gating
% =====================================================================
if m == cfg.mode.FAULT
    I_ch_max_out  = 0;
    I_dis_max_out = 0;
else
    I_ch_max_out  = I_ch_max_in;
    I_dis_max_out = I_dis_max_in;
end
end
