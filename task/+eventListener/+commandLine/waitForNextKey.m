function dataFile = waitForNextKey(options,expInfo,dataFile)

% -----------------------------------------------------------------------
% waitfornextkey.m waits for a keyboard input to continue with the next
%                      response
%
%   SYNTAX:         dataFile = eventListener.commandLine.waitForNextKey(options,expInfo,dataFile)
%
%   IN:             options: struct, with a subfield for the yes no keys
%                   expInfo: struct, contains key info on how the experiment 
%                                    is run
%                   dataFile:struct, data file initiated in initDataFile.m
%
%   OUT:            dataFile:struct, updated data file in case of abort
%
%   SUBFUNCTION(S): detectKey.m
%
%   AUTHOR(S):  coded by F.Petzschner 19. April 2017
%               last change: Katharina V. Wellstein, December 2019
%
% -------------------------------------------------------------------------

waiting = 1;
keyCode = [];

while waiting
    [ ~, ~, keyCode,  ~] = KbCheck;
    keyCode = find(keyCode);
    if any(keyCode==options.keys.next)
        waiting = 0;
    elseif any(keyCode==options.keys.escape)
        DrawFormattedText(options.screen.window, options.messages.abortText, 'center', 'center', options.screen.black);
        Screen('Flip', options.screen.window);
        eventListener.logEvent('exp_','abort',dataFile,1,trial)
        disp('Experiment was aborted.')
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        Screen('CloseAll');
        sca
        return;
    end
     if isempty(keyCode)
        keyCode = options.keys.no;
     end
end
