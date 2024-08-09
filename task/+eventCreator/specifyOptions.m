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
        options.task.nAvatars = 4;
        options.task.inputs   = readmatrix(fullfile([options.paths.inputDir,'input_sequence.csv']));
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
        options.task.nAvatars = 2;
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
        options.task.nTrials  = 8;
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';
        options.task.nAvatars = 2;
        options.doKeyboard = 1;

    otherwise
        disp(' ...no valid expMode specified, using debug options... ')
        options.screen.rect   = [20, 10, 900, 450];
        screens               = Screen('Screens');
        options.screen.number = max(screens);
        options.task.nTrials  = 8;
        options.task.inputs   = [1 2 2 1 2 1 1 2; 1 0 1 1 0 0 1 1]';
        options.task.nAvatars = 2;
        options.doKeyboard = 1;
end

options.task.name = 'SAP';
options.task.firstTarget = 60;
options.task.finalTarget = 100;

%% Select Stimuli based on Randomisation list
RandTable   = readtable([pwd,'/+eventCreator/stimulus_randomisation.xlsx']);
rowIdx      = find(RandTable.PID==str2num(PID));
avatars     = RandTable(rowIdx,:);
options.task.avatarArray = string(options.task.inputs(:,1));

if strcmp(expMode,'debug')
    cellName  = 'fmri_experiment_a';
elseif strcmp(expType,'behav') || strcmp(expMode,'experiment')
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
        options.screen.qText       = '\n How often does this person usually smile back when receiving a smile?';
        options.screen.predictText = ['Choose to smile: use index finger to start & ring finger once your face is neutral again.' ...
            '\n Choose to stay neutral: indicate choice with middle finger.'];
        options.screen.startPredictText = 'smile or neutral?';
        options.screen.stopPredictText  = 'stopped smiling?';
        options.screen.smileHoldText    = 'stop smile button not active yet!'; %% UNUSED AS OF NOW
        options.screen.firstTagetText   = ['You reached ',options.task.firstTarget,' points! ' ...
            '\n This added AUD 5 to your reimbursement.'];
        options.screen.finalTagetText = ['You reached ',options.task.finalTarget,' points! ' ...
            '\n This added another AUD 5 to your reimbursement.'];
        options.screen.expEndText     = ['Thank you! ' ...
            'You finished the ',options.task.name, 'task.'];

    case 'practice'
        options.screen.qText       = ['\n How often does this person usually smile back when receiving a smile? ' ...
            '\n Use your ringfinger to stop the sliding bar.'];
        options.screen.predictText = ['Do you choose to smile at this person because you predict that they will smile back?' ...
            '\n Use your index finger to start smiling and your ringfinger once you stopped smiling.' ...
            '\n Use your middlefinger if you choose not to smile at this ' ...
            '\n person because you predict that they will not smile back.'];
        options.screen.startPredictText =  ['Do you choose to smile at this person because you predict that they will smile back?' ...
            '\n Use your index finger to start smiling and continue to smile at them while answering the next question.' ...
            '\n Use your middlefinger if you choose not to smile at this person because you predict that they will not smile back.'];
        options.screen.stopPredictText  = 'Finished smiling: use your ring finger to indicate that yoru face is neutral again';
        options.screen.smileHoldText   = ['please spend some time smiling,' ...
            '\n  the button to stop smiling won''t be active immediately']; 
        options.screen.waitNoSmileText = 'wait and see how the face will respond';
        options.screen.firstTagetText  = ['You reached ',options.task.firstTarget,' points! ' ...
            '\n This added AUD 5 to your reimbursement.'];
        options.screen.finalTagetText  = ['You reached ',options.task.finalTarget,' points! ' ...
            '\n This added another AUD 5 to your reimbursement.'];
        options.screen.expEndText      = ['Thank you! \n' ...
            'You finished the ',options.task.name, 'task!'];
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
    options.dur.showReadyScreen =  2000;
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
options.files.namePrefix   = ['SNG_SAP_',PID,'_',expType];
options.files.savePath     = [pwd,'/data/',expMode,'/',options.files.projectID,PID];
mkdir(options.files.savePath);
options.files.dataFileName = [options.files.namePrefix,'dataFile.mat'];

end
