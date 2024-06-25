function dataFile = initDataFile(PID,expType,expMode)

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

%% EVENTS 
% Time stamps and special occurences (e.g. "abort event")

dataFile.events.exp_startTime     = GetSecs;
dataFile.events.intro_end         = [];
dataFile.events.exp_abort         = [];
dataFile.events.exp_missedTrial   = []; logical(dataFile.events.exp_missedTrial);
dataFile.events.exp_stopCriterion = []; logical(dataFile.events.exp_stopCriterion);
dataFile.events.exp_timeOut       = []; logical(dataFile.events.exp_timeOut);
dataFile.events.exp_end           = [];

%% TASK DATA
dataFile.data.smileRT     = zeros(1000,1);
dataFile.data.smileResp   = zeros(1000,1);
dataFile.data.congrResp   = zeros(1000,1);
dataFile.data.smiliness   = zeros(1000,1);


end