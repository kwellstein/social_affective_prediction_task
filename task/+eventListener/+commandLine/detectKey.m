function keyCode = detectKey(KBNumber, expType, OS)

% -----------------------------------------------------------------------
% detectKey.m checks if there is an input either from the keyboard or from the
%              response box 
%
%   SYNTAX:     keyCode = detectKey(expInfo, options)
%
%   IN:         KBNumber:   integer, number of the first found keyboard device
%               doKeyboard: logical, set to 1 if task is done on computer (as
%                                    opposed to response box)
%
%   OUT:        keyCode: vector of numbers corresponding to the pressed keys
%
%   AUTHOR:     Coded by:  Frederike Petzschner,  April 2017
%               Amended:  Katharina V. Wellstein, December 2019 for VAGUS study,
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
 
if strcmp(expType,'fmri')
    % EEG
    [~, keyCode, ~] = PsychRTBox('GetSecs', store.rtbox.rthandle);
    % also check keyboard in case of an escape
    [ ~, ~, keyCode2,  ~] = KbCheck(KBNumber);
    keyCode2 = find(keyCode2);
    keyCode = [keyCode, keyCode2];
elseif strcmp(expType,'behav')
    if strcmp(OS,'Mac') || strcmp(OS,'Linux')
    [ ~, ~, keyCode,  ~] = KbCheck;
    keyCode = find(keyCode);
    else
    [ ~, ~, keyCode,  ~] = KbCheck(deviceNumber);
     % also check keyboard in case of an escape
    [ ~, ~, keyCode2,  ~] = KbCheck;
    keyCode2 = find(keyCode2);
    keyCode = [keyCode, keyCode2];
    end
end

