function [R_ch, R_dis, r_state] = bms_r_estimator(V_meas, I_meas, r_state, cfg)
% BMS_R_ESTIMATOR  Internal resistance from current-step response.
%
% On each tick where the current steps by more than dI_min_step:
%   R_new = dV / dI
% Low-pass blended per direction (sign of the NEW current decides the
% direction bin). Initialized to nominal values at init so bms_limits
% never receives garbage.
%
% Inputs:
%   V_meas, I_meas  measurements at this tick
%   r_state         state struct (from bms_init), fields:
%                     .V_prev, .I_prev   previous tick measurements
%                     .R_ch, .R_dis      filtered estimates [Ohm]
%   cfg
%
% Outputs:
%   R_ch, R_dis     filtered resistance estimates [Ohm]
%   r_state         updated state
%
% NO persistent. NO truth signals (R_i from the plant is firewalled).

dI = I_meas - r_state.I_prev;
dV = V_meas - r_state.V_prev;

if abs(dI) > cfg.rest.dI_min_step
    R_new = dV / dI;
    % plausibility window: 0.2x..5x of the nominal band
    if R_new > 0.2 * cfg.rest.R_nominal_ch && R_new < 5 * cfg.rest.R_nominal_dis
        a = cfg.rest.lp_alpha;
        if I_meas >= 0
            r_state.R_ch  = (1 - a) * r_state.R_ch  + a * R_new;
        else
            r_state.R_dis = (1 - a) * r_state.R_dis + a * R_new;
        end
    end
end

r_state.V_prev = V_meas;
r_state.I_prev = I_meas;
R_ch  = r_state.R_ch;
R_dis = r_state.R_dis;
end
