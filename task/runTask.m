function dataFile = runTask(stimuli,expMode,expType,options,dataFile)

%% _______________________________________________________________________________%
% runTask.m runs the Social Affective Prediction task
%
% SYNTAX:  dataFile = runTask(stimuli,expMode,expType,options,dataFile)
%
% IN:       stimuli: struct, contains names of stimuli used in this task run
%
%           expMode: - In 'debug' mode timings are shorter, and the experiment
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
%           options:  struct containing general and task specific
%                        options
%           dataFile: struct containing all data recorded during task,
%                     fields specified in initDataFile.m
%
%  AUTHOR:  Coded by: Katharina V. Wellstein, XX.2024
%                     katharina.wellstein@newcastle.edu.au
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
% _______________________________________________________________________________%
%

%% INITIALIZE
predictField   = [options.task.name,'Prediction'];
actionField    = [options.task.name,'Action'];
taskRunning    = 1;
trial          = 0;

%% START task and send trigger
if strcmp(expType,'fmri')
    waitForTrigger = 1;
    while waitForTrigger
        keyCode = eventListener.commandLine.detectKey(options.KBNumber, options.doKeyboard);
        if keyCode == options.keys.taskStart
            waitForTrigger = 0;
        end
    end
end

if options.doEye
    % Must be offline to draw to EyeLink screen
    Eyelink('Command', 'set_idle_mode');

    % clear tracker display
    Eyelink('Command', 'clear_screen 0');
    Eyelink('StartRecording');

    % always wait a moment for recording to have definitely started
    WaitSecs(0.1);
    Eyelink('message', 'SYNCTIME');
end

dataFile.events.task_startTime = GetSecs();

%% SHOW intro
Screen('DrawTexture', options.screen.windowPtr, stimuli.intro,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showIntroScreen,options,dataFile,0);

if strcmp(expMode,'experiment')
    % show points info
    Screen('DrawTexture', options.screen.windowPtr, stimuli.intro_points,[], options.screen.rect);
    Screen('Flip', options.screen.windowPtr);
    [~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showShortIntro,options,dataFile,0);
end

Screen('DrawTexture', options.screen.windowPtr, stimuli.ready,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showShortInfoTxt,options,dataFile,0);

% show fixation cross for a baseline pupil measurement
if options.doEye
    dataFile.events.eyeBaseline_start = extractAfter(char(datetime('now')),12);

    Screen('DrawTexture', options.screen.windowPtr,stimuli.ITI,[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showEyeBaseline,options,dataFile,0);

    dataFile.events.eyeBaseline_end   = extractAfter(char(datetime('now')),12);
end

%% START task trials

while taskRunning
    trial   = trial + 1; % next step
    avatar  = options.task.avatarArray(trial);
    outcome = options.task.inputs(trial,2);

    % pick avatar of current trial
    firstSlide = [char(avatar),'_neutral'];  % prediction

    if outcome
        outcomeSlide = [char(avatar),'_smile'];   % if outcome is 1
    else
        outcomeSlide = [char(avatar),'_noSmile']; % if outcome is 0 %TODO: once stimuli are ready, add neutral outcome slides
    end

    %% 1ST EVENT: Prediction Phase
    % show first presentation of avatar
    dataFile.events.stimulus_startTime(trial) = extractAfter(char(datetime('now')),12);
    
    Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);

    [dataFile,RT,resp] = tools.askPrediction(expMode,stimuli.(firstSlide),options,dataFile,predictField,trial,'start');

   % show avatar again to make sure this event is constant in timing 
    restEventDur = options.dur.afterchoiceITI(trial)-RT;

    if restEventDur>0 % in case the choice took longer than 500-1000ms, do not show face again
        Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(restEventDur,options,dataFile,0);
    end

    %% 2ND EVENT: Action Phase
    % make sure that participants delineate smile periods with start
    % and stop button but do this also for when participants choose not
    % to smile
     dataFile = tools.askPrediction(expMode,stimuli.(firstSlide),options,dataFile,predictField,trial,'stop');

    
    %% 3RD EVENT: Outcome Phase
    % show outcome
    dataFile.events.outcome_startTime(trial) = extractAfter(char(datetime('now')),12);
    Screen('DrawTexture', options.screen.windowPtr,stimuli.(outcomeSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showOutcome,options,dataFile,0);

    % log congruency and show points slide
    if resp==outcome
        [~,dataFile] = eventListener.logData(1,predictField,'congruent',dataFile,trial);
        if options.task.showPoints
            Screen('DrawTexture', options.screen.windowPtr,stimuli.plus,[],options.screen.rect, 0);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
        end
    elseif isnan(resp)
        [~,dataFile] = eventListener.logData(-1,predictField,'congruent',dataFile,trial);
        dataFile     = eventListener.logEvent('exp','_missedTrial',dataFile,1,trial);
        Screen('DrawTexture', options.screen.windowPtr,stimuli.minus,[],options.screen.rect, 0);
        DrawFormattedText(options.screen.windowPtr, options.messages.timeOut,'center',[], options.screen.grey);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
    else
        [~,dataFile] = eventListener.logData(-1,predictField,'congruent',dataFile,trial);
        if options.task.showPoints
            Screen('DrawTexture', options.screen.windowPtr,stimuli.minus,[],options.screen.rect, 0);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
        end
    end

    % Show Fixation cross %
    dataFile.events.iti_startTime(trial) = extractAfter(char(datetime('now')),12);
    Screen('DrawTexture', options.screen.windowPtr,stimuli.ITI,[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.ITI(trial),options,dataFile,0);

    % check if this is the last trial
    if trial == options.task.nTrials
        taskRunning = 0;
    end
end

%% SAVE data

% log experiment end time
dataFile = eventListener.logEvent('exp','_end',dataFile,[],[]);
dataFile.Summary.points = sum(dataFile.(predictField).congruent);

% clean datafields, incl. deleting leftover zeros from structs in initDatafile
dataFile = tools.cleanDataFields(dataFile,trial,predictField,actionField);

% save all data
if options.doEye
    Eyelink('GetQueuedData');
    Eyelink('ReceiveFile');
end
output.saveData(options,dataFile);


% show end screen
DrawFormattedText(options.screen.windowPtr,options.screen.expEndText,'center','center',[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showShortInfoTxt,options,dataFile,0);

if strcmp(expMode,'experiment')
    tools.showPoints(options,dataFile.Summary.points);
end

end