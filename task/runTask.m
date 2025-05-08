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
predictField   = [options.task.name,'Prediction'];
actionField    = [options.task.name,'Action'];
taskRunning    = 1;
trial          = 0;

% send trigger indicating that this is the SAP task
if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.thisTaskTrigger,0,options.EMG.pinMask,options.EMG.pulseDur);
end

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
if options.doPPU
    f = parfeval(@readDataFromCOM,0);
end

dataFile.events.exp_startTime = GetSecs();

if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.expStart,0,options.EMG.pinMask,options.EMG.pulseDur);
end
%% SHOW intro
Screen('DrawTexture', options.screen.windowPtr, stimuli.intro,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showIntroScreen,options,dataFile,0);

if strcmp(expMode,'experiment')
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


if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.baselineStart,0,options.EMG.pinMask,options.EMG.pulseDur);
end

%% BASELINE
dataFile.events.baseline_start = extractAfter(char(datetime('now')),12);
if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.baselineStart,0,options.EMG.pinMask,options.EMG.pulseDur);
end

Screen('DrawTexture', options.screen.windowPtr,stimuli.ITI,[],options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);

if strcmp(expType,'fmri') && strcmp(expMode,'experiment')
    eventListener.commandLine.wait2(options.dur.showMRIBaseline,options,dataFile,0);
else
    eventListener.commandLine.wait2(options.dur.showEyeBaseline,options,dataFile,0);
end
dataFile.events.baseline_end   = extractAfter(char(datetime('now')),12);


%% START TASK
dataFile.events.task_startTime = GetSecs();
if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.taskStart,0,options.EMG.pinMask,options.EMG.pulseDur);
end


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
    dataFile.events.stimulus_startTime(trial)    = extractAfter(char(datetime('now')),12);
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

    %% 2ND EVENT: Action Phase
    [dataFile,RT,resp] = tools.askPrediction(stimuli.(firstSlide),options,dataFile,predictField,trial);

    if options.doEMG == 1
        if resp==1
            % set all the pins to zero before using parallel port as pins are
            % in an unknown state otherwise neutralKey
            parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
            % set pins to the code value and then afterwards set the pins to zero
            parPulse(options.EMG.portAddress,options.EMG.smileKey,0,options.EMG.pinMask,options.EMG.pulseDur);
        else
            % set all the pins to zero before using parallel port as pins are
            % in an unknown state otherwise
            parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
            % set pins to the code value and then afterwards set the pins to zero
            parPulse(options.EMG.portAddress,options.EMG.neutralKey,0,options.EMG.pinMask,options.EMG.pulseDur);
        end
    end
    RT = RT*1000; % convert to ms

    % show avatar again to make sure this event is constant in timing
    restEventDur = options.dur.afterActionITI(trial)-RT;

    %% 3RD EVENT: Outcome Phase
    % show outcome
    dataFile.events.outcome_startTime(trial)    = extractAfter(char(datetime('now')),12);
    dataFile.events.outcome_startTimeStp(trial) = GetSecs();

    if ~isnan(resp)
        if restEventDur>0 % in case the choice took longer than allocated action event time
            Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(restEventDur,options,dataFile,0);
        end

        if options.doEMG == 1
            % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
            parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
            if resp==outcome
                % set pins to the code value and then afterwards set the pins to zero
                parPulse(options.EMG.portAddress,options.EMG.congruentOutcome,0,options.EMG.pinMask,options.EMG.pulseDur);
            else
                % set pins to the code value and then afterwards set the pins to zero
                parPulse(options.EMG.portAddress,options.EMG.incongruentOutcome,0,options.EMG.pinMask,options.EMG.pulseDur);
            end
        end
        % show outcome slide
        Screen('DrawTexture', options.screen.windowPtr,stimuli.(outcomeSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showOutcome,options,dataFile,0);

    else % if participant missed the trial
        % show missed trial slide
        if restEventDur>0 % in case the choice took longer than allocated action event time
            DrawFormattedText(options.screen.windowPtr,options.messages.timeOut ,'center','center',[255 255 255],[],[],[],1);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(restEventDur,options,dataFile,0);
        end
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
        eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
    else
        [~,dataFile] = eventListener.logData(-1,predictField,'congruent',dataFile,trial);

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

if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.taskStop,0,options.EMG.pinMask,options.EMG.pulseDur);
end


%% SHOW END Sceen
% log experiment end time
dataFile.events.exp_end = GetSecs();
dataFile.Summary.points = sum(dataFile.(predictField).congruent);

% show end screen
DrawFormattedText(options.screen.windowPtr,options.screen.expEndText,'center','center',[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);

if strcmp(expMode,'experiment')
    tools.showPoints(options,dataFile.Summary.points);
end

%% SAVE data
% STOP parallel process
if options.doPPU
    cancel(f);
    fclose("all");
    exist = dir([pwd,filesep,'sObj.mat']);
    if exist
        load('sObj')
        sObj =[];
        delete([pwd,filesep,'sObj.mat']);
        disp('no COM obj saved, check ppu_data file...');
    end
end

% MOVE eyelink data
if options.doEye
    Eyelink('GetQueuedData');
    Eyelink('ReceiveFile');
end

% clean datafields, incl. deleting leftover zeros from structs in initDatafile
dataFile = tools.cleanDataFields(dataFile,trial,predictField,actionField);
output.saveData(options,dataFile);

if options.doEMG == 1
    % set all the pins to zero before using parallel port as pins are in an unknown state otherwise
    parPulse(options.EMG.portAddress,0,0,options.EMG.pinMask,options.EMG.pulseDur);
    % set pins to the code value and then afterwards set the pins to zero
    parPulse(options.EMG.portAddress,options.EMG.expStop,0,options.EMG.pinMask,options.EMG.pulseDur);
end

end