% fix_simulink.m
% =========================================================================
% Applies two structural fixes to Battery_sim_2.slx:
%
%  FIX 1 — Calendar aging: replace continuous 1/s Integrator with
%           Discrete-Time Integrator (Forward Euler, ST=1).
%
%  FIX 2 — SOC integration: replace hardcoded Gain(dt_h/Q_nom) with
%           a Product block that divides by the live Q_actual signal.
%
% Backup is created before any changes.
% =========================================================================

projectRoot = fileparts(mfilename('fullpath'));
modelName   = 'Battery_sim_2';
modelFile   = fullfile(projectRoot, [modelName '.slx']);
backupFile  = fullfile(projectRoot, ...
    [modelName '_backup_' datestr(now,'yyyymmdd_HHMMSS') '.slx']);

copyfile(modelFile, backupFile);
fprintf('Backup: %s\n\n', backupFile);

load_system(modelFile);

% =========================================================================
%% FIX 1: Calendar aging — continuous Integrator → Discrete-Time Integrator
% =========================================================================
fprintf('--- FIX 1: Calendar aging ---\n');

intPath = [modelName '/Aging/Calendar_aging/Integrator'];
subCal  = [modelName '/Aging/Calendar_aging'];
intPos  = get_param(intPath, 'Position');

% Step 1: Explicitly delete the connected lines BEFORE deleting the block.
%         This avoids stale line handles and "port already connected" errors.
intPH   = get_param(intPath, 'PortHandles');
inLine  = get_param(intPH.Inport(1),  'Line');
outLine = get_param(intPH.Outport(1), 'Line');

if inLine  ~= -1, delete_line(inLine);  end
if outLine ~= -1, delete_line(outLine); end
fprintf('  Lines disconnected.\n');

% Step 2: Delete the block (now has no lines — clean deletion)
delete_block(intPath);
fprintf('  Deleted: continuous Integrator\n');

% Step 3: Add Discrete-Time Integrator at same position
add_block('simulink/Discrete/Discrete-Time Integrator', intPath, ...
    'IntegratorMethod', 'ForwardEuler', ...
    'SampleTime',       '1',           ...
    'InitialCondition', '0',           ...
    'LimitOutput',      'off',         ...
    'Position',         intPos);
fprintf('  Added: Discrete-Time Integrator (ForwardEuler, ST=1, IC=0)\n');

% Step 4: Reconnect using block names (robust — not affected by stale handles)
%         From screenshot: Gain → Integrator → Qcal (Outport 2)
add_line(subCal, 'Gain/1',        'Integrator/1', 'autorouting', 'on');
add_line(subCal, 'Integrator/1',  'Qcal/1',       'autorouting', 'on');
fprintf('  Reconnected: Gain → Integrator → Qcal\n');
fprintf('  FIX 1 complete.\n\n');

% =========================================================================
%% FIX 2: SOC gain — dt_h/Q_nom → dt_h / Q_actual
% =========================================================================
fprintf('--- FIX 2: SOC integration gain ---\n');

gainPath = [modelName '/power dispatch/Gain'];
subPD    = [modelName '/power dispatch'];
gainPos  = get_param(gainPath, 'Position');

% Step 1: Find what the Gain connects to (source block/port, destination block/port)
gainPH     = get_param(gainPath, 'PortHandles');
gainInLine = get_param(gainPH.Inport(1),  'Line');
gainOutLine= get_param(gainPH.Outport(1), 'Line');

% Source: block name + port number feeding INTO the Gain
srcBlockH  = get_param(gainInLine, 'SrcBlockHandle');
srcBlockName = get_param(srcBlockH, 'Name');
srcPortIdx = get_param(get_param(gainInLine,'SrcPortHandle'), 'PortNumber');

% Destination: block name + port number the Gain feeds INTO
dstBlockH    = get_param(gainOutLine, 'DstBlockHandle');
dstBlockName = get_param(dstBlockH, 'Name');
dstPortIdx   = get_param(get_param(gainOutLine,'DstPortHandle'), 'PortNumber');

fprintf('  Gain input  from: %s / port %d\n', srcBlockName, srcPortIdx);
fprintf('  Gain output to:   %s / port %d\n', dstBlockName, dstPortIdx);

% Step 2: Explicitly delete lines, then block
if gainInLine  ~= -1, delete_line(gainInLine);  end
if gainOutLine ~= -1, delete_line(gainOutLine); end
delete_block(gainPath);
fprintf('  Deleted: Gain(dt_h/Q_nom)\n');

% Step 3: Add constant block for dt_h
%         (placed just below the Product block position)
constPath = [modelName '/power dispatch/dt_h_soc'];
constPos  = [gainPos(1)-5,  gainPos(2)+55, ...
             gainPos(1)+55, gainPos(2)+85];
add_block('simulink/Sources/Constant', constPath, ...
    'Value',    'dt_h', ...
    'Position', constPos);
fprintf('  Added: Constant(dt_h)\n');

% Step 4: Add Product block: I_net * dt_h / Q_actual
%         Inputs = '**/' means: port1 * port2 / port3
prodPath = [modelName '/power dispatch/SOC_step'];
add_block('simulink/Math Operations/Product', prodPath, ...
    'Inputs',   '**/', ...
    'Position', gainPos);
fprintf('  Added: Product(**/) for I_net * dt_h / Q_actual\n');

% Step 5: Reconnect
%   port 1 = original signal that fed Gain (I_net or net current)
%   port 2 = dt_h constant
%   port 3 = Q_actual (Port 1 inport of power dispatch subsystem)
add_line(subPD, sprintf('%s/%d', srcBlockName, srcPortIdx), ...
               'SOC_step/1', 'autorouting', 'on');
add_line(subPD, 'dt_h_soc/1', 'SOC_step/2', 'autorouting', 'on');
add_line(subPD, 'Q_actual/1', 'SOC_step/3', 'autorouting', 'on');
add_line(subPD, 'SOC_step/1', ...
    sprintf('%s/%d', dstBlockName, dstPortIdx), 'autorouting', 'on');

fprintf('  Reconnected: %s → Product(I×dt_h/Q_actual) → %s\n', ...
    srcBlockName, dstBlockName);
fprintf('  FIX 2 complete.\n\n');

% =========================================================================
%% SAVE
% =========================================================================
save_system(modelName, modelFile);
close_system(modelName);
fprintf('Model saved: %s\n', modelFile);
fprintf('Done. Open the model to verify routing looks clean.\n\n');
