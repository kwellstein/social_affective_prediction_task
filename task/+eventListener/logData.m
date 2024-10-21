function [X, dataFile] = logData(X,task,event,dataFile,trial)

% -----------------------------------------------------------------------
% logData.m logs data point X and a time stamp on each trial for each task
%
%   SYNTAX:       [X, dataFile] = eventListener.logData(X,task,event,dataFile,trial)
%
%   IN:           X:        any value, data to be stored
%                 task:     string, name of task for which event should be saved 
%                 event:    string, name of event which should be saved 
%                 dataFile: struct, data file initiated in initDataFile.m
%                 trial:    integer, trial number
%
%   OUT:          X:        any value, data point
%                 dataFile: struct, updated data file 
%
%   SUBFUNCTIONS: GetSecs.m
%
%   AUTHOR:     Coded by:    Katharina V. Wellstein, December 2019
%                            https://github.com/kwellstein
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

fieldName = dataFile.(task).(event);

switch event
    case'rt'
    fieldName(trial,:) = X;
    case 'response' 
    eventTime          = GetSecs() - dataFile.events.exp_startTime;
    fieldName(trial,:) = [X, eventTime];
    case 'congruent' 
    fieldName(trial,:) = X;
    X = sum(fieldName);
end

dataFile.(task).(event) = fieldName;
end