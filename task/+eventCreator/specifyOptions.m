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

switch expMode
    case 'experiment'
        % stimulus durations
        % options.screen.rect   = [0, 0, 1200, 600];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.inputs   = readmatrix(fullfile([options.paths.inputDir,'input_sequence.csv']));
        options.task.nTrials  = size(options.task.inputs);
        options.doKeyboard    = 0;
    case 'practice'
        % stimulus durations
        % options.screen.rect   = [0, 0, 1200, 600];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.screen.rect   = Screen('Rect', options.screen.number);
        options.task.nAvatars = 2;
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';

        if strcmp(expType,'behav')
            options.task.nTrials  = 10;
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
        options.task.nTrials  = 12;
        options.task.inputs   = readmatrix(fullfile([options.paths.inputDir,'input_sequence.csv']));
        options.task.nAvatars = 4;
        options.doKeyboard = 1;

    otherwise
        disp(' ...no valid expMode specified, using debug options... ')
        options.screen.rect   = [20, 10, 900, 450];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.task.nTrials  = 12;
        options.task.inputs   = readmatrix(fullfile([options.paths.inputDir,'input_sequence.csv']));
        options.task.nAvatars = 4;
        options.doKeyboard = 1;
end

options.task.name = 'SAP';
options.task.firstTarget = 80;
options.task.finalTarget = 120;

%% Select Stimuli based on Randomisation list
RandTable   = readtable([pwd,'/+eventCreator/stimulus_randomisation.xlsx']);
rowIdx      = find(RandTable.PID==str2num(PID));
avatars     = RandTable(rowIdx,:);
options.task.avatarArray = string(options.task.inputs(:,1));

if strcmp(expMode,'debug')
    cellName  = 'fmri_experiment_a';
else
    cellName  = [expType,'_',expMode,'_a'];
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
        options.screen.qText  = '\n How often does this person usually smile back when receiving a smile?';
        options.screen.predictText = ['Choose to smile: use index finger to start and ring finger once your face is neutral again.' ...
                             '\n Choose to stay neutral: indicate choice with middle finger.'];
        options.screen.firstTagetText = ['You reached ',options.task.firstTarget,' points! ' ...
                                        '\n This added AUD 5 to your reimbursement.'];
        options.screen.finalTagetText = ['You reached ',options.task.finalTarget,' points! ' ...
                                        '\n This added another AUD 5 to your reimbursement.'];
        options.screen.expEndText = ['Thank you, you finished the ',options.task.name, 'task!'];

    case 'practice'
        options.screen.qText  = ['\n How often does this person usually smile back when receiving a smile? ' ...
                                 '\n Use your ringfinger to stop the sliding bar.'];
        options.screen.predictText = ['Do you choose to smile at this person because you predict that they will smile back?' ...
                                 '\n Use your index finger to start smiling and your ringfinger once you stopped smiling' ...
                                 '\n use your middlefinger if you choose not to smile at this ' ...
                                 '\n person because you predict that they will not smile back.'];
        options.screen.firstTagetText = ['You reached ',options.task.firstTarget,' points! ' ...
                                        '\n This added AUD 5 to your reimbursement.'];
        options.screen.finalTagetText = ['You reached ',options.task.finalTarget,' points! ' ...
                                        '\n This added another AUD 5 to your reimbursement.'];
        options.screen.expEndText = ['Thank you, you finished the ',options.task.name, 'task!'];
end

options.screen.qTextL = '           Never';
options.screen.qTextR = 'Always          ';

%% options keyboard
% use KbDemo to identify kbName and Keycode
KbName('UnifyKeyNames')
switch expType
    case 'behav'
        options.keys.startSmile = KbName('LeftArrow'); % KeyCode: 37
        options.keys.stopSmile  = KbName('RightArrow'); % KeyCode: 39
        options.keys.noSmile    = KbName('UpArrow'); % KeyCode: 38
        options.keys.escape     = KbName('ESCAPE');

    case 'fmri'
        options.keys.startSmile = KbName('LeftArrow'); % CHANGE
        options.keys.stopSmile  = KbName('RightArrow'); % CHANGE
        options.keys.noSmile    = KbName('UpArrow'); % CHANGE
        options.keys.escape     = KbName('ESCAPE');

    otherwise
        disp(' ...no valid expType specified, using behav options... ')
        options.keys.startSmile = KbName('LeftArrow'); % CHANGE
        options.keys.stopSmile  = KbName('RightArrow'); % CHANGE
        options.keys.noSmile    = KbName('UpArrow'); % CHANGE
        options.keys.escape     = KbName('ESCAPE');
end

%% DURATIONS OF EVENTS
% CHANGE
if strcmp(expMode,'debug')
    options.dur.waitnxtkeypress = 5000; % in ms
    options.dur.showStimulus    = 1000;
    options.dur.showOutcome     = 400;
    options.dur.showIntroScreen = 1000;
    options.dur.showReadyScreen = 200;
    options.dur.rtTimeout       = 100;
    options.dur.ITI             = randi([50,200],options.task.nTrials,1);
else
    options.dur.waitnxtkeypress = 5000; % in ms
    options.dur.showStimulus    = 2000;
    options.dur.showOutcome     = 400;
    options.dur.showIntroScreen = 2000;
    options.dur.showReadyScreen = 200;
    options.dur.rtTimeout       = 100;
    options.dur.ITI             = randi([400,2000],options.task.nTrials,1); % Jayson: mean 2000, min 400s, max 11600 used OptimizeX, OptSec2
end

%% MESSAGES
options.messages.abortText = 'the experiment was aborted';
options.messages.timeOut   = 'you did not answer in time';

%% DATAFILES & PATHS
date   = datestr(now,2);
options.files.projectID    = 'SAPS_';
options.files.namePrefix   = ['SNG_SAP_',PID,'_',expType];
options.files.savePath     = [pwd,'/data/',expMode,'/',options.files.projectID,PID];
mkdir(options.files.savePath);
options.files.dataFileName = [options.files.namePrefix,'dataFile',date,'.mat'];

end
