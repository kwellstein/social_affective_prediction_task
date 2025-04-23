function SAPC_task_main
%% _______________________________________________________________________________%
%% MAIN Function for Social-Affective Prediction Control (SAPC) Task
% this script allows the experimenter to specify information regarding how
% the task will be run
%
% SYNTAX:  SAPC_task_main
%
% OUT:      expMode: - In 'debug' mode timings are shorter, and the experiment
%                     won't be full screen. You may use breakpoints.
%                    - In 'practice' mode you are running the entire
%                     the practice round as it has been specified in
%                     specifyOptions.m
%                    - In 'experiment' mode you are running the entire
%                     experiment as it has been specified in
%                     specifyOptions.m
%
%           expType: - 'behav': use keyboard and different instructions and
%                       more as specified in specifyOptions.m
%                    - 'fmri': use button box and different instructions
%                       more as specified in specifyOptions.m
%
%           PID:    A 4-digit integer (0001:1999) PPIDs have
%                    been assigned to participants a-priori
%
%           handedness: 'left' or 'right', influences keys used for
%                       responding
%
%  AUTHOR:  Coded by: Katharina V. Wellstein, October 2024
%                     katharina.wellstein@newcastle.edu.au
%                     https://github.com/kwellstein
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
% _______________________________________________________________________________

%% INITIALIZE
close all;
clearvars;
clc;

% open debug functions
edit debug_noResponse.m
edit debug_closePorts.m

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
    disp('You are running the SAPC task in DEBUG mode');
elseif strcmp(expMode, 'experiment')
    disp('You are running the SAPC task in EXPERIMENT mode');
elseif strcmp(expMode, 'practice')
    disp('You are running the PRACTICE of the SAPC task');
else
    expMode = input('Your input is not correct, type either ''debug'',''practice'' or ''experiment'' :','s');
end                             % END of mode check

if strcmp(expType, 'behav')% expType check
    disp('You are running the SAPC task behaviorally');
elseif strcmp(expType, 'fmri')
    disp('You are running the the SAPC task in the scanner');
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


%% SETUP ENVIRONMENT
options = tools.prepEnvironment;

%% SETUP OPTIONS
options  = eventCreator.specifyOptions(options,PID,expMode,expType,handedness);

options = eventCreator.initScreen(options,expMode);
stimuli = eventCreator.initVisuals(options,expMode,expType);

%% START EyeTracker
if options.doEye
    options.el = EyelinkInitDefaults(options.screen.windowPtr);
    EyelinkUpdateDefaults(options.el)
    constants.eyelink_data_fname    = options.files.eyeFileName;
    [options.el, options.exit_flag] = tools.setupEyeTracker(options.hardware.tracker, options.screen, constants);
end

%% RUN TASK
runTask(stimuli,expMode,expType,options,dataFile);
ListenChar(0);
Screen('CloseAll');

end