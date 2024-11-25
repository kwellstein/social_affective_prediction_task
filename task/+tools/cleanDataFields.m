function dataFile = cleanDataFields(dataFile,trial,predictField,actionField)

% -----------------------------------------------------------------------
% cleanDataFields.m eliminates excess zeros from data vectors
%
%   SYNTAX:       dataFile = tools.cleanDataFields(dataFile,trial,predictField,questField,smileTimeField)
%
%   IN:           dataFile:       struct, contains all variables, for which data
%                                   will be saved
%                 trial:          integer, trial number
%                 predictField:   string, field name for prediction data
%                 smileTimeField: string, field name for length of smile data
%
%   OUT:          dataFile: struct, updated data file
%
%
%   AUTHOR:     Coded by: Katharina V. Wellstein, December 2019
%                         Amended for SAPS study October 2024
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

dataFile.(predictField).congruent = dataFile.(predictField).congruent(1:trial,:);
dataFile.(predictField).response  = dataFile.(predictField).response(1:trial,:);
dataFile.(predictField).rt        = dataFile.(predictField).rt(1:trial,:);
dataFile.(actionField).rt         = dataFile.(actionField).rt(1:trial,:);

dataFile.events.task_startTime       = dataFile.events.task_startTime; 
dataFile.events.stimulus_startTime   = dataFile.events.stimulus_startTime(1:trial,:);
dataFile.events.predKey_startTime    = dataFile.events.predKey_startTime(1:trial,:);
dataFile.events.predAction_startTime = dataFile.events.predAction_startTime(1:trial,:);
dataFile.events.predAction_stopTime  = dataFile.events.predAction_stopTime(1:trial,:);
dataFile.events.outcome_startTime    = dataFile.events.outcome_startTime(1:trial,:);
dataFile.events.iti_startTime        = dataFile.events.iti_startTime(1:trial,:); 

dataFile.events.exp_abort            = dataFile.events.exp_abort(1:trial,:);
dataFile.events.exp_missedTrial      = dataFile.events.exp_missedTrial(1:trial,:);
dataFile.events.exp_questWrongButton = dataFile.events.exp_questWrongButton(1:trial,:);
dataFile.events.exp_timeOut          = dataFile.events.exp_timeOut(1:trial,:);

end
