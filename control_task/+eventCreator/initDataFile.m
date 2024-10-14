function dataFile = initDataFile(PID,expType,expMode,handedness)

% -----------------------------------------------------------------------
% initDataFile.m initializes the datafile for this experiment
%
%   SYNTAX:       dataFile = initDataFile
%
%   OUT:          dataFile: struct, contains all variables, for which data
%                                   will be saved
%
%   SUBFUNCTIONS: GetSecs.m
%
%   AUTHOR:     Based on: Frederike Petzschner & Sandra Iglesias, 2017
%               Amended:  Katharina V. Wellstein, December 2019 for VAGUS study,
%	                                              XX.2024 for SAPS study
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
%

%% EXP METADATA
dataFile.descr.PPID    = PID;
dataFile.descr.date    = datetime;
dataFile.descr.expType = expType;
dataFile.descr.expMode = expMode;
dataFile.descr.handedness = handedness;

%% EVENTS 
% Time stamps and special occurences (e.g. "abort event")

dataFile.events.exp_startTime        = GetSecs;
dataFile.events.practice_startTime   = [];
dataFile.events.experiment_startTime = [];
dataFile.events.exp_abort            = [];
dataFile.events.exp_missedTrial      = []; logical(dataFile.events.exp_missedTrial);
dataFile.events.exp_stopCriterion    = []; logical(dataFile.events.exp_stopCriterion);
dataFile.events.exp_timeOut          = []; logical(dataFile.events.exp_timeOut);
dataFile.events.exp_end              = [];

%% TASK DATA
% COL 1: if smile predicted ==1, if neutral predicted == 0
dataFile.SAPCPrediction.rt        = zeros(200,1);
% COL 1: if smile response ==1, if neutral response == 0, COL 2: time point
dataFile.SAPCPrediction.response  = zeros(200,2);
dataFile.SAPCPrediction.congruent = zeros(200,1); % if congruent ==1, if incongurent == 0
% COL 1: response on sliding bar, COL 2: time point
dataFile.SAPCQuestion.response = zeros(200,2);
dataFile.SAPCQuestion.rt       = zeros(200,1);
dataFile.SAPCSummary.points    = 0;

end