
function Uc = Uc_cathode(soc, map)
% UC_CATHODE  LiFePO4 cathode OCV vs SOC using Safari et al. Eq. A3
% map.xc0 and map.xc100 from Table AI (stoichiometry at SOC=0% and SOC=100%)
if nargin < 2 || ~isstruct(map)
    map.xc0   = 0.916;    % cathode lithiation at SOC=0%
    map.xc100 = 0.045;    % cathode lithiation at SOC=100%
end

soc = max(0, min(1, soc));

% Map SOC → cathode lithiation xc
% Note: cathode delithiates on charge so xc decreases as SOC increases
xc = map.xc0 + soc * (map.xc100 - map.xc0);

% Safari et al. cathode OCV, Eq. A3
Uc = 3.4323 ...
   - 0.8428  * exp(-80.2493 * (1 - xc)^1.3198) ...
   - 3.2474e-6 * exp(20.2645 * (1 - xc)^3.8003) ...
   + 3.2482e-6 * exp(20.2646 * (1 - xc)^3.7995);
end