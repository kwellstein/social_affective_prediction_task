function dataFile = initDataFile(PID,expType,expMode,handedness)

% -----------------------------------------------------------------------
% initDataFile.m initializes the datafile for this experiment
%
%   SYNTAX:       dataFile = eventCreator.initDataFile(PID,expType,expMode,handedness)
%
%   IN:    expMode:  - In 'debug' mode timings are shorter, and the experiment
%                      won't be full screen. You may use breakpoints.
%                    - In 'practice' mode you are running the entire
%                      the practice round as it has been specified in
%                      specifyOptions.m
%                    - In 'experiment' mode you are running the entire
%                      experiment as it has been specified in
%                      specifyOptions.m
%
%           expType: - 'behav': use keyboard and different instructions and
%                       more as specified in specifyOptions.m
%                    - 'fmri': use button box and different instructions
%                       more as specified in specifyOptions.m
%
%           PID:        A 4-digit integer (0001:1999) PPIDs have
%                       been assigned to participants a-priori
%
%           handedness: 'left' or 'right', influences keys used for responding
%
%   OUT:    dataFile: struct, contains all variables, for which data will be saved
%
%
%   SUBFUNCTIONS: GetSecs.m
%
%   AUTHOR:     Katharina V. Wellstein, December 2019 for VAGUS study,
%	            Amended for SAPS study, October 2024
%                         katharina.wellstein@newcastle.edu.au
%                         https://github.com/kwellstein
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

% get date and time

dataFile.descr.PPID       = PID;
dataFile.descr.date       = extractBefore(char(datetime('now','InputFormat','dd-mm-yyyy')),12);
dataFile.descr.expType    = expType;
dataFile.descr.expMode    = expMode;
dataFile.descr.handedness = handedness;

%% EVENTS 
% Time stamps and special occurences (e.g. "abort event")

dataFile.events.exp_startTime        = GetSecs;
dataFile.events.task_startTime       = strings(200,1);
dataFile.events.stimulus_startTime   = strings(200,1);
dataFile.events.slider_startTime     = strings(200,1);
dataFile.events.predKey_startTime    = strings(200,1);
dataFile.events.predAction_startTime = strings(200,1);
dataFile.events.predAction_stopTime  = strings(200,1); 
dataFile.events.outcome_startTime    = strings(200,1);
dataFile.events.iti_startTime        = strings(200,1);
dataFile.events.exp_abort            = false(200,1);
dataFile.events.exp_missedTrial      = false(200,1);
dataFile.events.exp_questWrongButton = false(200,1);
dataFile.events.exp_timeOut          = false(200,1);
dataFile.events.exp_end              = [];

%% TASK DATA
% COL 1: if smile predicted ==1, if neutral predicted == 0
dataFile.SAPPrediction.rt       = zeros(200,1);
dataFile.SAPAction.rt           = zeros(200,1);
% COL 1: if smile response ==1, if neutral response == 0, COL 2: time point
dataFile.SAPPrediction.response  = zeros(200,2);
dataFile.SAPPrediction.congruent = zeros(200,1); % if congruent ==1, if incongurent == 0
% COL 1: response on sliding bar, COL 2: time point
dataFile.SAPQuestion.response = zeros(200,2);
dataFile.SAPQuestion.rt       = zeros(200,1);
dataFile.Summary.points    = 0;

end