function [SOH_est, Q_est, soh_state] = bms_soh_estimator(SOC_est, corrected, I_meas, soh_state, cfg, dt_h)
% BMS_SOH_ESTIMATOR  Anchor-pair capacity bookkeeping.
%
% Capacity is re-estimated when two OCV-snap anchor events bracket a large
% SOC swing:
%   Q_new = dAh_counted / (SOC_anchor2 - SOC_anchor1),  |dSOC| >= 0.5
%   Q_est <- ff*Q_est + (1-ff)*Q_new        (forgetting factor, bad-anchor guard)
%   SOH_est = Q_est / Q_nom
%
% Inputs:
%   SOC_est     current SOC estimate [-]
%   corrected   true on OCV-snap ticks (from bms_soc_estimator)
%   I_meas      measured current [A]
%   soh_state   state struct (from bms_init), fields:
%                 .Q_est        capacity estimate [Ah]
%                 .Ah_acc       coulombs counted since last anchor [Ah]
%                 .anchor_soc   SOC at last anchor [-]
%                 .has_anchor   0/1 - an anchor exists
%   cfg, dt_h
%
% Outputs:
%   SOH_est     Q_est / Q_nom [-]
%   Q_est       capacity estimate [Ah] (feeds back into bms_soc_estimator)
%   soh_state   updated state
%
% NO persistent. NO truth signals.

% --- accumulate measured throughput every tick ---
soh_state.Ah_acc = soh_state.Ah_acc + cfg.est.eta_coulombic * I_meas * dt_h;

% --- anchor handling on snap events ---
if corrected
    if soh_state.has_anchor
        dsoc = SOC_est - soh_state.anchor_soc;
        if abs(dsoc) >= cfg.soh.min_anchor_span
            Q_new = soh_state.Ah_acc / dsoc;          % signed/signed -> positive
            if Q_new > 0.5 * cfg.cell.Q_nom && Q_new < 1.5 * cfg.cell.Q_nom
                ff = cfg.soh.forget_factor;
                soh_state.Q_est = ff * soh_state.Q_est + (1 - ff) * Q_new;
            end
            % wide-span pair consumed -> new bookkeeping segment either way
        end
    end
    % every snap re-anchors and resets the coulomb ledger
    soh_state.anchor_soc = SOC_est;
    soh_state.Ah_acc     = 0;
    soh_state.has_anchor = 1;
end

Q_est   = soh_state.Q_est;
SOH_est = soh_state.Q_est / cfg.cell.Q_nom;
end
