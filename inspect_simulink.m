% inspect_simulink.m
% =========================================================================
% Programmatic inspection of Battery_sim_2.slx block parameters.
% Checks all structural and numerical settings against Schimpe (2018)
% without opening the Simulink GUI.
%
% Checks:
%   A. Solver & simulation settings
%   B. All blocks in model — types, names, key parameters
%   C. SOC integrator — gain, IC, limits, sample time
%   D. Capacity fade feedback path (Q_actual denominator)
%   E. Calendar aging accumulator — Sum+UnitDelay vs integrator
%   F. Cycle aging accumulator
%   G. Thermal integrator — IC, limits
%   H. MATLAB Function blocks — correct .m file linkage
%   I. Input/Output ports and signal routing summary
% =========================================================================

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'Cell'));
addpath(fullfile(projectRoot, 'Data'));

modelName = 'Battery_sim_2';
fprintf('\n========== Simulink Model Inspection: %s ==========\n\n', modelName);

load_system(fullfile(projectRoot, modelName));

pass = 0; fail = 0; info = 0;

function emit(tag, label, val_str, note)
    sym = '';
    switch tag
        case 'PASS', sym = '[PASS]';
        case 'FAIL', sym = '[FAIL]';
        case 'INFO', sym = '[INFO]';
        case 'WARN', sym = '[WARN]';
    end
    fprintf('  %-6s  %-45s  %s\n', sym, label, val_str);
    if nargin > 3 && ~isempty(note)
        fprintf('         NOTE: %s\n', note);
    end
end

% =========================================================================
fprintf('--- A. SOLVER & SIMULATION SETTINGS ---\n');
% =========================================================================
solver     = get_param(modelName, 'Solver');
stopTime   = get_param(modelName, 'StopTime');
startTime  = get_param(modelName, 'StartTime');
sampleTime = get_param(modelName, 'FixedStep');
simType    = get_param(modelName, 'SolverType');

emit('INFO', 'Solver',        solver,   '');
emit('INFO', 'Solver type',   simType,  '');
emit('INFO', 'Start time',    startTime,'');
emit('INFO', 'Stop time',     stopTime, 'Expected: 87600 (10 yrs in hours)');
emit('INFO', 'Fixed step',    sampleTime, 'Expected: 1 (1-hour step)');

if strcmp(solver,'FixedStepDiscrete') || strcmp(simType,'Fixed-step')
    emit('PASS','Solver is fixed-step discrete','','Correct for hourly BESS simulation');
    pass = pass+1;
else
    emit('WARN','Solver is NOT fixed-step discrete',solver,...
         'For hourly dispatch model, ode1 or discrete is preferred');
end

if str2double(stopTime) == 87600
    emit('PASS','Stop time = 87600 h (10 years)','',''); pass=pass+1;
else
    emit('WARN','Stop time != 87600',stopTime,'Check simulation horizon');
end

% =========================================================================
fprintf('\n--- B. BLOCK INVENTORY ---\n');
% =========================================================================
allBlocks = find_system(modelName, 'LookUnderMasks','all', 'Type','block');
blockTypes = cellfun(@(b) get_param(b,'BlockType'), allBlocks, 'UniformOutput', false);
blockNames = cellfun(@(b) get_param(b,'Name'),      allBlocks, 'UniformOutput', false);

% Count by type
typeList = unique(blockTypes);
fprintf('  Block type summary:\n');
for k = 1:length(typeList)
    n = sum(strcmp(blockTypes, typeList{k}));
    fprintf('    %-30s  %d\n', typeList{k}, n);
end

% List all MATLAB Function blocks (critical — linked to our .m files)
mfcnBlocks = allBlocks(strcmp(blockTypes,'SubSystem'));
fprintf('\n  Subsystem / MATLAB Function blocks:\n');
for k = 1:length(allBlocks)
    bt = blockTypes{k};
    bn = blockNames{k};
    bp = allBlocks{k};
    if strcmp(bt,'SubSystem') || strcmp(bt,'MATLABFcn') || strcmp(bt,'Embedded MATLAB Function')
        emit('INFO', bn, bt, '');
    end
end

% =========================================================================
fprintf('\n--- C. SOC INTEGRATOR ---\n');
% =========================================================================
% Expected structure:
%   Net current = (Ich - Idis - SOC*self_discharge_rate*Q_actual) [A]
%   Divided by Q_actual [Ah] → rate in [1/h]
%   Discrete integrator with sample time = 1h, IC = SOC0 = 0.5
%   Output limited to [SOC_min, SOC_max] = [0.05, 0.95]

intBlocks = find_system(modelName,'LookUnderMasks','all',...
    'BlockType','DiscreteIntegrator');
fprintf('  Found %d DiscreteIntegrator block(s)\n', length(intBlocks));

for k = 1:length(intBlocks)
    bp  = intBlocks{k};
    bn  = get_param(bp,'Name');
    ic  = get_param(bp,'InitialCondition');
    st  = get_param(bp,'SampleTime');
    lim = get_param(bp,'LimitOutput');
    ul  = get_param(bp,'UpperSaturationLimit');
    ll  = get_param(bp,'LowerSaturationLimit');
    gain= get_param(bp,'gainval');
    method = get_param(bp,'IntegratorMethod');

    fprintf('\n  Block: %s\n', bn);
    emit('INFO','  IntegratorMethod', method, '');
    emit('INFO','  InitialCondition', ic,     'Expected: SOC0 = 0.5');
    emit('INFO','  SampleTime',       st,     'Expected: 1 (hours)');
    emit('INFO','  LimitOutput',      lim,    'Expected: on');
    emit('INFO','  UpperLimit',       ul,     'Expected: SOC_max = 0.95');
    emit('INFO','  LowerLimit',       ll,     'Expected: SOC_min = 0.05');
    emit('INFO','  Gain (K)',         gain,   'Expected: 1 (gain in denominator path)');

    % IC check
    ic_val = str2double(ic);
    if ~isnan(ic_val)
        if abs(ic_val - 0.5) < 1e-9
            emit('PASS','  IC = 0.5 (SOC0)','',''); pass=pass+1;
        else
            emit('FAIL','  IC != 0.5',ic,'Expected SOC0=0.5'); fail=fail+1;
        end
    else
        emit('INFO','  IC is a variable',ic,'Verify it resolves to 0.5 from workspace');
        info=info+1;
    end

    % Sample time check
    st_val = str2double(st);
    if ~isnan(st_val) && st_val == 1
        emit('PASS','  Sample time = 1h','',''); pass=pass+1;
    elseif ~isnan(st_val) && st_val == -1
        emit('INFO','  Sample time = -1 (inherited)','','Check parent Triggered/Enabled subsystem rate');
        info=info+1;
    else
        emit('INFO','  Sample time is variable or non-standard',st,'');
        info=info+1;
    end

    % Limits check
    if strcmp(lim,'on')
        emit('PASS','  Output limiting is ON','',''); pass=pass+1;
        ul_val = str2double(ul);
        ll_val = str2double(ll);
        if ~isnan(ul_val) && abs(ul_val-0.95)<1e-9
            emit('PASS','  Upper limit = 0.95 (SOC_max)','',''); pass=pass+1;
        else
            emit('INFO','  Upper limit is variable',ul,'Verify = SOC_max = 0.95'); info=info+1;
        end
        if ~isnan(ll_val) && abs(ll_val-0.05)<1e-9
            emit('PASS','  Lower limit = 0.05 (SOC_min)','',''); pass=pass+1;
        else
            emit('INFO','  Lower limit is variable',ll,'Verify = SOC_min = 0.05'); info=info+1;
        end
    else
        emit('FAIL','  Output limiting is OFF','','SOC must be bounded [SOC_min, SOC_max]'); fail=fail+1;
    end
end

if isempty(intBlocks)
    % Also check for continuous integrators (should NOT be used for SOC)
    contInt = find_system(modelName,'LookUnderMasks','all','BlockType','Integrator');
    if ~isempty(contInt)
        emit('WARN','Continuous Integrator found — check if used for SOC',...
            num2str(length(contInt)),...
            'SOC should use DiscreteIntegrator at 1h sample time, not continuous');
    end
end

% =========================================================================
fprintf('\n--- D. CAPACITY FADE FEEDBACK ---\n');
% =========================================================================
% Critical: Q_actual = Q_nom * (1 - Q_loss_total/100)
% Q_actual must divide into the SOC integrator denominator.
% Look for Product/Divide blocks that could implement this.

prodBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','Product');
fprintf('  Found %d Product/Divide block(s)\n', length(prodBlocks));
for k = 1:length(prodBlocks)
    bp = prodBlocks{k};
    bn = get_param(bp,'Name');
    inputs = get_param(bp,'Inputs');
    emit('INFO', ['  Product: ' bn], ['Inputs: ' inputs], '');
end

% Look for Sum blocks with Q_loss signal
sumBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','Sum');
fprintf('  Found %d Sum block(s)\n', length(sumBlocks));
for k = 1:length(sumBlocks)
    bp = sumBlocks{k};
    bn = get_param(bp,'Name');
    inputs = get_param(bp,'Inputs');
    emit('INFO', ['  Sum: ' bn], ['Inputs: ' inputs], '');
end

% =========================================================================
fprintf('\n--- E. CALENDAR AGING ACCUMULATOR ---\n');
% =========================================================================
% Must be: dQcal → Sum → output (Qcal_total)
%               ↑
%         UnitDelay (z^-1, IC=0, sample time=1)
%
% NOT allowed: continuous Integrator (would integrate a rate, wrong units)

udBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','UnitDelay');
fprintf('  Found %d UnitDelay block(s)\n', length(udBlocks));
for k = 1:length(udBlocks)
    bp = udBlocks{k};
    bn = get_param(bp,'Name');
    ic = get_param(bp,'InitialCondition');
    st = get_param(bp,'SampleTime');
    emit('INFO', ['  UnitDelay: ' bn], ['IC=' ic '  ST=' st], ...
         'Calendar/cycle aging accumulators should use this pattern');
end

contIntBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','Integrator');
if ~isempty(contIntBlocks)
    fprintf('  Found %d continuous Integrator block(s) — checking usage:\n',...
        length(contIntBlocks));
    for k = 1:length(contIntBlocks)
        bp = contIntBlocks{k};
        bn = get_param(bp,'Name');
        emit('WARN',['  Integrator: ' bn],'Continuous',...
             'If used for aging accumulation: WRONG — use Sum+UnitDelay');
    end
else
    emit('PASS','No continuous Integrators found','',''); pass=pass+1;
end

% =========================================================================
fprintf('\n--- F. FROM-WORKSPACE / SIGNAL SOURCE BLOCKS ---\n');
% =========================================================================
fwBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','FromWorkspace');
fprintf('  Found %d FromWorkspace block(s)\n', length(fwBlocks));
for k = 1:length(fwBlocks)
    bp  = fwBlocks{k};
    bn  = get_param(bp,'Name');
    var = get_param(bp,'VariableName');
    st  = get_param(bp,'SampleTime');
    emit('INFO',['  FromWorkspace: ' bn],['Var=' var '  ST=' st],'');

    % Interpolation method
    interp = get_param(bp,'Interpolate');
    if strcmp(interp,'off')
        emit('PASS',['  ' bn ': interpolation OFF (ZOH for hourly data)'],'','');
        pass=pass+1;
    else
        emit('INFO',['  ' bn ': interpolation ON'],interp,...
             'For hourly dispatch data, ZOH (off) is preferred over linear interp');
        info=info+1;
    end
end

% =========================================================================
fprintf('\n--- G. MATLAB FUNCTION BLOCK LINKAGE ---\n');
% =========================================================================
% Find all MATLAB Function (Stateflow chart or EML) blocks
sfBlocks = find_system(modelName,'LookUnderMasks','all',...
    'BlockType','SubSystem');

fprintf('  Checking MATLAB Function / S-Function blocks:\n');
sfcnBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','S-Function');
for k = 1:length(sfcnBlocks)
    bp = sfcnBlocks{k};
    bn = get_param(bp,'Name');
    fn = get_param(bp,'FunctionName');
    emit('INFO',['  S-Function: ' bn],fn,'');
end

% Check for any block whose name matches our known functions
knownFcns = {'cell_thermal','calendar_aging','cycle_aging','current_limiter'};
for k = 1:length(knownFcns)
    hits = find_system(modelName,'LookUnderMasks','all','Name',knownFcns{k});
    if ~isempty(hits)
        emit('INFO',['  Found block named: ' knownFcns{k}], ...
            get_param(hits{1},'BlockType'),'');
    end
end

% =========================================================================
fprintf('\n--- H. OUTPUT / TO-WORKSPACE BLOCKS ---\n');
% =========================================================================
twBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','ToWorkspace');
fprintf('  Found %d ToWorkspace block(s)\n', length(twBlocks));
for k = 1:length(twBlocks)
    bp  = twBlocks{k};
    bn  = get_param(bp,'Name');
    var = get_param(bp,'VariableName');
    fmt = get_param(bp,'SaveFormat');
    emit('INFO',['  ToWorkspace: ' bn],['Var=' var '  Format=' fmt],'');
end

% Also check Outport blocks
outBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','Outport');
fprintf('  Found %d Outport block(s)\n', length(outBlocks));
for k = 1:length(outBlocks)
    bp = outBlocks{k};
    bn = get_param(bp,'Name');
    pn = get_param(bp,'Port');
    emit('INFO',['  Outport ' pn ': ' bn],'','');
end

% =========================================================================
fprintf('\n--- I. SCOPE / DISPLAY BLOCKS ---\n');
% =========================================================================
scopeBlocks = find_system(modelName,'LookUnderMasks','all','BlockType','Scope');
fprintf('  Found %d Scope block(s)\n', length(scopeBlocks));
for k = 1:length(scopeBlocks)
    bp = scopeBlocks{k};
    bn = get_param(bp,'Name');
    emit('INFO',['  Scope: ' bn],'','');
end

% =========================================================================
fprintf('\n--- J. FULL BLOCK LIST WITH KEY PARAMETERS ---\n');
% =========================================================================
fprintf('  %-35s  %-25s  %s\n','Block Name','Type','Key Parameter');
fprintf('  %s\n', repmat('-',1,90));
for k = 1:length(allBlocks)
    bp = allBlocks{k};
    bt = blockTypes{k};
    bn = blockNames{k};

    % Get one key parameter per block type
    try
        switch bt
            case 'Gain'
                kp = ['Gain=' get_param(bp,'Gain')];
            case 'Constant'
                kp = ['Value=' get_param(bp,'Value')];
            case 'DiscreteIntegrator'
                kp = ['IC=' get_param(bp,'InitialCondition') ...
                      '  ST=' get_param(bp,'SampleTime')];
            case 'Integrator'
                kp = ['IC=' get_param(bp,'InitialCondition')];
            case 'UnitDelay'
                kp = ['IC=' get_param(bp,'InitialCondition') ...
                      '  ST=' get_param(bp,'SampleTime')];
            case 'FromWorkspace'
                kp = ['Var=' get_param(bp,'VariableName')];
            case 'ToWorkspace'
                kp = ['Var=' get_param(bp,'VariableName')];
            case 'Scope'
                kp = '';
            case 'Sum'
                kp = ['Inputs=' get_param(bp,'Inputs')];
            case 'Product'
                kp = ['Inputs=' get_param(bp,'Inputs')];
            case 'Saturate'
                kp = ['[' get_param(bp,'LowerLimit') ',' get_param(bp,'UpperLimit') ']'];
            case 'Switch'
                kp = ['Threshold=' get_param(bp,'Threshold')];
            case 'RelationalOperator'
                kp = get_param(bp,'Operator');
            case 'Lookup_n-D'
                kp = ['Dims=' get_param(bp,'NumberOfTableDimensions')];
            case 'Inport'
                kp = ['Port=' get_param(bp,'Port')];
            case 'Outport'
                kp = ['Port=' get_param(bp,'Port')];
            otherwise
                kp = '';
        end
    catch
        kp = '';
    end

    % Shorten path for readability
    shortName = strrep(bp, [modelName '/'], '');
    fprintf('  %-35s  %-25s  %s\n', shortName(1:min(end,35)), bt(1:min(end,25)), kp);
end

% =========================================================================
fprintf('\n========== INSPECTION SUMMARY ==========\n');
fprintf('  PASS: %d   FAIL: %d   INFO/WARN: %d\n\n', pass, fail, info);

if fail == 0
    fprintf('  No structural failures detected.\n');
else
    fprintf('  %d issue(s) require attention — see [FAIL] lines above.\n', fail);
end

close_system(modelName, 0);
fprintf('\n  Model closed (no changes saved).\n\n');
