function p = params(model)
% PARAMS  Parameter set with per-model gating: 'B1' | 'B2' | 'B3'

% normalize tag
if isa(model,'string'); model = char(model); end
model = upper(strtrim(model));
p.meta.model = model;

% -------- Cell (Sony LFP US26650FTC1) --------
p.cell.V_nom     = 3.20;   % V
p.cell.Q_nom     = 3.00;   % Ah


% Efficiencies
p.eta_ch  = 0.98;
p.eta_dis = 0.98;

% SOC window & initial SOC
p.SOC_min = 0.05; 
p.SOC_max = 0.95; 
p.SOC0    = 0.50;

% Environment (ambient for now)
p.T_degC  = 25;
p.R_gas   = 8.314462618;   % J/mol/K
p.F       = 96485;         % C/mol

% -------- Gating by model --------
switch model
    case 'B1'
        p.modes.do_cycle        = false;
        p.modes.do_calendar     = false;
    case 'B2'
        p.modes.do_cycle        = true;
        p.modes.do_calendar     = false;
    case 'B3'
        p.modes.do_cycle        = true;
        p.modes.do_calendar     = true;
    otherwise
        error('Unknown model "%s". Use B1 | B2 | B3.', model);
end

% -------- Montes cycle-aging (LFP) --------
p.kcyc     = 0.003414;
p.Tref_K   = 298.0;
p.kT       = 5.8755;
p.kDODc    = 0.0046;      % DOD in PERCENT
p.kCch     = 0.1038;
p.kCdch    = 0.296;
p.kmSOC    = 0.0513;
p.a_montes = 0.869;
p.mSOCref  = 0.42;        % 42% → 0.42


% Cycle-aging reference coefficients (per Table IV)
p.deg.kcyc_highT_ref_Ah_m05      = 1.46e-4;  % Ah^(-0.5),  T=25°C, I = 1C
p.deg.kcyc_lowT_ref_Ah_m05       = 4.01e-4;  % Ah^(-0.5),  T=25°C, Ich = 1C
p.deg.kcyc_lowT_highSOC_ref_Ah_m1= 2.031e-6;  % Ah^(-1),    T=25°C, Ich = 1C

% Cycle-aging activation energies
p.deg.Ea_cyc_highT_Jmol                  = 3.27e4;   % J/mol   (I = 1C)
p.deg.Ea_cyc_lowT_Jmol                   = 5.55e4;   % J/mol   (Ich = 1C)
p.deg.Ea_cyc_lowT_highSOC_Jmol   = 2.33e5;   % J/mol   (Ich = 1C)

% Beta time constants used by Naumann’s low-T terms
p.deg.beta_lowT_h                        = 2.64;     % h
p.deg.beta_lowT_highSOC_h        = 7.84;     % h

% Reference charge current (for terms defined with Ich,Ref)
p.deg.Ich_ref_A      = 3.0;                 % A
p.deg.SOCref         = 0.82;

% -------- SOH floor --------
p.deg.SOH_min = 0.50;

% -------- Calendar aging (Naumann/Schimpe) --------
p.deg.kcal_ref    = 3.694e-4; % h^(-0.5) at 25°C & ~50% SOC
p.deg.Ea_cal_Jmol = 20592;    % J/mol
p.deg.alpha       = 0.384;
p.deg.k0          = 0.142;
p.deg.Tref_K      = 298.15;   % 25°C
p.deg.Ua_ref_V    = 0.123;    % graphite anode OCV at ~50% SOC (ref)

% OCV mapping (calibrated so Ua(50%)≈0.123 V)
p.deg.OCVmap.xa0   = 8.5e-3; 
p.deg.OCVmap.xa100 = 0.78;


% OCV mapping (cathode)
p.deg.OCVmap.xc0   = 0.916;
p.deg.OCVmap.xc100 = 0.045;


end