function SAP_task_main

%% _______________________________________________________________________________%
%% MAIN FUNCTION for Social-Affective Prediction (SAP) Task
%
% SYNTAX:  ....
%
% AUTHOR:  Coded by: Katharina V. Wellstein, XX.2024,
%                    katharina.wellstein@newcastle.edu.au
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
%% _______________________________________________________________________________%
% this script allows the experimenter to specify information on the mode the
%               task will be run in.
%
% SYNTAX:  XX
%
% OUT:      expMode: - In 'debug' mode timings are shorter, and the experiment
%                     won't be full screen. You may use breakpoints.
%                   - In 'experiment' mode you are running the entire
%                     experiment as it is intended
%
%           PPID:    A 4-digit integer (0001:0999) PPIDs have
%                   been assigned to participants a-priori
%
%           visitNo: A 1-digit integer (1:4). Each participant will be doing
%                   this task 4 times.
%
%  AUTHOR:  Coded by: Katharina V. Wellstein, XX.2024
%                     katharina.wellstein@newcastle.edu.au
% _______________________________________________________________________________%

%% INITIALIZE
close all;
clearvars;
clc;

diary on
% add toolbox to path
addpath(genpath(fullfile([pwd,'/Psychtoolbox-3'])));

%% SPECIFY inputs
expMode    = input('Enter ''debug'', ''practice'' or ''experiment'' ','s');
expType    = input('Enter ''behav'' or ''fmri'' ','s');
PID        = input('Enter participant id (PID)','s');
handedness = input('Enter participant''s handedness, ''right'' or ''left''','s');

%% Check if inputs are correct

if strcmp(expMode, 'debug')     % expMode check
    disp('You are running the SAP task in DEBUG mode');
elseif strcmp(expMode, 'experiment')
    disp('You are running the SAP task in EXPERIMENT mode');
elseif strcmp(expMode, 'practice')
    disp('You are running the PRACTICE of the SAP task');
else
    expMode = input('Your input is not correct, type either ''debug'',''practice'' or ''experiment'' :','s');
end                             % END of mode check

if strcmp(expType, 'behav')% expType check
    disp('You are running the SAP task behaviorally');
elseif strcmp(expType, 'fmri')
    disp('You are running the the SAP task in the scanner');
else
    expType = input('Your input is not correct, type either ''behav'' or ''fmri'' :','s');
end % END expType check

if ~numel(PID) == 4 % PPID check
    disp('PID has to be a 4 digit string');
end                  % END PPID check

if strcmp(handedness, 'right')% handedness check
    disp('The participant''s dominant hand is the right one');
elseif strcmp(handedness, 'left')
    disp('The participant''s dominant hand is the left one');

else
    expType = input('Your input is not correct, type either ''right'' or ''left'' :','s');
end % END expType check

%% SETUP DATAFILE
dataFile = eventCreator.initDataFile(PID,expType,expMode,handedness);

%% SETUP OPTIONS
options  = eventCreator.specifyOptions(PID,expMode,expType,handedness);

%% SETUP ENVIRONMENT
options = tools.prepEnvironment(options);
options = eventCreator.initScreen(options,expMode);
stimuli = eventCreator.initVisuals(options,expMode,expType);

%% RUN TASK
runTask(stimuli,expMode,expType,options,dataFile);

Screen('CloseAll');

end
