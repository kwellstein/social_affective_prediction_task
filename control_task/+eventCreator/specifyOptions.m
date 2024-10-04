function options = specifyOptions(PID,expMode,expType)
% -----------------------------------------------------------------------
% specifyOptions.m creates structs for the different stages in the task
%                  Change this file if you would like to change task settings
%
%   SYNTAX:     options = specifyOptions(expMode,stairType)
%
%   IN:         expMode:   string, 'debug' or 'experiment'
%               stairType: string, 'simpleUp','simpleDown','interleaved'
%
%   OUT:        options: struct containing general and task specific
%                        options
%
%   AUTHOR:     Katharina V. Wellstein, XX 2024
%
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

%% specify paths

options.paths.codeDir  = pwd;
options.paths.inputDir = '/Users/kwellste/projects/SEPAB/tasks/social_affective_prediction_task/HGF_simulations/generated_data/';
options.paths.saveDir  = '/Users/kwellste/projects/SEPAB/tasks/data/';
%% specifing experiment mode specific settings

options.task.name = 'SAPC';
options.task.firstTarget = 50;
options.task.finalTarget = 100;

switch expMode
    case 'experiment'
        % stimulus durations
        % options.screen.rect   = [0, 0, 1200, 600];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.showPoints = 0;
        options.task.nEggs = 3; % softcode!
        options.task.inputs   = readmatrix(fullfile([options.paths.inputDir,'input_sequence_',options.task.name,'.csv']));
        options.task.nTrials  = size(options.task.inputs,1);

        if strcmp(expType,'behav')
            options.doKeyboard = 1;
        else
            options.doKeyboard    = 0;
        end

    case 'practice'
        % stimulus durations
        % options.screen.rect   = [0, 0, 1200, 600];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.showPoints = 1;
        options.task.nEggs = 2;
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';

        if strcmp(expType,'behav')
            options.task.nTrials  = 8;
            options.doKeyboard = 1;
        else
            options.task.nTrials  = 4;
        end

    case 'debug'
        % stimulus durations
        options.screen.rect   = [20, 10, 900, 450];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        % options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.showPoints = 1;
        options.task.nTrials  = 8;
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';
        options.task.nEggs = 2;
        options.doKeyboard = 1;

    otherwise
        disp(' ...no valid expMode specified, using debug options... ')
        options.screen.rect   = [20, 10, 900, 450];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.task.showPoints = 1;
        options.task.nTrials  = 8;
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';
        options.task.nEGGS = 2;
        options.doKeyboard = 1;
end


%% Select Stimuli based on Randomisation list
RandTable = readtable([pwd,'/+eventCreator/stimulus_randomisation.xlsx']);
rowIdx    = find(RandTable.PID==str2num(PID));
eggs      = RandTable(rowIdx,:);
options.task.eggArray = string(options.task.inputs(:,1));

if strcmp(expMode,'debug')
    cellName  = 'fmri_experiment_a';
elseif strcmp(expType,'behav') || strcmp(expMode,'experiment')
    cellName  = 'fmri_experiment_a';
else
    cellName  = [expType,'_',expMode,'_a'];
end

for iEgg = 1:options.task.nEggs
    options.task.eggArray(strcmp(options.task.avatarArray,num2str(iEgg))) = string(eggs.([cellName,num2str(iEgg)]));
end

%% options screen
options.screen.white  = WhiteIndex(options.screen.number);
options.screen.black  = BlackIndex(options.screen.number);
options.screen.grey   = options.screen.white / 2;
options.screen.task   = options.screen.grey / 2;
options.screen.inc    = options.screen.white - options.screen.grey;

switch expMode
    case 'experiment'
        options.screen.predictText    = 'collect?';
    case 'practice'
        options.screen.predictText = ['Do you choose to collect this egg because you believe you can resell it at your shop?' ...
            '\n Use your index finger to collect or your ring finger to reject the egg.'];
end

options.screen.firstTagetText = ['You reached ',options.task.firstTarget,' points! ' ...
    '\n This added AUD 5 to your reimbursement.'];
options.screen.finalTagetText = ['You reached ',options.task.finalTarget,' points! ' ...
    '\n This added another AUD 5 to your reimbursement.'];
options.screen.expEndText     = ['Thank you! ' ...
    'You finished the ',options.task.name, ' ',expMode, '.'];

%% options keyboard
% use KbDemo to identify kbName and Keycode
KbName('UnifyKeyNames')
switch expType
    case 'behav'
        if strcmp(handedness,'right')
            options.keys.collect = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
            options.keys.reject  = KbName('RightArrow'); % KeyCode: 79, dominant hand ring finger

        else
            options.keys.collect = KbName('LeftAlt');     % KeyCode: 226, dominant hand index finger
            options.keys.reject  = KbName('LeftControl'); % KeyCode: 224, dominant hand ring finger
        end

    case 'fmri'
        if strcmp(handedness,'right')
            options.keys.collect = KbName('1');   % CHANGE: This should dominant hand index finger
            options.keys.reject  = KbName('2'); % CHANGE: This should dominant hand ring finger
        else
            options.keys.collect = KbName('3');     % KeyCode: 226, dominant hand index finger
            options.keys.reject  = KbName('4'); % KeyCode: 224, dominant hand ring finger
        end

    otherwise
        if strcmp(handedness,'right')
            options.keys.collect = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
            options.keys.reject  = KbName('RightArrow'); % KeyCode: 79, dominant hand ring finger

        else
            options.keys.collect = KbName('LeftAlt');     % KeyCode: 226, dominant hand index finger
            options.keys.reject  = KbName('LeftControl'); % KeyCode: 224, dominant hand ring finger
        end
end

options.keys.escape     = KbName('ESCAPE');

%% DURATIONS OF EVENTS
% CHANGE
if strcmp(expMode,'debug')
    options.dur.waitnxtkeypress = 2000; % in ms
    options.dur.showStimulus    = 500; % in ms
    options.dur.showSmile       = 2;    % in sec
    options.dur.showOutcome     = 500;
    options.dur.showPoints      = 1000;
    options.dur.showIntroScreen = 1000;
    options.dur.showReadyScreen = 200;
    options.dur.rtTimeout       = 500;
    options.dur.showWarning     = 500;
    options.dur.ITI             = randi([150,250],options.task.nTrials,1);
else
    options.dur.waitnxtkeypress = 5000; % in ms
    options.dur.showStimulus    = 400;  % in ms
    options.dur.showSmile       = 1000;   % in sec
    options.dur.showOutcome     = 500;
    options.dur.showPoints      = 500;
    options.dur.showIntroScreen = 30000; % in ms
    options.dur.showReadyScreen =  1500;
    options.dur.rtTimeout       =  1500;
    options.dur.showWarning     =  1000;
    options.dur.ITI             = randi([1500,2500],options.task.nTrials,1); % Jayson: mean 2000, min 400s, max 11600 used OptimizeX, OptSec2
end

%% MESSAGES
options.messages.abortText     = 'the experiment was aborted';
options.messages.timeOut       = 'you did not answer in time';
options.messages.wrongButton   = 'you pressed the wrong button';


%% DATAFILES & PATHS
options.files.projectID    = 'SAPS_';
options.files.namePrefix   = ['SNG_SAPC_',PID,'_',expType];
options.files.savePath     = [pwd,'/data/',expMode,'/',options.files.projectID,PID];
mkdir(options.files.savePath);
options.files.dataFileName = [options.files.namePrefix,'_dataFile.mat'];
options.files.dataFileName = [options.files.namePrefix,'_optionsFile.mat'];

end
