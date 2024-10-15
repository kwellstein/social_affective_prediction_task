function options = specifyOptions(PID,expMode,expType,handedness)
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
options.paths.inputDir = [pwd,filesep,'+eventCreator/'];
options.paths.tasksDir = '/Users/kwellste/projects/SEPAB/tasks/';
options.paths.saveDir  = [options.paths.tasksDir,'data/'];

%% specifing experiment mode specific settings
options.task.name = 'SAPC';

%specify the task number (i.e. the place in the tasks sequence this task has) in this study
options.task.sequenceIdx    = 2;
options.task.maxSequenceIdx = 3;
options.task.firstTarget = 50;
options.task.finalTarget = 100;

switch expMode
    case 'experiment'
        % stimulus durations
        % options.screen.rect   = [0, 0, 1200, 600];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.inputs   = readmatrix(fullfile([options.paths.inputDir,'input_sequence.csv']));
        options.task.nEggs    = max(options.task.inputs(:,1));
        options.task.nTrials  = size(options.task.inputs,1);        
        rng(1,"twister");
        options.task.slidingBarStart = rand(options.task.nTrials,1);

        options.task.showPoints = 0;
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
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';
        options.task.nEggs    = max(options.task.inputs);
        options.task.nTrials  = size(options.task.inputs,1);
        rng(1,"twister");
        options.task.slidingBarStart = rand(options.task.nTrials,1);

        options.task.showPoints = 1;

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
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';
        options.task.nEggs    = max(options.task.inputs);
        options.task.nTrials  = size(options.task.inputs,1);
        rng(1,"twister");
        options.task.slidingBarStart = rand(options.task.nTrials,1);

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
rowIdx    = find(RandTable.PID==str2double(PID));
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
    options.task.eggArray(strcmp(options.task.eggArray,num2str(iEgg))) = string(eggs.([cellName,num2str(iEgg)]));
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
        options.screen.qText       = ['\n How often do you make a profit from reselling this type of egg? ' ...
            '\n Use your other index finger to stop the sliding bar.'];
    case 'practice'
        options.screen.qText       = ['\n How often do you make a profit from reselling this type of egg? ' ...
            '\n Use your other index finger to stop the sliding bar.'];
        options.screen.predictText = ['Do you choose to collect this egg because you believe you can resell it at your shop?' ...
            '\n Use your index finger to collect or your middle finger to reject the egg.'];
end

if options.task.sequenceIdx<options.task.maxSequenceIdx
    options.screen.firstTagetText = ['You collected more than ', options.task.firstTarget,' points! ' ...
        '\n You will receive an additional AUD 5 to your reimbursement if you keep this score.'];
    options.screen.finalTagetText = ['You collected more than ', options.task.finalTarget,' points! ' ...
        '\n You will receive an additional AUD 10 to your reimbursement if you keep this score.'];
    options.screen.noTagetText = ['You have not collected enough points to reach one of the reimbursed targets.' ...
        '\n Keep collecting points in the next task!'];
else
    options.screen.firstTagetText = ['You collected more than ', options.task.firstTarget,' points across all tasks! ' ...
        '\n You will receive an additional AUD 5 to your reimbursement.'];
    options.screen.finalTagetText = ['You collected more than ', options.task.finalTarget,' points across all tasks! ' ...
        '\n You will receive an additional AUD 10 to your reimbursement.'];
    options.screen.noTagetText = 'You have not collected enough points to reach one of the reimbursed targets.';
end

options.screen.pointsText = 'You collected the following amount of points: ';
options.screen.qTextL = '                       Never';
options.screen.qTextR = 'Always                      ';
options.screen.expEndText     = ['Thank you! ' ...
    'You finished the ',options.task.name, '/ Egg task ',expMode, '.'];

%% options keyboard
% use KbDemo to identify kbName and Keycode
KbName('UnifyKeyNames')
switch expType
    case 'behav'
        if strcmp(handedness,'right')
            options.keys.collect = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
            options.keys.reject  = KbName('RightArrow'); % KeyCode: 79, dominant hand middle finger
            options.keys.stop    = KbName('LeftAlt');    % KeyCode: 226, dominant hand index finger
        else
            options.keys.collect = KbName('LeftAlt');     % KeyCode: 226, dominant hand index finger
            options.keys.reject  = KbName('LeftControl'); % KeyCode: 224, dominant hand ring finger
            options.keys.stop    = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
        end

    case 'fmri'
        if strcmp(handedness,'right')
            options.keys.collect = KbName('1'); % CHANGE: This should dominant hand index finger
            options.keys.reject  = KbName('2'); % CHANGE: This should dominant hand middle finger
            options.keys.stop    = KbName('3'); % KeyCode: 226, dominant hand index finger
        else
            options.keys.collect = KbName('3'); % KeyCode: 226, dominant hand index finger
            options.keys.reject  = KbName('4'); % KeyCode: 224, dominant hand middle finger
            options.keys.stop    = KbName('1'); % CHANGE: This should dominant hand index finger
        end

    otherwise
        if strcmp(handedness,'right')
            options.keys.collect = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
            options.keys.reject  = KbName('RightArrow'); % KeyCode: 79, dominant hand middle finger
            options.keys.stop    = KbName('LeftAlt');    % KeyCode: 226, dominant hand index finger
        else
            options.keys.collect = KbName('LeftAlt');     % KeyCode: 226, dominant hand index finger
            options.keys.reject  = KbName('LeftControl'); % KeyCode: 224, dominant hand ring finger
            options.keys.stop    = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
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
    options.dur.showChoiceITI   = randi([500,1500],options.task.nTrials,1);
    options.dur.showOutcome     = 500;
    options.dur.showPoints      = 500;
    options.dur.showIntroScreen = 50000; % in ms
    options.dur.showReadyScreen =  1500;
    options.dur.rtTimeout       =  1500;
    options.dur.showWarning     =  1000;
    options.dur.ITI             = randi([500,1500],options.task.nTrials,1); % Jayson: mean 2000, min 400s, max 11600 used OptimizeX, OptSec2
end

%% MESSAGES
options.messages.abortText     = 'the experiment was aborted';
options.messages.timeOut       = 'you did not answer in time';
options.messages.wrongButton   = 'you pressed the wrong button';


%% DATAFILES & PATHS
options.files.projectID    = 'SAPS_';
options.files.namePrefix   = ['SNG_SAPC_',PID,'_',expType];
options.files.savePath     = [options.paths.saveDir,filesep,expMode,filesep,options.files.projectID,PID];
mkdir(options.files.savePath);
options.files.dataFileExtension    = 'dataFile.mat';
options.files.optionsFileExtension = 'optionsFile.mat';
options.files.dataFileName    = [options.files.namePrefix,'_',options.files.dataFileExtension];
options.files.optionsFileName = [options.files.namePrefix,'_',options.files.optionsFileExtension];

end
