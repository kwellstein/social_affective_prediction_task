function [dataFile,rt,resp] = waitForResponse(cues,options,expInfo,dataFile,task,trial)

% -----------------------------------------------------------------------
% waitForResponse.m waits for a keyboard input to response to a
%                   question with yes and no
%
%   SYNTAX:     [dataFile,rt,resp] = waitForResponse(cues,options,expInfo,...
%                                                    dataFile,task,trial)
%
%   IN:           cues:     struct, contains names of slides initiated in
%                                 initiate Visuals
%                 options:  struct, options the tasks will run with
%                 expInfo:  struct, contains key info on how the experiment is 
%                                 run instance, incl. keyboard number 
%                 dataFile: struct, data file initiated in initDataFile.m
%                 trial:    integer, trial number 
%
%   OUT:          dataFile: struct, updated data file
%                 rt:       double, reaction time
%                 resp:     integer, respsonse
%
%   SUBFUNCTIONS: detectKey.m; Screen.m; logEvent.m
%
%   AUTHOR:     Coded by: Frederike Petzschner,   April 2017
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

%% INITIALIZE
waiting = 1;
ticID   = tic();
rt      = 0;
keyCode = [];

%% WAIT for response

%!!!!! AMEND RE CUES/STIMULI

while waiting
    
    % show question

    Screen('DrawTexture', options.screen.windowPtr, cues.cues.painT_q, [], options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    
    % detect response
    keyCode = eventListener.commandLine.detectKey(options.KBNumber, options.expType, option.OS);
    rt      = toc(ticID);
    
    if any(keyCode == options.keys.startStmile)
        resp        = 1;
        waiting     = 1;
        
    elseif any(keyCode == options.keys.noSmile)
        resp            = 0;
        waiting         = 1;
   
    elseif any(keyCode == options.keys.stopSmile)
           Screen('DrawTexture', options.screen.windowPtr, cues.cues.painT_q, [], options.screen.rect, 0);
           Screen('Flip', options.screen.windowPtr);

    elseif any(keyCode == options.keys.escape)
        DrawFormattedText(options.screen.windowPtr, options.messages.abortText,...
                                     'center', 'center', options.screen.black);
        Screen('Flip', options.screen.windowPtr);
        dataFile        = eventListener.logEvent('exp','_abort', [],trial);
        disp('Game was aborted.')
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        sca
        return;
        
    elseif rt > options.dur.rtTimeout
        Screen('DrawTexture', options.screen.windowPtr, cues.timeOut, [], options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        dataFile = eventListener.logEvent('exp','_missedTrial', [],trial);
        disp('Participant missed a trial.')
        waiting  = 0;
        resp     = NaN;   
        
    end
end

