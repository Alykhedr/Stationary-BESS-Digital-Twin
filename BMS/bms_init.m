function states = bms_init(cfg, V_meas_t0, ocv_SOC, ocv_V, hys_SOC, hys_V, regen_seed)
% BMS_INIT  Build all BMS state structs; draw frozen sensor biases (seeded).
%
% Runs ONCE offline (from Workspace_set.m / main.m) before sim() — not
% inside a function block. The returned structs initialize the Memory/Bus
% wiring in the .slx and the offline harness alike.
%
% Inputs:
%   cfg          from bms_config()
%   V_meas_t0    terminal voltage at t=0 (battery at rest) — seeds SOC_est
%                via OCV inversion; pass NaN to default-seed at 0.5
%   ocv_*/hys_*  shared tables from Data/ocv_table.mat
%   regen_seed   (optional) true = redraw biases and overwrite
%                Data/bms_scatter_seed.mat; default false = reuse persisted
%                draws for reproducibility
%
% Output: states struct with fields
%   .sens_V, .sens_I, .sens_T   sensor states (bias/gain/noise/quant/lag)
%   .est                        SOC estimator state
%   .soh                        SOH estimator state
%   .r                          resistance estimator state
%   .mode                       mode machine state

if nargin < 7, regen_seed = false; end
seed_file = fullfile(fileparts(mfilename('fullpath')), '..', 'Data', 'bms_scatter_seed.mat');

% --- frozen bias draws (persisted for reproducibility across sessions) ---
if exist(seed_file, 'file') && ~regen_seed
    d = load(seed_file);
    draws = d.draws;
else
    rng(cfg.sens.rng_seed, 'twister');
    draws.b_V    = (2*rand - 1) * cfg.sens.V_bias_max;
    draws.b_I    = (2*rand - 1) * cfg.sens.I_bias_max;
    draws.g_I    = (2*rand - 1) * cfg.sens.I_gain_err_max;
    draws.b_T    = (2*rand - 1) * cfg.sens.T_bias_max;
    draws.nseedV = floor(rand * 2^30) + 1;
    draws.nseedI = floor(rand * 2^30) + 1;
    draws.nseedT = floor(rand * 2^30) + 1;
    save(seed_file, 'draws');
end

% --- sensor states ---
states.sens_V = struct('bias', draws.b_V, 'gain_err', 0, ...
    'noise_sig', cfg.sens.V_noise_sigma, 'quant', cfg.sens.V_quant, ...
    'lag_tau_h', 0, 'y_lag', 0, 'noise_seed', draws.nseedV);

states.sens_I = struct('bias', draws.b_I, 'gain_err', draws.g_I, ...
    'noise_sig', cfg.sens.I_noise_sigma, 'quant', 0, ...
    'lag_tau_h', 0, 'y_lag', 0, 'noise_seed', draws.nseedI);

states.sens_T = struct('bias', draws.b_T, 'gain_err', 0, ...
    'noise_sig', cfg.sens.T_noise_sigma, 'quant', 0, ...
    'lag_tau_h', cfg.sens.T_lag_tau_h, 'y_lag', 0, 'noise_seed', draws.nseedT);

% --- SOC seed from OCV at rest (INIT-state job) ---
if isnan(V_meas_t0)
    soc0 = 0.5;
else
    % no zone restriction at init: a coarse seed beats no seed; the first
    % steep-zone rest will correct it
    V0 = min(max(V_meas_t0, ocv_V(1)), ocv_V(end));
    soc0 = interp1(ocv_V, ocv_SOC, V0, 'linear');
end

states.est  = struct('SOC', soc0, 't_rest_h', 0, 'I_last_sign', 0);
states.soh  = struct('Q_est', cfg.cell.Q_nom, 'Ah_acc', 0, 'anchor_soc', 0, 'has_anchor', 0);
states.r    = struct('V_prev', V_meas_t0, 'I_prev', 0, ...
                     'R_ch', cfg.rest.R_nominal_ch, 'R_dis', cfg.rest.R_nominal_dis);
states.mode = struct('mode', cfg.mode.INIT, 'fault_code', 0, 'dwell_h', 0, ...
                     'uv_latched', 0, 'fault_T_limit', 0);
end
