
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

save('WS_Variables.mat')

