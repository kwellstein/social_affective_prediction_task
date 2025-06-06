function dataFile = runTask(stimuli,expMode,expType,options,dataFile)

%% _______________________________________________________________________________%
%% runTask.m runs the Social Affective Prediction Control task
%
% SYNTAX:  dataFile = runTask(stimuli,expMode,expType,options,dataFile)
%
% IN:       stimuli: struct, contains names of stimuli used in this task run
%
%           expMode: - In 'practice' mode you are running the entire
%                     the practice round as it has been specified in
%                     specifyOptions.m
%                     - In 'experiment' mode you are running the entire
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
%  AUTHOR:  Coded by: Katharina V. Wellstein, May 2025
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
predictField = [options.task.name,'Prediction'];
taskRunning  = 1;
trial        = 0;

%% START task and SEND TRIGGERS
% send trigger indicating that this is the SAPC task
if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.thisTaskTrigger,0,options.EMG.pinMask,options.EMG.pulseDur);
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

if options.doPPU == 1
    % split off to reading PPU data
    f = parfeval(@readDataFromCOM,0);
end

dataFile.events.exp_startTime = GetSecs();

%% SHOW intro
Screen('DrawTexture', options.screen.windowPtr, stimuli.intro,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showIntroScreen,options,dataFile,0);

if strcmp(expMode,'practice')
    Screen('DrawTexture', options.screen.windowPtr, stimuli.intro2,[], options.screen.rect);
    Screen('Flip', options.screen.windowPtr);
    [~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showShortIntro,options,dataFile,0);

    Screen('DrawTexture', options.screen.windowPtr, stimuli.intro3,[], options.screen.rect);
    Screen('Flip', options.screen.windowPtr);
    [~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showPractOutcome,options,dataFile,0);
else
    % show points info
    if  options.task.nTasks == 2
        Screen('DrawTexture', options.screen.windowPtr, stimuli.intro_points_2Tasks,[], options.screen.rect);
    else
        Screen('DrawTexture', options.screen.windowPtr, stimuli.intro_points_allTasks,[], options.screen.rect);
    end

    Screen('Flip', options.screen.windowPtr);
    [~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showShortIntro,options,dataFile,0);
end

% show ready screen
Screen('DrawTexture', options.screen.windowPtr, stimuli.ready,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);

%% GET scanner trigger
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


%% BASELINE
dataFile.events.baseline_start = extractAfter(char(datetime('now')),12);
if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.baselineStart,0,options.EMG.pinMask,options.EMG.pulseDur);
end

Screen('DrawTexture', options.screen.windowPtr, stimuli.ITI,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);

if strcmp(expType,'fmri') && strcmp(expMode,'experiment')
    [~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showMRIBaseline,options,dataFile,0);
else
    [~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showEyeBaseline,options,dataFile,0);
end

dataFile.events.baseline_end   = extractAfter(char(datetime('now')),12);

%% START TASK
dataFile.events.task_startTime = GetSecs();

while taskRunning
    trial   = trial + 1; % next step
    egg     = options.task.eggArray(trial);
    outcome = options.task.inputs(trial,2);

    % pick egg of current trial
    firstSlide  = [char(egg),'_egg'];  % prediction
    choiceSlide = [char(egg),'_eggCollected'];  % choice stimulus if decided to collect

    %% 1ST EVENT: Prediction Phase
    % show first presentation of avatar
    dataFile.events.stimulus_startTime(trial)     = extractAfter(char(datetime('now')),12);
    dataFile.events.stimulus_startTimeStp(trial) = GetSecs();

    if options.doEMG == 1
        % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
        parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
        % set pins to the code value and then afterwards set the pins to zero
        parPulse(options.EMG.portAddress,options.EMG.trialStart,0,options.EMG.pinMask,options.EMG.pulseDur);
    end

    Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);

    [dataFile,RT,resp] = tools.askPrediction([],stimuli.(firstSlide),options,dataFile,predictField,trial);
    if options.doEMG == 1
        if resp==1
            % set all the pins to zero before using parallel port as pins are
            % in an unknown state otherwise neutralKey
            parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
            % set pins to the code value and then afterwards set the pins to zero
            parPulse(options.EMG.portAddress,options.EMG.collectKey,0,options.EMG.pinMask,options.EMG.pulseDur);
        else
            % set all the pins to zero before using parallel port as pins are
            % in an unknown state otherwise
            parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
            % set pins to the code value and then afterwards set the pins to zero
            parPulse(options.EMG.portAddress,options.EMG.noCollectKey,0,options.EMG.pinMask,options.EMG.pulseDur);
        end
    end

    RT = RT*1000; % convert to ms
    restEventDur = options.dur.afterChoiceITI(trial)-RT;

    %% 2ND EVENT: Show Choice
    dataFile.events.choiceStim_startTime(trial) = extractAfter(char(datetime('now')),12);

    if resp ==1
        % show choice with jitter
        Screen('DrawTexture', options.screen.windowPtr, stimuli.(choiceSlide),[],options.screen.rect, 0);
    elseif resp==0
        Screen('DrawTexture', options.screen.windowPtr, stimuli.no_eggCollected,[],options.screen.rect, 0);
    else
        DrawFormattedText(options.screen.windowPtr, options.messages.timeOut,'center',[], options.screen.grey);
    end
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(restEventDur,options,dataFile,0);

    %% 3RD EVENT: Show Outcome
    % log congruency and show points slide

    if resp==outcome % if congurent outcome
        % log data
        [~,dataFile] = eventListener.logData(1,predictField,'congruent',dataFile,trial);

        % select slide to be presented plus duration as a function of
        % experiment vs. practice expMode
        if strcmp(expMode,'experiment')
            outcomeSlide = 'coin'; % experiment mode, show simple coin

        elseif resp==1 % if NOT experiment mode, show coin and comment as a function of choice made by participant
            outcomeSlide = 'collectCoin'; % collected egg and earned coin

        elseif resp==0
            outcomeSlide = 'rejectCoin';% rejected egg and earned coin
        end

        % show outcome with different duration and slide as specified in exp-practice loop above!
        dataFile.events.outcome_startTime(trial)    = extractAfter(char(datetime('now')),12);
        dataFile.events.outcome_startTimeStp(trial) = GetSecs();

        if options.doEMG == 1
            % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
            parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
            % set pins to the code value and then afterwards set the pins to zero
            parPulse(options.EMG.portAddress,options.EMG.congruentOutcome,0,options.EMG.pinMask,options.EMG.pulseDur);
        end

        Screen('DrawTexture', options.screen.windowPtr,stimuli.(outcomeSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showOutcome,options,dataFile,0);

        if options.task.showPoints
            Screen('DrawTexture', options.screen.windowPtr,stimuli.plus,[],options.screen.rect, 0);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
        end

    elseif isnan(resp) % if no response
        [~,dataFile] = eventListener.logData(-1,predictField,'congruent',dataFile,trial);
        outcomeSlide = 'noCoin'; % if outcome is 0
        dataFile     = eventListener.logEvent('exp','_missedTrial',dataFile,1,trial);
        DrawFormattedText(options.screen.windowPtr, options.messages.timeOut,'center',[], options.screen.grey);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showOutcome,options,dataFile,0);
    
    else % if wrong decision made
        [~,dataFile] = eventListener.logData(-1,predictField,'congruent',dataFile,trial);
        if strcmp(expMode,'experiment')
            outcomeSlide = 'noCoin'; % if outcome is 0

        elseif resp==1 % if NOT experiment mode, show coin and comment as a function of choice made by participant
            outcomeSlide = 'collectNoCoin'; % collected bad egg

        elseif resp==0
            outcomeSlide = 'rejectNoCoin';% rejected good egg
        end


        if options.doEMG == 1
            % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
            parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
            % set pins to the code value and then afterwards set the pins to zero
            parPulse(options.EMG.portAddress,options.EMG.incongruentOutcome,0,options.EMG.pinMask,options.EMG.pulseDur);
        end

        % show outcome with different duration and slide as specified in exp-practice loop above!
        Screen('DrawTexture', options.screen.windowPtr,stimuli.(outcomeSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showOutcome,options,dataFile,0);

        if options.task.showPoints
            Screen('DrawTexture', options.screen.windowPtr,stimuli.minus,[],options.screen.rect, 0);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
        end
    end

    if options.doEMG == 1
        % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
        parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
        % set pins to the code value and then afterwards set the pins to zero
        parPulse(options.EMG.portAddress,options.EMG.trialStop,0,options.EMG.pinMask,options.EMG.pulseDur);
    end

    %% ITI Show Fixation cross
    dataFile.events.iti_startTime(trial)    = extractAfter(char(datetime('now')),12);
    dataFile.events.iti_startTimeStp(trial) = GetSecs();

    Screen('DrawTexture', options.screen.windowPtr,stimuli.ITI,[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.ITI(trial),options,dataFile,0);

    % check if this is the last trial
    if trial == options.task.nTrials
        taskRunning = 0;
    end
end

if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.taskStop,0,options.EMG.pinMask,options.EMG.pulseDur);
end


%% SHOW END screen
% log experiment end time
dataFile.events.exp_end = GetSecs();
dataFile.Summary.points = sum(dataFile.(predictField).congruent);

DrawFormattedText(options.screen.windowPtr,options.screen.expEndText,'center','center',[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);

if strcmp(expMode,'experiment')
    tools.showPoints(options,dataFile.Summary.points);
end

%% SAVE data
% move eyelink data
if options.doEye
    Eyelink('GetQueuedData');
    Eyelink('ReceiveFile');
end

if options.doPPU
    cancel(f);
    fclose("all");
    exist = dir([pwd,filesep,'sObj.mat']);
    if ~isempty(exist)
        load('sObj')
        sObj =[];
        delete([pwd,filesep,'sObj.mat']);
    else
        disp('no COM obj saved, check ppu_data file...');
    end
end
% clean datafields, incl. deleting leftover zeros from structs in initDatafile
dataFile = tools.cleanDataFields(dataFile,trial,predictField);
output.saveData(options,dataFile);

if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.expStop,0,options.EMG.pinMask,options.EMG.pulseDur);
end


end