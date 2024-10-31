function dataFile = logEvent(task,event,dataFile,X,trial)

% -----------------------------------------------------------------------
% logEvent.m logs timing of events specified in eventName and saves the data
%
%   SYNTAX:       dataFile = eventListener.logEvent(task,event,dataFile,X,trial)
%
%   IN:           task:     string, name of task for which event should be saved 
%                 event:    string, name of event which should be saved 
%                 dataFile: struct, data file initiated in initDataFile.m
%                 X:        logical, data to be stored in logical array
%                 trial:    integer, current trial number
%
%   OUT:          dataFile: struct, updated data file 
%
%   SUBFUNCTIONS: GetSecs.m
%
%   AUTHOR:     Based on: Frederike Petzschner & Sandra Iglesias, 2017
%               Amended:  Katharina V. Wellstein, October 2024
%                         katharina.wellstein@newcastle.edu.au
%                         https://github.com/kwellstein
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

if strcmp(task,'debug')
   task = 'practice'; 
   eventName   = [task event];
else
    eventName   = [task event]; 
end


if   islogical(dataFile.events.(eventName))
     dataFile.events.(eventName(trial)) = X;
     
    else  
    eventTime = GetSecs() - dataFile.events.exp_startTime;
    dataFile.events.(eventName)           = eventTime;

end

end