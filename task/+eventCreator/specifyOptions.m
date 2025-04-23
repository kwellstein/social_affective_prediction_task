function options = specifyOptions(options,PID,expMode,expType,handedness)

% -----------------------------------------------------------------------
% specifyOptions.m creates structs for the different stages in the task
%                  Change this file if you would like to change task settings
%
%   SYNTAX:     options = eventCreator.specifyOptions(PID,expMode,expType,handedness)
%
%   IN:    expMode:  - In 'practice' mode you are running the entire
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
%   OUT:    options:   struct containing general and task specific
%                        options
%
%   AUTHOR: Coded by: Katharina V. Wellstein, October 2024
%                     katharina.wellstein@newcastle.edu.au
%                     https://github.com/kwellstein
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
options.paths.inputDir = [pwd,filesep,'+eventCreator',filesep];
options.paths.tasksDir = ['..',filesep];
options.paths.saveDir  = [options.paths.tasksDir,'data',filesep];
options.paths.randFile = [pwd,filesep,'+eventCreator',filesep,'randomisation.xlsx'];

%% specifing experiment mode specific settings
options.files.projectID = 'SAPS_';
options.task.name       = 'SAP';

%% DATAFILES & PATHS
options.files.namePrefix   = ['SNG_SAP_',PID,'_',expType];
options.files.savePath     = [options.paths.saveDir,expMode,filesep,options.files.projectID,PID,filesep];
mkdir(options.files.savePath);
options.files.dataFileExtension    = 'dataFile.mat';
options.files.optionsFileExtension = 'optionsFile.mat';
options.files.dataFileName    = [options.files.namePrefix,'_',options.files.dataFileExtension];
options.files.optionsFileName = [options.files.namePrefix,'_',options.files.optionsFileExtension];
options.files.eyeFileName     = [PID,options.task.name,'.edf'];


%% Settings for different experiment modes
switch expMode
    case 'experiment'
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.inputs   = readmatrix(fullfile([options.paths.inputDir,'input_sequence.csv']));
        options.task.nAvatars = max(options.task.inputs(:,1));
        options.task.nTrials  = 15;%size(options.task.inputs,1);
        rng(1,"twister");
        options.doEye = 0;
        options.doEMG = 0;
        options.doPPU = 1;
        options.task.showPoints = 0;

    case 'practice'
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.inputs   = [1 2 2 1 2 1 2 1; ...
            1 0 1 1 0 1 0 1]';
        options.task.nAvatars = max(options.task.inputs(:,1));

        if strcmp(expType,'behav')
            options.task.nTrials = numel(options.task.inputs(:,2));
        else
            options.task.nTrials = numel(options.task.inputs(:,2))/2;
        end

        options.task.showPoints = 0;
        options.doEye = 0;
        options.doEMG = 0;
        options.doPPU = 0;
end

%% STIMULI SELECTION based on randomisation list
stimRandTable = readtable(options.paths.randFile,'Sheet','stimuli');
rowIdx        = find(stimRandTable.PID==str2num(PID));
avatars       = stimRandTable(rowIdx,:);
options.task.avatarArray = string(options.task.inputs(:,1));

if strcmp(expMode,'practice')
    cellName  = 'practice_a';
elseif strcmp(expMode,'experiment')
    cellName  = 'experiment_a';
end

for iAvatar = 1:options.task.nAvatars
    options.task.avatarArray(strcmp(options.task.avatarArray,num2str(iAvatar))) = string(avatars.([cellName,num2str(iAvatar)]));
end

%% TASK SEQUENCE selection based on randomisation list
taskRandTable = readtable(options.paths.randFile,'Sheet','tasks');
rowIdx        = find(taskRandTable.PID==str2num(PID));
taskCol       = taskRandTable.(options.task.name);

%specify the task number (i.e. the place in the tasks sequence this task has) in this study
options.task.sequenceIdx    = taskCol(rowIdx);
%
if strcmp(expMode,'experiment')
    d = load([options.paths.saveDir,'practice',filesep,options.files.projectID,PID,filesep,'SNG_AAA_',PID,'_behav_dataFile.mat']);
    nTrials     = length(d.dataFile.AAAPrediction.response(:,1));
    nApproaches = sum(d.dataFile.AAAPrediction.response(:,1));

    if nApproaches/nTrials <0.35
        options.task.firstTarget    = 40;
        options.task.finalTarget    = 80;
        options.task.maxSequenceIdx = 2;
    else
        options.task.firstTarget    = 50;
        options.task.finalTarget    = 100;
        options.task.maxSequenceIdx = 3;
    end
else
    options.task.firstTarget    = 50;
    options.task.finalTarget    = 100;
    options.task.maxSequenceIdx = 3;
end

%% SCREEN and TEXT
options.screen.white  = WhiteIndex(options.screen.number);
options.screen.black  = BlackIndex(options.screen.number);
options.screen.grey   = options.screen.white / 2;
options.screen.task   = options.screen.grey / 2;
options.screen.inc    = options.screen.white - options.screen.grey;

switch expMode
    case 'experiment'
        options.screen.startPredictText = '\n smile or neutral?';

    case 'practice'
        options.screen.startPredictText = ['Do think that this person will smile back at you? Smile at the face and press' ...
            '\n ',handedness,' index finger once you are happy with your smile.'];
end

if options.task.sequenceIdx<options.task.maxSequenceIdx
    options.screen.firstTargetText = ['You collected more than ', num2str(options.task.firstTarget),' points! ' ...
        '\n You will receive an additional 5$ to your reimbursement if you keep this score.'];
    options.screen.finalTargetText = ['You collected more than ', num2str(options.task.finalTarget),' points! ' ...
        '\n You will receive an additional 10$ to your reimbursement if you keep this score.'];
    options.screen.noTagretText = ['You have not collected enough points to reach one of the reimbursed targets.' ...
        '\n Keep collecting points in the next task!'];
else
    options.screen.firstTargetText = ['You collected more than ', num2str(options.task.firstTarget),' points across all tasks! ' ...
        '\n You will receive an additional 5$ to your reimbursement.'];
    options.screen.finalTargetText = ['You collected more than ', num2str(options.task.finalTarget),' points across all tasks! ' ...
        '\n You will receive an additional 10$ to your reimbursement.'];
    options.screen.noTagretText = 'You have not collected enough points to reach one of the reimbursed targets.';
end

options.screen.pointsText = 'You collected the following amount of points: ';
options.screen.expEndText = ['Thank you! ' ...
    'You finished the ',options.task.name,' ',expMode,'.'];

% MESSAGES
options.messages.abortText     = 'the experiment was aborted';
options.messages.timeOut       = 'you did not answer in time';
options.messages.wrongButton   = 'you pressed the wrong button';


%% KEYBOARD
% use KbDemo to identify kbName and Keycode
KbName('UnifyKeyNames');


if strcmp(options.PC,'EEGLab_Computer')
    if strcmp(handedness,'right')
        options.keys.smile   = KbName('4$');  % KeyCode: 70, dominant hand index finger
        options.keys.noSmile = KbName('3#');  % KeyCode: 66, non-dominant hand index finger
    else
        options.keys.smile   = KbName('3#'); % KeyCode: 66, dominant hand index finger
        options.keys.noSmile = KbName('4$'); % KeyCode: 70, non-dominant hand index finger
    end
elseif strcmp(options.PC,'Scanner_Computer')
    if strcmp(expType,'behav')
        if strcmp(handedness,'right')
            options.keys.smile   = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
            options.keys.noSmile = KbName('LeftAlt');    % KeyCode: 226, non-dominant hand index finger

        else
            options.keys.smile   = KbName('LeftAlt');     % KeyCode: 226, dominant hand index finger
            options.keys.noSmile = KbName('LeftArrow');   % KeyCode: 37, non-dominant hand index finger
        end
    else
        options.keys.taskStart = KbName('5%');
        if strcmp(handedness,'right')
            options.keys.smile   = KbName('1!'); % CHANGE: This should dominant hand index finger
            options.keys.noSmile = KbName('4$'); % CHANGE: This should non-dominant hand index finger
        else
            options.keys.smile   = KbName('4$'); % KeyCode: 226, dominant hand index finger
            options.keys.noSmile = KbName('1!'); % KeyCode: 37, non-dominant hand index finger
        end
    end
else
    if strcmp(handedness,'right')
        options.keys.collect = KbName('RightArrow');  % KeyCode: 37, dominant hand index finger
        options.keys.reject  = KbName('LeftAlt'); % KeyCode: 79, dominant hand ring finger

    else
        options.keys.collect = KbName('LeftAlt');     % KeyCode: 226, dominant hand index finger
        options.keys.reject  = KbName('RightArrow'); % KeyCode: 224, dominant hand ring finger
    end
end

options.keys.escape    = KbName('ESCAPE');
options.keys.space     = KbName('space');

%% DURATIONS OF EVENTS
if  strcmp(expMode,'practice')
    options.dur.waitnxtkeypress = 5000; % in ms
    options.dur.showStimulus    = 500; % in ms
    options.dur.showOutcome     = 500;
    options.dur.showPoints      = 500;
    options.dur.showIntroScreen = 20000; % in ms
    options.dur.showShortIntro  = 10000;
    options.dur.showShortInfoTxt= 1200;
    options.dur.showReadyScreen = 1000;
    options.dur.showEyeBaseline = 3000;
    options.dur.showMRIBaseline = 0;
    options.dur.afterActionITI  = randi([2000,3500],options.task.nTrials,1);
    options.dur.rtTimeout       = 10000;
    options.dur.showWarning     = 1500;
    options.dur.ITI             = randi([2500,3500],options.task.nTrials,1);  % Jayson: mean 2000, min 400s, max 11600 used OptimizeX, OptSec2
else % in ms
    options.dur.waitnxtkeypress = 5000; % in ms
    options.dur.showStimulus    = 500; % in ms
    options.dur.showOutcome     = 500;
    options.dur.showPoints      = 500;
    options.dur.showIntroScreen = 20000; % in ms
    options.dur.showShortIntro  = 10000;
    options.dur.showShortInfoTxt= 1200;
    options.dur.showReadyScreen = 1000;
    options.dur.showEyeBaseline = 3000;
    options.dur.showMRIBaseline = 10000;
    options.dur.afterActionITI  = randi([1000,2000],options.task.nTrials,1);
    options.dur.rtTimeout       =  2500;
    options.dur.showWarning     =  1500;
    options.dur.ITI             = randi([2500,3500],options.task.nTrials,1);
end

options.dur.taskDur = options.task.nTrials*(options.dur.showStimulus+options.dur.showOutcome)...
    +sum(options.dur.afterActionITI)+sum(options.dur.ITI);
options.dur.expDur = options.dur.taskDur + options.dur.showMRIBaseline+options.dur.showIntroScreen ...
    + options.dur.showShortIntro + options.dur.showShortInfoTxt;
options.dur.mriDur = options.dur.taskDur + options.dur.showMRIBaseline+options.dur.showShortInfoTxt;


%% DEFINE EMG triggers

if options.doEMG == 1
    options.EMG.expStart     = 1;
    options.EMG.expStop      = 2;
    options.EMG.trialStart   = 3;
    options.EMG.smileStart   = 4;
    options.EMG.neutralStart = 5;
    options.EMG.respStop     = 6;
    options.EMG.trialStop    = 9;
end

% hardware identifiers
options.hardware.tracker = 'T60';
end
