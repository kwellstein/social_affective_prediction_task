function [dataFile,rt,resp] = showResponseScreen(cues,options,expInfo,dataFile,task,trial)

% -----------------------------------------------------------------------
% showResponseScreen.m shows the response screen depending on the
%                     participants response detected by waitForResponse.m
%
%   SYNTAX:       [dataFile,rt,resp] = showResponseScreen(cues,options,expInfo,...
%                                                         dataFile,task,trial)
%
%   IN:           cues:     struct, contains names of slides initiated in
%                                   initiate Visuals
%                 options:  struct, options the tasks will run with
%                 expInfo:  struct, contains key info on how the experiment is 
%                                   run instance 
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
rt      = 0;
keyCode = [];

%% WAIT for response

while waiting
    
    % show question
    if strcmp(task, 'painDetect')
     Screen('DrawTexture', options.screen.windowPtr, cues.painT_q, [], options.screen.rect, 0);  
    else
     Screen('DrawTexture', options.screen.windowPtr, cues.detectionT_q, [], options.screen.rect, 0);  
    end
    
    Screen('Flip', options.screen.windowPtr);
    
    % detect response
    keyCode = eventListener.commandLine.detectKey(expInfo.KBNumber, options.doKeyboard);
    rt      = toc(ticID);
    
    if any(keyCode == options.keys.yes)
        resp        = 1;
        waiting     = 0;
        
    elseif any(keyCode == options.keys.no)
        resp            = 0;
        waiting         = 0;
        
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


                                            
%% SHOW response screen
if strcmp(task, 'painDetect')
    if resp == 1
    Screen('DrawTexture', options.screen.windowPtr, cues.painDetectRespYes, [], options.screen.rect, 0);
        elseif resp == 0
    Screen('DrawTexture', options.screen.windowPtr, cues.painDetectRespNo, [], options.screen.rect, 0);
    end

else
    if resp == 1
    Screen('DrawTexture', options.screen.windowPtr, cues.respYes, [], options.screen.rect, 0);
        elseif resp == 0
    Screen('DrawTexture', options.screen.windowPtr, cues.respNo, [], options.screen.rect, 0);
    end
end

Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showScreen,options,expInfo,dataFile,trial);

end