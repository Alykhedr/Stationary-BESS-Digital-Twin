
function values = readTemperature()
    filepath = fullfile(fileparts(mfilename('fullpath')), 'duisburg_temperature_2018_2019.xlsx');
    T = readtable(filepath, 'VariableNamingRule', 'preserve');
    values = T{:,2};
end