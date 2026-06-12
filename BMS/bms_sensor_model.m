function [y_meas, sens_state] = bms_sensor_model(y_true, sens_state, dt_h)
% BMS_SENSOR_MODEL  Generic 1D measurement-chain model (bias/gain/noise/quant/lag).
%
% One function, instantiated three times (V, I, T) with different state
% structs. NO persistent variables — all state passes through sens_state
% (Simulink: wire through a Memory block with a Bus object).
%
%   y_meas = quantize( lag( (1+gain_err)*y_true + bias + noise ), q )
%
% Inputs:
%   y_true      true signal from plant [unit of channel]
%   sens_state  struct (created by bms_init), fields:
%                 .bias       frozen offset, drawn once at init [unit]
%                 .gain_err   frozen relative gain error [-] (0 for V/T)
%                 .noise_sig  noise 1-sigma [unit] (0 disables)
%                 .quant      quantization LSB [unit] (0 disables)
%                 .lag_tau_h  first-order lag time constant [h] (0 disables)
%                 .y_lag      lag filter state [unit]
%                 .noise_seed running RNG state (scalar uint32-like double)
%   dt_h        timestep [h] — NEVER hard-coded (dual-rate contexts)
%
% Outputs:
%   y_meas      corrupted measurement
%   sens_state  updated state (lag state + RNG state advanced)
%
% Noise uses a tiny embedded LCG so results are reproducible from the seed
% and identical in Simulink codegen and offline harness (randn is not
% codegen-deterministic across contexts).

% --- systematic errors: gain then offset ---
y = (1 + sens_state.gain_err) * y_true + sens_state.bias;

% --- noise (Box-Muller from two LCG draws), reproducible & codegen-safe ---
if sens_state.noise_sig > 0
    [u1, s1] = lcg_next(sens_state.noise_seed);
    [u2, s2] = lcg_next(s1);
    sens_state.noise_seed = s2;
    n = sqrt(-2*log(max(u1, 1e-12))) * cos(2*pi*u2);
    y = y + sens_state.noise_sig * n;
end

% --- first-order lag (exact discrete update, stable for any dt_h) ---
if sens_state.lag_tau_h > 0
    a = exp(-dt_h / sens_state.lag_tau_h);
    sens_state.y_lag = a * sens_state.y_lag + (1 - a) * y;
    y = sens_state.y_lag;
else
    sens_state.y_lag = y;   % keep state defined either way
end

% --- quantization ---
if sens_state.quant > 0
    y = round(y / sens_state.quant) * sens_state.quant;
end

y_meas = y;
end

function [u, s] = lcg_next(s)
% Park-Miller minimal standard LCG. State s in (0, 2^31-1).
s = mod(16807 * s, 2147483647);
u = s / 2147483647;
end
