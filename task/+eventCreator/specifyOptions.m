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
%   AUTHOR:     Katharina V. Wellstein, October 2024
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
options.task.name = 'SAP';

%specify the task number (i.e. the place in the tasks sequence this task has) in this study
options.task.sequenceIdx    = 1;
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
        options.task.nAvatars = max(options.task.inputs(:,1));
        options.task.nTrials  = size(options.task.inputs,1);
        rng(1,"twister");
        options.task.slidingBarStart = rand(options.task.nTrials,1)*100;

        options.task.showPoints = 0;
        if strcmp(expType,'behav')
            options.doKeyboard = 1;
        else
            options.doKeyboard = 0;
        end

    case 'practice'
        % stimulus durations
        % options.screen.rect   = [0, 0, 1200, 600];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.inputs   = [1 2 2 1 2 1 ; 1 0 1 1 0 1]';
        options.task.nAvatars = max(options.task.inputs(:,1));

        options.task.showPoints = 1;

        if strcmp(expType,'behav')
            options.task.nTrials  = 6;
            options.doKeyboard    = 1;
        else
            options.task.nTrials  = 4;
            options.doKeyboard    = 0;
        end
        rng(1,"twister");
        options.task.slidingBarStart = rand(options.task.nTrials,1)*100;

    case 'debug'
        % stimulus durations
        options.screen.rect   = [20, 10, 900, 450];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        % options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';
        options.task.nAvatars = max(options.task.inputs(:,1));
        options.task.nTrials  = size(options.task.inputs,1);
        options.task.slidingBarStart = rand(options.task.nTrials,1)*100;

        options.task.showPoints = 1;
        options.doKeyboard      = 1;

    otherwise
        disp(' ...no valid expMode specified, using debug options... ')
        options.screen.rect   = [20, 10, 900, 450];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';
        options.task.nAvatars = max(options.task.inputs(:,1));
        options.task.nTrials  = size(options.task.inputs,1);
        options.task.slidingBarStart = rand(options.task.nTrials,1);

        options.task.showPoints = 1;
        options.doKeyboard      = 1;
end

%% Select Stimuli based on Randomisation list
RandTable   = readtable([pwd,'/+eventCreator/stimulus_randomisation.xlsx']);
rowIdx      = find(RandTable.PID==str2num(PID));
avatars     = RandTable(rowIdx,:);
options.task.avatarArray = string(options.task.inputs(:,1));

if strcmp(expMode,'practice')
    cellName  = 'practice_a';
elseif strcmp(expMode,'experiment')
    cellName  = 'experiment_a';
end

for iAvatar = 1:options.task.nAvatars
    options.task.avatarArray(strcmp(options.task.avatarArray,num2str(iAvatar))) = string(avatars.([cellName,num2str(iAvatar)]));
end

%% options screen
options.screen.white  = WhiteIndex(options.screen.number);
options.screen.black  = BlackIndex(options.screen.number);
options.screen.grey   = options.screen.white / 2;
options.screen.task   = options.screen.grey / 2;
options.screen.inc    = options.screen.white - options.screen.grey;

switch expMode
    case 'experiment'
        options.screen.qText       = '\n frequency of smiling back?';
        options.screen.startPredictText = '\n smile or neutral?';
        options.screen.stopPredictText  = '\n stopped smiling?';


    case 'practice'
        if strcmp(expType,'behav')
            options.screen.qText       = ['\n How often does this person usually smile back when receiving a smile? ' ...
                '\n Use your other index finger to stop the sliding bar.'];
            options.screen.startPredictText = ['Do you choose to smile at this person because you think that they will smile back?' ...
                '\n -> ',handedness,' index finger to start smiling & other index finger once you stopped smiling.' ...
                '\n -> ',handedness,' middle finger if you choose not to smile because you they won''t smile back.'];
        else
            if strcmp(handedness,'right')
                options.screen.qText       = ['\n How often does this person usually smile back when receiving a smile? ' ...
                    '\n Use your left index finger to stop the sliding bar.'];
            else
                options.screen.qText       = ['\n How often does this person usually smile back when receiving a smile? ' ...
                    '\n Use your right index finger to stop the sliding bar.'];
            end
            options.screen.startPredictText = ['Choose to smile: use ',handedness,' index finger to start & other index finger once your face is neutral again.' ...
                '\n Choose to stay neutral: indicate choice with ',handedness,' middle finger.'];
        end
end

if options.task.sequenceIdx<options.task.maxSequenceIdx
    options.screen.firstTargetText = ['You collected more than ', options.task.firstTarget,' points! ' ...
        '\n You will receive an additional AUD 5 to your reimbursement if you keep this score.'];
    options.screen.finalTargetText = ['You collected more than ', options.task.finalTarget,' points! ' ...
        '\n You will receive an additional AUD 10 to your reimbursement if you keep this score.'];
    options.screen.noTagretText = ['You have not collected enough points to reach one of the reimbursed targets.' ...
        '\n Keep collecting points in the next task!'];
else
    options.screen.firstTargetText = ['You collected more than ', options.task.firstTarget,' points across all tasks! ' ...
        '\n You will receive an additional AUD 5 to your reimbursement.'];
    options.screen.finalTargetText = ['You collected more than ', options.task.finalTarget,' points across all tasks! ' ...
        '\n You will receive an additional AUD 10 to your reimbursement.'];
    options.screen.noTagretText = 'You have not collected enough points to reach one of the reimbursed targets.';
end

options.screen.pointsText = 'You collected the following amount of points: ';
options.screen.expEndText = ['Thank you! ' ...
    'You finished the ',options.task.name,' ',expMode,'.'];
options.screen.qTextL = '                       Never';
options.screen.qTextR = 'Always                      ';

%% options keyboard
% use KbDemo to identify kbName and Keycode
KbName('UnifyKeyNames')
switch expType
    case 'behav'
        options.keys.escape     = KbName('ESCAPE');

        if strcmp(handedness,'right')
            options.keys.startSmile = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
            options.keys.stopSmile  = KbName('LeftAlt');    % KeyCode: 226, non-dominant hand index finger
            options.keys.noSmile    = KbName('RightArrow'); % KeyCode: 79, dominant hand ring finger

        else
            options.keys.startSmile = KbName('LeftAlt');     % KeyCode: 226, dominant hand index finger
            options.keys.stopSmile  = KbName('LeftArrow');   % KeyCode: 37, non-dominant hand index finger
            options.keys.noSmile    = KbName('LeftControl'); % KeyCode: 224, dominant hand ring finger
        end

    case 'fmri'
        options.keys.escape     = KbName('ESCAPE');

        if strcmp(handedness,'right')
            options.keys.startSmile = KbName('1'); % CHANGE: This should dominant hand index finger
            options.keys.stopSmile  = KbName('3'); % CHANGE: This should non-dominant hand index finger
            options.keys.noSmile    = KbName('2'); % CHANGE: This should dominant hand ring finger
        else
            options.keys.startSmile = KbName('3'); % KeyCode: 226, dominant hand index finger
            options.keys.stopSmile  = KbName('2'); % KeyCode: 37, non-dominant hand index finger
            options.keys.noSmile    = KbName('4'); % KeyCode: 224, dominant hand ring finger
        end

    otherwise
        if strcmp(handedness,'right')
            options.keys.startSmile = KbName('LeftArrow');  % KeyCode: 37, dominant hand index finger
            options.keys.stopSmile  = KbName('LeftAlt');    % KeyCode: 226, non-dominant hand index finger
            options.keys.noSmile    = KbName('RightArrow'); % KeyCode: 79, dominant hand ring finger

        else
            options.keys.startSmile = KbName('LeftAlt');     % KeyCode: 226, dominant hand index finger
            options.keys.stopSmile  = KbName('LeftArrow');   % KeyCode: 37, non-dominant hand index finger
            options.keys.noSmile    = KbName('LeftControl'); % KeyCode: 224, dominant hand ring finger
        end
end

%% DURATIONS OF EVENTS
% CHANGE
if strcmp(expMode,'debug') % in ms
    options.dur.waitnxtkeypress = 2000; % in ms
    options.dur.showStimulus    = 500; % in ms
    options.dur.showSmile       = 15000;
    options.dur.showOutcome     = 500;
    options.dur.showPoints      = 1000;
    options.dur.showIntroScreen = 1000;
    options.dur.showReadyScreen = 200;
    options.dur.afterSmileITI   = randi([150,250],options.task.nTrials,1);
    options.dur.afterNeutralITI = randi([150,250],options.task.nTrials,1);
    options.dur.rtTimeout       = 500;
    options.dur.showWarning     = 500;
    options.dur.ITI             = randi([150,250],options.task.nTrials,1);
else % in ms
    options.dur.waitnxtkeypress = 5000; % in ms
    options.dur.showStimulus    = 500;  % in ms
    options.dur.showSmile       = 10000;
    options.dur.showOutcome     = 500;
    options.dur.showPoints      = 500;
    options.dur.showIntroScreen = 30000; % in ms
    options.dur.showReadyScreen =  1500;
    options.dur.afterSmileITI   = randi([1000,2000],options.task.nTrials,1);
    options.dur.afterNeutralITI = randi([1000,2000],options.task.nTrials,1);
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
options.files.namePrefix   = ['SNG_SAP_',PID,'_',expType];
options.files.savePath     = [options.paths.saveDir,filesep,expMode,filesep,options.files.projectID,PID];
mkdir(options.files.savePath);
options.files.dataFileExtension    = 'dataFile.mat';
options.files.optionsFileExtension = 'optionsFile.mat';
options.files.dataFileName    = [options.files.namePrefix,'_',options.files.dataFileExtension];
options.files.optionsFileName = [options.files.namePrefix,'_',options.files.optionsFileExtension];

end
