function cfg = bms_config()
% BMS_CONFIG  Single source of truth for all BMS thresholds and parameters.
%
% Frozen at M0 — do not edit without agreement from both owners.
% ALL fields are numeric (scalars, vectors, or nested structs of numerics)
% so the struct can be attached to MATLAB Function blocks as a Parameter.
% No strings, no cells, no function handles.
%
% Sources: Sony US26650FTC1 datasheet; Schimpe (2018) TUM dissertation;
% Schimpe et al., Applied Energy 210 (2018) Table 3.

% =====================================================================
% Cell hard limits and derating knees
% =====================================================================
cfg.cell.Q_nom            = 3.0;     % [Ah] nominal capacity (1C = 3.0 A)

cfg.cell.V_max_protect    = 3.60;    % [V] datasheet charge limit -> FAULT
cfg.cell.V_max_warn       = 3.55;    % [V] derating knee; charge headroom
                                     %     computed against THIS, not protect
cfg.cell.V_min_protect    = 2.00;    % [V] datasheet discharge limit -> FAULT
cfg.cell.V_min_warn       = 2.50;    % [V] derating knee (Schimpe PE binds at
                                     %     2.88 V system-level; PE limit first)
cfg.cell.V_reconnect_hi   = 3.45;    % [V] hysteresis release after OV fault
cfg.cell.V_reconnect_lo   = 2.80;    % [V] hysteresis release after UV fault

cfg.cell.T_chg_min        = -1;      % [degC] no charge below (datasheet)
cfg.cell.T_chg_max        = 46;      % [degC]
cfg.cell.T_dis_min        = -20;     % [degC]
cfg.cell.T_dis_max        = 60;      % [degC]
cfg.cell.T_warn_band      =  5;      % [degC] derate ramp width inside limits
cfg.cell.T_fault_hyst     =  3;      % [degC] recovery hysteresis

cfg.cell.I_chg_max_cont   = 3.0;     % [A] 1C continuous (datasheet)
cfg.cell.I_dis_max_cont   = 20.0;    % [A] datasheet (PE limits lower)

% =====================================================================
% SOC windows
% =====================================================================
cfg.soc.window_min        = 0.05;    % [-] operational window (dispatch)
cfg.soc.window_max        = 0.95;    % [-]
cfg.soc.protect_min       = 0.02;    % [-] ~ Schimpe PE-driven min SOC 1.8 %
cfg.soc.protect_max       = 0.98;    % [-]
% NOTE: SOC_est is NOT a FAULT trigger (safety path must not depend on
% estimator health). protect_* feed derating/warning only; voltage
% protection covers true over/under-charge.

% =====================================================================
% Sensor models (biases drawn once at init, frozen; see bms_init)
% =====================================================================
cfg.sens.V_bias_max       = 2e-3;    % [V]    uniform +/- draw
cfg.sens.V_noise_sigma    = 0.5e-3;  % [V]    1-sigma
cfg.sens.V_quant          = 0.1e-3;  % [V]    LSB (16-bit class AFE)

cfg.sens.I_bias_max       = 10e-3;   % [A]    DOMINANT coulomb-count killer
cfg.sens.I_gain_err_max   = 0.005;   % [-]    +/-0.5 % shunt+amp tolerance
cfg.sens.I_noise_sigma    = 5e-3;    % [A]    1-sigma

cfg.sens.T_bias_max       = 1.0;     % [degC] NTC + divider tolerance
cfg.sens.T_noise_sigma    = 0.2;     % [degC] 1-sigma
cfg.sens.T_lag_tau_h      = 30/3600; % [h]    first-order lag (30 s)

cfg.sens.rng_seed         = 42;      % [-]    reproducible bias draws

% =====================================================================
% SOC estimator (coulomb counting + OCV-snap correction)
% =====================================================================
cfg.est.ocv_corr_zones    = [0.00 0.10; 0.90 1.00];  % [-] LFP steep zones;
                                                     %    correction forbidden
                                                     %    on the flat plateau
cfg.est.rest_current_thr  = 0.015;   % [A] ~C/200, "at rest" detection
cfg.est.rest_time_min     = 2;       % [h] min rest before OCV snap allowed
% lambda ramp policy: lambda = min(1, (t_rest - rest_time_min)/rest_time_min)
% (full reset reached at 2x rest_time_min; encoded in bms_soc_estimator)
cfg.est.s_rate_nom_per_h  = 5.6e-6;  % [1/h] self-discharge at 25 degC ONLY
                                     %       (intentional mismatch vs plant's
                                     %        T-dependent truth)
cfg.est.eta_coulombic     = 1.0;     % [-] Schimpe assumption

% =====================================================================
% SOH estimator (anchor-pair capacity bookkeeping)
% =====================================================================
cfg.soh.min_anchor_span   = 0.5;     % [-] |SOC_a2 - SOC_a1| required
cfg.soh.forget_factor     = 0.9;     % [-] Q_est <- ff*Q_prev + (1-ff)*Q_new

% =====================================================================
% Resistance estimator
% =====================================================================
cfg.rest.dI_min_step      = 0.5;     % [A] min current step for dV/dI estimate
cfg.rest.lp_alpha         = 0.1;     % [-] low-pass blend for new estimates
cfg.rest.R_nominal_ch     = 43e-3;   % [Ohm] init value -> limits never get garbage
cfg.rest.R_nominal_dis    = 50e-3;   % [Ohm]

% =====================================================================
% Mode state machine (int enum -- Simulink bus compatible)
% =====================================================================
cfg.mode.INIT             = 0;
cfg.mode.STANDBY          = 1;
cfg.mode.CHARGE           = 2;
cfg.mode.DISCHARGE        = 3;
cfg.mode.DERATE           = 4;
cfg.mode.FAULT            = 5;
cfg.mode.I_idle_thr       = 0.015;   % [A] STANDBY <-> CHARGE/DISCHARGE
cfg.mode.fault_dwell_min  = 1;       % [ticks] min dwell before FAULT release

% =====================================================================
% Balancing (dissipative, per Schimpe; live at pack phase / Sprint 2)
% =====================================================================
cfg.bal.V_threshold       = 5e-3;    % [V] balance if V > min(V) + threshold
cfg.bal.R_bleed           = 33;      % [Ohm] ~100 mA bleed at 3.3 V
cfg.bal.enable_modes      = [2 1];   % [enum] CHARGE, STANDBY (numeric --
                                     %        strings not Simulink-Parameter-safe)

% =====================================================================
% Auxiliary power accounting (Schimpe Applied Energy 210, Table 3)
% =====================================================================
cfg.aux.P_slave_W         = 2.76;    % [W] per module (287 W / 104 modules)
cfg.aux.P_master_W        = 81;      % [W] system-level C&M share
end
