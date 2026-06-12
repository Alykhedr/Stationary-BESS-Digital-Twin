function [y_meas, y_lag_out, seed_out] = bms_sensor_model_sl(y_true, y_lag_prev, seed_prev, channel, bias, gain_err, dt_h)
% BMS_SENSOR_MODEL_SL  Simulink wrapper for one sensor channel. Scalar ports.
%
% Block wiring:
%   inputs : y_true        from plant
%            y_lag_prev    Memory block (init: 0, or plant value at t0)
%            seed_prev     Memory block (init: nseedV/I/T from bms_init draw,
%                          stored as workspace scalars by Workspace_set)
%            channel       Constant: 1 = V, 2 = I, 3 = T  (selects noise/
%                          quant/lag settings from bms_config)
%            bias          Constant wired to workspace scalar (b_V/b_I/b_T,
%                          drawn once by bms_init -> Workspace_set)
%            gain_err      Constant (g_I for current channel, 0 otherwise)
%            dt_h          Constant / workspace var
%   outputs: y_meas, plus the two state scalars back to their Memory blocks
%
% One block instance per channel (3 total). Core logic: bms_sensor_model.m.

cfg = bms_config();

if channel == 1          % voltage
    noise_sig = cfg.sens.V_noise_sigma; quant = cfg.sens.V_quant; lag = 0;
elseif channel == 2      % current
    noise_sig = cfg.sens.I_noise_sigma; quant = 0;                lag = 0;
else                     % temperature
    noise_sig = cfg.sens.T_noise_sigma; quant = 0;                lag = cfg.sens.T_lag_tau_h;
end

st = struct('bias', bias, 'gain_err', gain_err, 'noise_sig', noise_sig, ...
            'quant', quant, 'lag_tau_h', lag, 'y_lag', y_lag_prev, ...
            'noise_seed', seed_prev);

[y_meas, st] = bms_sensor_model(y_true, st, dt_h);

y_lag_out = st.y_lag;
seed_out  = st.noise_seed;
end
