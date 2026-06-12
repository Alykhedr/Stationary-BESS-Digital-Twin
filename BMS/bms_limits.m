function [I_ch_max, I_dis_max, derate_active] = bms_limits(V_meas_max, V_meas_min, T_meas_max, T_meas_min, SOC_est, Q_est, R_ch, R_dis, cfg, dt_h)
% BMS_LIMITS  Dynamic State-of-Power limits (stateless, pure math).
%
% Each limit is the minimum of independent constraint curves:
%   voltage headroom | temperature derate | SOC window | hardware continuous
%
% AMENDMENT (STATUS.md #2): charge headroom uses V_max_warn (3.55 V),
% NOT V_max_protect (3.60 V) — otherwise the limiter steers the cell
% right up to the fault threshold and noise latches FAULT.
%
% Protection inputs V_meas/T_meas are RAW measurements, not estimates —
% deliberate: the safety path must not depend on estimator health.
% Worst-cell aggregation (max/min over blocks) happens at the caller at
% pack phase; the equations here are unchanged.
%
% Inputs:
%   V_meas_max/min   worst-cell measured voltages [V] (scalar = single cell)
%   T_meas_max/min   worst-cell measured temperatures [degC]
%   SOC_est, Q_est   from estimation layer (window constraint only)
%   R_ch, R_dis      resistance estimates [Ohm] (from bms_r_estimator)
%   cfg, dt_h
%
% Outputs:
%   I_ch_max, I_dis_max   dynamic limits [A], >= 0; FAULT zeroing is done
%                         by bms_mode downstream, not here
%   derate_active         true if any derate factor < 1 (DERATE mode label)
%
% Stateless. NO persistent. NO truth signals.

% =====================================================================
% CHARGE
% =====================================================================
I_ch_volt = (cfg.cell.V_max_warn - V_meas_max) / max(R_ch, 1e-4);
f_T_chg   = derate_ramp(T_meas_min, cfg.cell.T_chg_min, cfg.cell.T_warn_band, true) ...
          * derate_ramp(T_meas_max, cfg.cell.T_chg_max, cfg.cell.T_warn_band, false);
I_ch_temp = f_T_chg * cfg.cell.I_chg_max_cont;
I_ch_soc  = max(0, (cfg.soc.window_max - SOC_est)) * Q_est / dt_h;

I_ch_max  = max(0, min([I_ch_volt, I_ch_temp, I_ch_soc, cfg.cell.I_chg_max_cont]));

% =====================================================================
% DISCHARGE (symmetric)
% =====================================================================
I_dis_volt = (V_meas_min - cfg.cell.V_min_warn) / max(R_dis, 1e-4);
f_T_dis    = derate_ramp(T_meas_min, cfg.cell.T_dis_min, cfg.cell.T_warn_band, true) ...
           * derate_ramp(T_meas_max, cfg.cell.T_dis_max, cfg.cell.T_warn_band, false);
I_dis_temp = f_T_dis * cfg.cell.I_dis_max_cont;
I_dis_soc  = max(0, (SOC_est - cfg.soc.window_min)) * Q_est / dt_h;

I_dis_max  = max(0, min([I_dis_volt, I_dis_temp, I_dis_soc, cfg.cell.I_dis_max_cont]));

% =====================================================================
% DERATE flag (mode label only; bms_mode consumes it)
% Temperature ramps ONLY. Voltage-headroom taper is normal CV-like
% behavior near the SOC extremes (it binds on nearly every discharge
% tick vs the 20 A hardware max) and must not label the mode DERATE.
% =====================================================================
derate_active = (f_T_chg < 1) || (f_T_dis < 1);
end

function f = derate_ramp(T, T_limit, band, is_lower)
% Piecewise-linear derate factor in [0,1].
% is_lower=true : f=0 at/below T_limit, ramps to 1 at T_limit+band
% is_lower=false: f=1 up to T_limit-band, ramps to 0 at/above T_limit
if is_lower
    f = min(max((T - T_limit) / band, 0), 1);
else
    f = min(max((T_limit - T) / band, 0), 1);
end
end
