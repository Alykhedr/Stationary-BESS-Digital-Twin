% MAKE_FIXTURE_LONG  Generate a multi-year plant fixture for the SOH study.
%
% Runs the aging plant (Battery_sim_2) over its full configured horizon and
% logs the signals the offline BMS chain needs — INCLUDING Q_actual and
% SOH_true, which the 2-week fixture omitted. Saved to Data/fixture_long.mat
% in the same struct layout as fixture_2week.mat (+ Q_actual, SOH_true).
%
% Script (not function): the model's FromWorkspace blocks read the base
% workspace, exactly as main.m does. Truth signals (SOC_true, SOH_true,
% Q_actual) are for ANALYSIS ONLY — never fed into any BMS function.

clear; clc;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'Cell'));
addpath(fullfile(root, 'Data'));
addpath(fullfile(root, 'BMS'));

run(fullfile(root, 'Data', 'Workspace_set.m'));
root = fileparts(fileparts(mfilename('fullpath')));   % Workspace_set clears vars
load(fullfile(root, 'WS_Variables.mat'));

fprintf('Running Battery_sim_2 over full horizon (this may take a minute)...\n');
load_system(fullfile(root, 'Battery_sim_2.slx'));
t0 = tic;
simout = sim('Battery_sim_2');
fprintf('Sim done in %.1f s.\n', toc(t0));

vars = simout.who;
fprintf('Logged signals in simout: %s\n', strjoin(vars, ', '));

[I_true,   t_h] = getsig(simout, 'I_net');
[V_true,   ~]   = getsig(simout, 'V_terminal');
[T_true,   ~]   = getsig(simout, 'T_cell');
[SOC_true, ~]   = getsig(simout, 'SOC');
[SOH_true, ~]   = getsig(simout, 'SOH');

if any(strcmp(vars, 'Q_actual'))
    [Q_actual, ~] = getsig(simout, 'Q_actual');
else
    cfg = bms_config();
    Q_actual = SOH_true * cfg.cell.Q_nom;
end

n = min([numel(t_h) numel(I_true) numel(V_true) numel(T_true) ...
         numel(SOC_true) numel(SOH_true) numel(Q_actual)]);
clip = @(x) x(1:n);

fixture = struct( ...
    't_h',      clip(t_h), ...
    'I_true',   clip(I_true), ...
    'V_true',   clip(V_true), ...
    'T_true',   clip(T_true), ...
    'SOC_true', clip(SOC_true), ...
    'SOH_true', clip(SOH_true), ...
    'Q_actual', clip(Q_actual), ...
    'meta', sprintf('Battery_sim_2 full-horizon fixture; %d samples (0-%g h); generated %s', ...
                    n, t_h(n), datestr(now)));

save(fullfile(root, 'Data', 'fixture_long.mat'), 'fixture');

fprintf('\n=== fixture_long.mat written: %d samples, 0 to %.0f h (%.1f years) ===\n', ...
        n, fixture.t_h(end), fixture.t_h(end)/8760);
fprintf('  I_true   : %.3f .. %.3f A\n', min(I_true), max(I_true));
fprintf('  V_true   : %.3f .. %.3f V\n', min(V_true), max(V_true));
fprintf('  T_true   : %.2f .. %.2f degC\n', min(T_true), max(T_true));
fprintf('  SOC_true : %.3f .. %.3f\n', min(SOC_true), max(SOC_true));
fprintf('  SOH_true : %.4f .. %.4f  (capacity fade = %.2f%%)\n', ...
        min(SOH_true), max(SOH_true), (1-min(SOH_true))*100);
fprintf('  Q_actual : %.4f .. %.4f Ah\n', min(Q_actual), max(Q_actual));

function [v, t] = getsig(so, name)
x = so.(name);
if isa(x, 'timeseries')
    v = squeeze(x.Data); t = x.Time;
elseif isa(x, 'Simulink.SimulationData.Dataset')
    e = x.getElement(1); v = squeeze(e.Values.Data); t = e.Values.Time;
else
    v = squeeze(x); t = (0:numel(v)-1)';
end
v = double(v(:)); t = double(t(:));
end
