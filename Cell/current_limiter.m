function [Ich, Idis, P_bess] = current_limiter(Ppv, Pload, SOC, V_nom, ...
    I_ch_max, I_dis_max, SOC_min, SOC_max, dt_h, eta_ch, eta_dis,Q_nom,V_terminal)

I_req = (Pload - Ppv) / V_terminal;

I_req = min(max(I_req, -I_ch_max), I_dis_max);

I_ch_lim  = (SOC_max - SOC) * Q_nom / dt_h;
I_dis_lim = (SOC - SOC_min) * Q_nom / dt_h;

I_req = min(max(I_req, -I_ch_lim), I_dis_lim);

Ich  = max(-I_req, 0);
Idis = max( I_req, 0);

P_bess = V_terminal * Idis * eta_dis - V_terminal * Ich / eta_ch;
end