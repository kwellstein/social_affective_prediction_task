function [options,abort] = checkEscape(options,dataFile,trial)

% -----------------------------------------------------------------------
% checkEscape.m checks if the escape key was pressed and aborts the task in
%               that case
%
%   SYNTAX:       [dataFile, expInfo] = runTask(cues,options,expInfo,dataFile,...
%                                               task,maxDur)
%
%   IN:           options:  struct,  options the tasks will run with
%                 dataFile: struct,  data file initiated in initDataFile.m
%                 trial:    integer, trial number
%
%   OUT:          options:  struct, updated options struct
%                 abort:    logical, returns = 1 if the task is aborted
%
%   AUTHOR:       Coded by: Frederike Petzschner,   April 2017
%	              Amended:  Kathatina V. Wellstein, December 2019 for VAGUS study,
%	                                                XX.2024 for SAPS study
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

keyCode = eventListener.commandLine.detectKey(options.KBNumber, options.expType, option.OS);

if isempty(trial)
    trial = 1;
end

if any(keyCode==options.keys.escape)
        sca
        tools.logEvent('exp','abort',dataFile,X,trial);
        eventListener.commandLine.wait2(3)
        abort = 1;
        disp('Experiment was aborted.')
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        return;
else
    abort = 0;
end

end
