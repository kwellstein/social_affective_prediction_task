function [dataFile,RT,resp] = askPrediction(cue,options,dataFile,task,trial)

% -----------------------------------------------------------------------
% askPrediction.m shows the response screen depending on the
%                     participants response detected by waitForResponse.m
%
%   SYNTAX:       [dataFile,RT,resp] = tools.askPrediction(expMode,cue,options,dataFile,task,trial,respMode)
%
%   IN:           expMode:   string,'practice' or 'experiment'
%                 cue:       struct, contains names of slides initiated in
%                                   initiate Visuals
%                 options:  struct, options the tasks will run with
%                 dataFile: struct, data file initiated in initDataFile.m
%                 task:     string, task name
%                 trial:    integer, trial number
%                 respMode: string, 'start' or 'stop', refering to whether
%                                   a participant is about to start or stop smiling
%
%   OUT:          dataFile: struct, updated data file
%                 RT:       double, reaction time
%                 resp:     integer, response (1=yes, 0 = no)
%
%   AUTHOR:     Katharina V. Wellstein, December 2019
%               Amended for SAPS study October 2024
%               katharina.wellstein@newcastle.edu.au
%               https://github.com/kwellstein
% -------------------------------------------------------------------------------%
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

%% GET response
waiting = 1;
ticID   = tic();
RT      = 0;

dataFile.events.predAction_startTime(trial) = extractAfter(char(datetime('now')),12);
dataFile.events.predAction_startTimeStp(trial) = GetSecs();

%% WAIT for response

while waiting

    % show predictionslide
    Screen('DrawTexture', options.screen.windowPtr, cue,[], options.screen.rect, 0);
    Screen('TextSize', options.screen.windowPtr, 50);
    DrawFormattedText(options.screen.windowPtr,options.screen.startPredictText,'center',[],[255 255 255],[],[],[],1);
    Screen('Flip', options.screen.windowPtr);

    % detect response
    [ ~, ~, keyCode,  ~] = KbCheck;
    keyCode = find(keyCode);
    RT      = toc(ticID);

    if any(keyCode == options.keys.smile)
        resp    = 1;
        % if options.doEMG==1
        %     parPulse(options.EMG.portNo) % get port address
        %     parPulse(options.EMG.smileStart,0,15,1)
        % end
        waiting = 0;

    elseif any(keyCode == options.keys.noSmile)
        resp    = 0;
        % if options.doEMG==1
        %     parPulse(options.EMG.portNo) % get port address
        %     parPulse(options.EMG.neutralStart,0,15,1)
        % end
        waiting = 0;

        % in case ESC is pressed this will be logged and saved and the
        % experiment stops here
    elseif any(keyCode == options.keys.escape)
        DrawFormattedText(options.screen.windowPtr, options.messages.abortText,...
            'center', 'center', options.screen.grey);
        Screen('Flip', options.screen.windowPtr);
        dataFile        = eventListener.logEvent('exp','_abort',dataFile,1,trial);
        output.saveData(options,dataFile);
        disp('Game was aborted.')
        Screen('CloseAll');
        ListenChar(0);
        sca
        return;

        % if the participant takes too long (as defined in the options)
        % this will be logged and saved as NaN. A time-out message will be
        % displayed
    elseif RT*1000 > options.dur.rtTimeout
        durMissedTrial = options.dur.afterActionITI(trial)-(RT*1000);
        DrawFormattedText(options.screen.windowPtr, options.messages.timeOut,...
            'center', 'center', options.screen.grey);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(durMissedTrial,options,dataFile,0);
        dataFile = eventListener.logEvent('exp','_missedTrial',dataFile,1,trial);
        disp(['Participant missed trial ',num2str(trial),'... ']);

        waiting  = 0;
        resp     = NaN;

    end % END STARTSMILE detection loop
end
    dataFile.events.predAction_stopTime(trial) = extractAfter(char(datetime('now')),12);
    [~,dataFile] = eventListener.logData(RT,task,'rt',dataFile,trial);
    [~,dataFile] = eventListener.logData(resp,task,'response',dataFile,trial);

end
