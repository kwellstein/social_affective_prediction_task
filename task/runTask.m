function dataFile = runTask(stimuli,expMode,expType,options,dataFile)

%% _______________________________________________________________________________%
%% runTask.m runs the Social Affective Prediction task
%
% SYNTAX:  dataFile = runTask(stimuli,expMode,expType,options,dataFile)
%
% IN:       stimuli: struct, contains names of stimuli used in this task run
%
%           expMode: - In 'practice' mode you are running the entire
%                     the practice round as it has been specified in

%                     specifyOptions.m
%                    - In 'experiment' mode you are running the entire
%                     experiment as it has been specified in
%                     specifyOptions.m
%
%           expType: - 'behav': use keyboard and different instructions and
%                       more as specified in specifyOptions.m
%                    - 'fmri': use button box and different instructions13
%                       more as specified in specifyOptions.m
%           options:  struct containing general and task specific
%                        options
%           dataFile: struct containing all data recorded during task,
%                     fields specified in initDataFile.m
%
%  AUTHOR:  Coded by: Katharina V. Wellstein, XX.2024
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

% split off to reading PPU data
f = parfeval(@readDataFromCOM,0);

dataFile.events.exp_startTime = GetSecs();

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

% show ready screen
Screen('DrawTexture', options.screen.windowPtr, stimuli.ready,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);


%% START task and send trigger
if strcmp(expType,'fmri')
    waitForTrigger = 1;
    while waitForTrigger
        [ ~, ~, keyCode,  ~] = KbCheck;
        keyCode = find(keyCode);
        if keyCode == options.keys.taskStart
            waitForTrigger = 0;
        end
    end
end

% if options.doEMG==1
%     parPulse(options.EMG.portNo) % get port address
%     parPulse(options.EMG.expStart,0,15,1)
% end


dataFile.events.task_startTime = GetSecs();
% show baseline
dataFile.events.baseline_start = extractAfter(char(datetime('now')),12);
Screen('DrawTexture', options.screen.windowPtr,stimuli.ITI,[],options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);

if strcmp(expType,'fmri') && strcmp(expMode,'experiment')
    eventListener.commandLine.wait2(options.dur.showMRIBaseline,options,dataFile,0);
else
    eventListener.commandLine.wait2(options.dur.showEyeBaseline,options,dataFile,0);
end
dataFile.events.baseline_end   = extractAfter(char(datetime('now')),12);


%% START TASK

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
    dataFile.events.stimulus_startTimeStp(trial) = GetSecs();

    % if options.doEMG==1
    %     parPulse(options.EMG.portNo) % get port address
    %     parPulse(options.EMG.trialStart,0,15,1)
    % end
    
    Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);
    
    [dataFile,RT,resp] = tools.askPrediction(stimuli.(firstSlide),options,dataFile,predictField,trial);
    
    % show avatar again to make sure this event is constant in timing
    restEventDur = options.dur.afterActionITI(trial)-RT;
    
    %% 2ND EVENT: Action Phase
    % make sure that participants delineate smile periods with start
    % and stop button but do this also for when participants choose not
    % to smile

    if restEventDur>0 % in case the choice took longer than allocated action event time
        Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(restEventDur,options,dataFile,0);
    end
    
    %% 3RD EVENT: Outcome Phase
    % show outcome
    dataFile.events.outcome_startTime(trial) = extractAfter(char(datetime('now')),12);
    dataFile.events.outcome_startTimeStp(trial) = GetSecs();
    if ~isnan(resp)   
        % if options.doEMG==1
        %     parPulse(options.EMG.portNo) % get port address
        %     parPulse(options.EMG.respStop,0,15,1)
        % end

        Screen('DrawTexture', options.screen.windowPtr,stimuli.(outcomeSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showOutcome,options,dataFile,0);
    else
        Screen('DrawTexture', options.screen.windowPtr,stimuli.(firstSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showOutcome,options,dataFile,0);
    end
    
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
    % if options.doEMG==1
    %     parPulse(options.EMG.portNo) % get port address
    %     parPulse(options.EMG.trialStop,0,15,1)
    % end


    %% ITI Show Fixation cross 
    dataFile.events.iti_startTime(trial) = extractAfter(char(datetime('now')),12);
    dataFile.events.iti_startTimeStp(trial) = GetSecs();

    Screen('DrawTexture', options.screen.windowPtr,stimuli.ITI,[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.ITI(trial),options,dataFile,0);
    
    % check if this is the last trial
    if trial == options.task.nTrials
        taskRunning = 0;
        
    end
end

% if options.doEMG==1
%     parPulse(options.EMG.portNo) % get port address
%     parPulse(options.EMG.expStop,0,15,1)
% end
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
eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);

if strcmp(expMode,'experiment')
    tools.showPoints(options,dataFile.Summary.points);
end
%% STOP parallel process
cancel(f);

fclose("all");
load('sObj')
sObj =[];
delete([pwd,filesep,'sObj.mat']);

end