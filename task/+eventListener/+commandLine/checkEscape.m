function [options,abort] = checkEscape(options,dataFile,trial)

% -----------------------------------------------------------------------
% checkEscape.m checks if the escape key was pressed and aborts the game in
%               that case
%
%   SYNTAX:     [options,abort] = eventListener.commandLine.checkEscape(options,expInfo,dataFile,trial)
%
%   IN:          dataFile: struct,  data file initiated in initDataFile.m
%   IN:          expInfo:  struct,  contains key info on how the experiment is 
%                                   run instance 
%                options:  struct,  options the tasks will run with
%                trial:    integer, trial number
%
%   OUT:         options:  struct, updated options struct
%                abort:    logical, returns = 1 if the task is aborted
%
%   SUBFUNCTION(S): detectKey.m; logData.m; stopStim.m; saveInterimData.m
%
%   AUTHOR(S):    coded by: Frederike Petzschner, April 2017
%	              amended:  Kathatina V. Wellstein, May 2020
% -------------------------------------------------------------------------
%

keyCode = eventListener.commandLine.detectKey(options.KBNumber, options.doKeyboard);

if isempty(trial)
    trial = 1;
end

if any(keyCode==options.keys.escape)
        eventListener.logData(1,'events','exp_abort',dataFile,trial);

        disp('<strong>Experiment was aborted.</strong>')
        % output.saveInterimData([],options,dataFile,expInfo);

        ShowCursor;
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        Screen('CloseAll');
        sca;
        abort = 1;
else
    abort = 0;
end

end
