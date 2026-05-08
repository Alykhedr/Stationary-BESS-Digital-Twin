function [Qcyc, dQcyc] = cycle_aging(SOC, Ich, Idis, dt_h, T_degC, Q_nom, ...
    kT, Tref_K, kDODc, kcyc, kCch, kCdch, kmSOC, mSOCref, a_montes)

persistent dir soc_ext seg_dt_ch seg_Ah_ch seg_dt_dis seg_Ah_dis seg_Ah_abs Cfcyc_total_pp

if isempty(dir)
    dir = 0; soc_ext = -999;
    seg_dt_ch = 0; seg_Ah_ch = 0;
    seg_dt_dis = 0; seg_Ah_dis = 0;
    seg_Ah_abs = 0; Cfcyc_total_pp = 0;
end

Qcyc  = Cfcyc_total_pp;
dQcyc = 0;

T_K    = T_degC + 273.15;
fT_cyc = exp(kT * (T_K - Tref_K) / T_K);

is_rest = (Ich == 0) && (Idis == 0);

seg_Ah_abs = seg_Ah_abs + (Idis + Ich) * dt_h;
if Idis > 0
    seg_dt_dis = seg_dt_dis + dt_h;
    seg_Ah_dis = seg_Ah_dis + Idis * dt_h;
elseif Ich > 0
    seg_dt_ch = seg_dt_ch + dt_h;
    seg_Ah_ch = seg_Ah_ch + Ich * dt_h;
end

if soc_ext < -998
    soc_ext = SOC;
    return
end

dSOC   = SOC - soc_ext;
newdir = sign(dSOC);

close_cycle = (newdir ~= 0 && newdir ~= dir) || ...
              (is_rest && dir ~= 0 && seg_Ah_abs > 0);

if ~close_cycle
    if newdir ~= 0, dir = newdir; end
    return
end

Sa     = soc_ext;
Sb     = SOC;
DOD_i  = abs(Sb - Sa);
mSOC_i = 0.5*(Sa + Sb);

Cdis_i = 0; if seg_dt_dis > 0, Cdis_i = (seg_Ah_dis/seg_dt_dis)/Q_nom; end
Cch_i  = 0; if seg_dt_ch  > 0, Cch_i  = (seg_Ah_ch /seg_dt_ch )/Q_nom; end

dFEC_i = seg_Ah_abs / (2*Q_nom);
fD     = exp(kDODc * DOD_i * 100);

delta_i = kcyc * fT_cyc * fD * exp(kCch*Cch_i) * exp(kCdch*Cdis_i) ...
        * (1 + kmSOC*mSOC_i*((1-mSOC_i)/(2*mSOCref)));

Fvirt_prev     = (max(Cfcyc_total_pp,0)/max(delta_i,eps))^(1/a_montes);
dQcyc          = delta_i*((Fvirt_prev+dFEC_i)^a_montes - Fvirt_prev^a_montes);
dQcyc          = max(dQcyc, 0);
Cfcyc_total_pp = Cfcyc_total_pp + dQcyc;

% reset
if is_rest
    dir = 0;
else
    dir = newdir;
end
soc_ext = SOC;
seg_dt_ch=0; seg_Ah_ch=0; seg_dt_dis=0; seg_Ah_dis=0; seg_Ah_abs=0;

Qcyc = Cfcyc_total_pp;
end