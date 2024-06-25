function [dataFile,rt,resp] = waitForResponse(cues,options,expInfo,dataFile,task,trial)

% -----------------------------------------------------------------------
% waitForResponse.m waits for a keyboard input to response to a question with yes and no
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
%   SUBFUNCTION(S): detectKey.m; Screen.m; logEvent.m
%
%   AUTHOR(S):     coded by: Frederike Petzschner, April 2017
%                  amended:  Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%

%% INITIALIZE
waiting = 1;
ticID   = tic();
rt      = 0;
keyCode = [];

%% WAIT for response

while waiting
    
    % show question
    if task == 'painDetect'
        Screen('DrawTexture', options.screen.windowPtr, cues.cues.painT_q, [], options.screen.rect, 0);
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

