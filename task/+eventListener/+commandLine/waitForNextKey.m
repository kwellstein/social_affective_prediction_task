function dataFile = waitForNextKey(options,expInfo,dataFile)

% -----------------------------------------------------------------------
% waitfornextkey.m waits for a keyboard input to continue with the next
%                      response
%
%   SYNTAX:         [] = waitfornextkey(options,expInfo)
%
%   IN:             options: struct, with a subfield for the yes no keys
%                   expInfo: struct, contains key info on how the experiment 
%                                    is run
%                   dataFile:struct, data file initiated in initDataFile.m
%
%   OUT:            dataFile:struct, updated data file in case of abort
%
%   SUBFUNCTIONS: detectKey.m
%
%   AUTHOR:      Coded by F.Petzschner ,  April 2017
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

waiting = 1;
keyCode = [];

while waiting
    keyCode = eventListener.commandLine.detectKey(options.KBNumber, options.expType, options.OS);
    if any(keyCode==options.keys.next)
        waiting = 0;
    elseif any(keyCode==options.keys.escape)
        DrawFormattedText(options.screen.window, options.messages.abortText, 'center', 'center', options.screen.black);
        Screen('Flip', options.screen.window);
        eventListener.logEvent('exp_','abort',dataFile,1,trial)
        disp('Experiment was aborted.')
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        sca
        return;
    end
     if isempty(keyCode) %% CHANGE!
        keyCode = options.keys.no;
     end
end
