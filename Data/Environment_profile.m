dt_h  = 1;
[~, Ppv, Pload] = load_profile_bess(V_nom, Q_nom);

temperature  = readTemperature();
n_years = 10;
temperature = repmat(temperature,   n_years, 1);
Ppv   = repmat(Ppv,   n_years, 1);
Pload = repmat(Pload, n_years, 1);

Ppv_ws.time               = (0:n_years*8760-1)';
Ppv_ws.signals.values     = Ppv;
Ppv_ws.signals.dimensions = 1;

Pload_ws.time               = (0:n_years*8760-1)';
Pload_ws.signals.values     = Pload;
Pload_ws.signals.dimensions = 1;

temperature_ws.time               = (0:n_years*8760-1)';
temperature_ws.signals.values     = temperature;
temperature_ws.signals.dimensions = 1;

dt_s  = dt_h * 3600;

clear temperature Ppv Pload 
