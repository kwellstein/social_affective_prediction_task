function [dataFile,RT,resp] = askPrediction(~,cue,options,dataFile,task,trial,respMode)

% -----------------------------------------------------------------------
% askPrediction.m shows the response screen depending on the
%                     participants response detected by waitForResponse.m
%
%   SYNTAX:       [dataFile,rt,resp] = showResponseScreen(cues,options,expInfo,...
%                                                         dataFile,task,trial)
%
%   IN:           cues:     struct, contains names of slides initiated in
%                                   initiate Visuals
%                 options:  struct, options the tasks will run with
%                 dataFile: struct, data file initiated in initDataFile.m
%                 task:     string, task name
%                 trial:    integer, trial number
%
%   OUT:          dataFile: struct, updated data file
%                 rt:       double, reaction time
%                 resp:     integer, response (1=ja, 0 = nein)
%
%   AUTHOR:     Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%
%% GET response
waiting = 1;
ticID   = tic();
RT      = 0;

%% WAIT for response
if strcmp(respMode,'start')
    while waiting

        % show predictionslide
        Screen('DrawTexture', options.screen.windowPtr, cue,[], options.screen.rect, 0);
        Screen('TextSize', options.screen.windowPtr, 50);
        DrawFormattedText(options.screen.windowPtr,options.screen.startPredictText,'center',[],[255 255 255],[],[],[],1);
        Screen('Flip', options.screen.windowPtr);

        % detect response
        keyCode = eventListener.commandLine.detectKey(options.KBNumber, options.doKeyboard);
        RT      = toc(ticID);

        if any(keyCode == options.keys.startSmile)
            resp    = 1;
            waiting = 0;

        elseif any(keyCode == options.keys.noSmile)
            resp    = 0;
            waiting = 0;

            % in case ESC is pressed this will be logged and saved and the
            % experiment stops here
        elseif any(keyCode == options.keys.escape)
            DrawFormattedText(options.screen.windowPtr, options.messages.abortText,...
                'center', 'center', options.screen.grey);
            Screen('Flip', options.screen.windowPtr);
            dataFile        = eventListener.logEvent('exp','_abort', [],trial);
            disp('Game was aborted.')
            Screen('CloseAll');
            sca
            return;

            % if the participant takes too long (as defined in the options)
            % this will be logged and saved as NaN. A time-out message will be
            % displayed
        elseif RT > options.dur.rtTimeout
            DrawFormattedText(options.screen.windowPtr, options.messages.timeOut,...
                'center', 'center', options.screen.grey);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(options.dur.showWarning,options,dataFile,0);
            dataFile = eventListener.logEvent('exp','_missedTrial', [],trial);
            disp(['Participant missed trial ',num2str(trial),'... ']);
            waiting  = 0;
            resp     = NaN;

        end % END STARTSMILE detection loop
    end % END WAITING loop

    [~,dataFile] = eventListener.logData(RT,task,'rt',dataFile,trial);
    [~,dataFile] = eventListener.logData(resp,task,'response',dataFile,trial);
    % show face
    Screen('DrawTexture', options.screen.windowPtr, cue,[], options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);

else
    while waiting
        % show screen with stimulus and wait for participant to press a
        % button or time-out
        Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showSmile,options,dataFile,0);
        % show predictionslide
        Screen('DrawTexture', options.screen.windowPtr, cue,[], options.screen.rect, 0);
        Screen('TextSize', options.screen.windowPtr, 50);
        DrawFormattedText(options.screen.windowPtr,options.screen.stopPredictText,'center',[],[255 255 255],[],[],[],1);
        Screen('Flip', options.screen.windowPtr);

        keyCode = eventListener.commandLine.detectKey(options.KBNumber, options.doKeyboard);
        RT      = toc(ticID);
        if any(keyCode == options.keys.stopSmile)
            waiting = 0;

            % in case ESC is pressed this will be logged and saved and the experiment stops here
        elseif any(keyCode == options.keys.escape)
            DrawFormattedText(options.screen.windowPtr, options.messages.abortText,...
                'center', 'center', options.screen.grey);
            Screen('Flip', options.screen.windowPtr);
            dataFile        = eventListener.logEvent('exp','_abort', [],trial);
            disp('Game was aborted.')
            Screen('CloseAll');
            sca
            return;

            % if the participant takes too long (as defined in the options)this will
            % be logged and saved as NaN. A time-out message will be displayed
        elseif RT > options.dur.rtTimeout
            DrawFormattedText(options.screen.windowPtr, options.messages.timeOut,...
                'center', 'center', options.screen.grey);
            Screen('Flip', options.screen.windowPtr);
            dataFile = eventListener.logEvent('exp','_missedTrial', [],trial);
            disp('Participant missed a trial.')
            waiting  = 0;
            resp     = NaN;
        end % END STARTSMILE detection loop
    end % END WAITING loop
end
end
