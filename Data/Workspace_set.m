
clc; clear;
Cell_Variables_Init
Environment_profile

if exist('surrogate_map.mat','file')
    M = load('surrogate_map.mat');  R = M.R;
    bpC   = double(R.gC(:));
    bpSOC = double(R.gSOC(:));
    bpSOH = double(R.gSOH(:));
    mapCeff = double(R.C_eff);
    mapTact = double(R.t_active);
end
% --- BMS_Status bus object (define before the model loads) ---
e(1) = Simulink.BusElement; e(1).Name = 'mode';          e(1).DataType = 'double';
e(2) = Simulink.BusElement; e(2).Name = 'fault_code';    e(2).DataType = 'double';
e(3) = Simulink.BusElement; e(3).Name = 'derate_active'; e(3).DataType = 'boolean';
e(4) = Simulink.BusElement; e(4).Name = 'limit_hit';     e(4).DataType = 'boolean';
e(5) = Simulink.BusElement; e(5).Name = 't_active';      e(5).DataType = 'double';

BMS_Status = Simulink.Bus;
BMS_Status.Elements = e;
clear e

save('WS_Variables.mat')

