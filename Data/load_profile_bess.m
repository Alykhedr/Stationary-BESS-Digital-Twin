function [time, Ppv, Pload] = load_profile_bess(V_nom, Q_nom)

nhours = 8760;
infile = 'DE_2018Apr_2020Jan_60min.csv';

opts = detectImportOptions(infile, 'NumHeaderLines', 0);
opts = setvaropts(opts, 'utc_timestamp', 'Type', 'char');
T    = readtable(infile, opts);

ts   = string(T.utc_timestamp);
time = datetime(ts, 'InputFormat', "yyyy-MM-dd'T'HH:mm:ss'Z'", 'TimeZone', 'UTC');
time = time(1:nhours);

load_DE = fillmissing(T.DE_load_actual_entsoe_transparency, 'linear', 'MaxGap', 6);
gen_pv  = fillmissing(T.DE_solar_generation_actual,         'linear', 'MaxGap', 6);

load_DE = load_DE(1:nhours);
gen_pv  = gen_pv(1:nhours);

% Normalize load mean to PV mean for balance
mean_pv = mean(gen_pv);
load_DE = load_DE / mean(load_DE) * mean_pv;
load_DE(load_DE < 0) = 0;

% Scale so peak PV = 1C power (V_nom * Q_nom)
P_1C  = V_nom * Q_nom;   % 9.6 W
scale = max(gen_pv);      % peak PV in MW

Ppv   = gen_pv  / scale * P_1C;   % W, peak = 1C
Pload = load_DE / scale * P_1C;   % W, scaled same
end