function keyCode = testKeyboard

% -----------------------------------------------------------------------
% testKeyboard checks if there is an input either from the keyboard or from the
%              response box 
%
%   SYNTAX:      keyCode = testKeyboards
%
%   OUT:         keyCode: vector of numbers corresponding to the pressed keys
%
%   SUBFUNCTION: keyCode = detectkey(deviceNumber,doKeyboard).m
%
%   AUTHOR:      Coded by:  Frederike Petzschner,  April 2017
%                Amended:  Katharina V. Wellstein, December 2019 for VAGUS study,
%	                                              XX.2024 for SAPS study
% -------------------------------------------------------------------------
% This file is released under the terms of the GNU General Public Licence
% (GPL), version 3. You can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% This file is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program. If not, see <https://www.gnu.org/licenses/>.
% _______________________________________________________________________________%
 
%

%% INITIALIZE

waiting = 1;
ticID = tic();
rt = 0;
keyCode = [];
KbName('UnifyKeyNames');
while waiting
    keyCode = detectkey(1, 1, 1); % deviceNumber, options.expType, option.OS
    rt = toc(ticID);
    if any(keyCode==45) % CHANGE ALL HERE!!!
        resp       = 1;
        waiting    = 0;
    elseif any(keyCode==58)
        resp       = 0;
        waiting    = 0;
    elseif KbName == 'tab'
        resp       = 0;
        waiting    = 0;
    elseif KbName == ',<' 
        resp       = -1;
        waiting    = 0;
    elseif KbName == '.>'
        resp       = 1;
        waiting    = 0;
    elseif rt> 5
        waiting    = 0;
        resp       = NaN;    
    end
end

%% DETECT KEY
keyCode = detectkey(options.KBNumber, options.expType, option.OS);

end