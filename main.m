clear; clc;

% Add project paths
addpath(fullfile(fileparts(mfilename('fullpath')), 'Cell'));
addpath(fullfile(fileparts(mfilename('fullpath')), 'Data'));

run(fullfile(fileparts(mfilename('fullpath')), 'Data', 'Workspace_set'));
load("WS_Variables.mat")



load_system("Battery_sim_2");
simout = sim("Battery_sim_2");

