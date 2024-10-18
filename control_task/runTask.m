function dataFile = runTask(stimuli,expMode,expType,options,dataFile)
%% _______________________________________________________________________________%
%% runTask.m runs the Social Affective Prediction task
%
% SYNTAX:  XX
%
% OUT:      expMode: - In 'debug' mode timings are shorter, and the experiment
%                     won't be full screen. You may use breakpoints.
%                   - In 'experiment' mode you are running the entire
%                     experiment as it is intended
%
%           PPID:    A 4-digit integer (0001:0999) PPIDs have
%                   been assigned to participants a-priori
%
%           visitNo: A 1-digit integer (1:4). Each participant will be doing
%                   this task 4 times.
%
%  AUTHOR:  Coded by: Katharina V. Wellstein, XX.2024
%                     katharina.wellstein@newcastle.edu.au
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

%% INITIALIZE
predictField = [options.task.name,'Prediction'];
questField   = [options.task.name,'Question'];
taskRunning  = 1;
trial        = 0;

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

dataFile.events.exp_startTime = GetSecs();
%% SHOW intro

Screen('DrawTexture', options.screen.windowPtr, stimuli.intro,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showIntroScreen,options,dataFile,0);

if strcmp(expMode,'practice')
    Screen('DrawTexture', options.screen.windowPtr, stimuli.intro2,[], options.screen.rect);
    Screen('Flip', options.screen.windowPtr);
    [~,~,dataFile] = eventListener.commandLine.wait2((options.dur.showIntroScreen/2),options,dataFile,0);

    Screen('DrawTexture', options.screen.windowPtr, stimuli.intro3,[], options.screen.rect);
    Screen('Flip', options.screen.windowPtr);
    [~,~,dataFile] = eventListener.commandLine.wait2((options.dur.showIntroScreen/2),options,dataFile,0);
end

Screen('DrawTexture', options.screen.windowPtr, stimuli.ready,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);
dataFile = eventListener.logEvent(expMode,'_startTime',dataFile,[],[]);

%% START task trials

while taskRunning
    trial   = trial + 1; % next step
    egg     = options.task.eggArray(trial);
    outcome = options.task.inputs(trial,2);

    % pick egg of current trial
    firstSlide  = [char(egg),'_egg'];  % prediction
    choiceSlide = [char(egg),'_eggCollected'];  % choice stimulus if decided to collect

    % show egg
    Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);

    dataFile = tools.showSlidingBarQuestion(stimuli.(firstSlide),options,dataFile,questField,trial);
    [dataFile,~,resp] = tools.askPrediction([],stimuli.(firstSlide),options,dataFile,predictField,trial);

    if resp ==1
        % show choice with jitter
        Screen('DrawTexture', options.screen.windowPtr, stimuli.(choiceSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showChoiceITI(trial),options,dataFile,0);
    else
        Screen('DrawTexture', options.screen.windowPtr, stimuli.no_eggCollected,[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showChoiceITI(trial),options,dataFile,0);
    end



    % log congruency and show points slide
    if resp==outcome % if congurent outcome
        % log data
        [~,dataFile] = eventListener.logData(1,predictField,'congruent',dataFile,trial);
        
        % select slide to be presented plus duration as a function of
        % experiment vs. practice expMode
        if strcmp(expMode,'experiment')
            outcomeSlide = 'coin'; % experiment mode, show simple coin
            durOutcomeSlide = options.dur.showOutcome;

        elseif resp==1 % if NOT experiment mode, show coin and comment as a function of choice made by participant
            outcomeSlide = 'collectCoin'; % collected egg and earned coin
            durOutcomeSlide = options.dur.showReadyScreen;

        elseif resp==0
            outcomeSlide = 'rejectCoin';% rejected egg and earned coin
            durOutcomeSlide = options.dur.showReadyScreen;
        end

        % show outcome with different duration and slide as specified in exp-practice loop above!
        Screen('DrawTexture', options.screen.windowPtr,stimuli.(outcomeSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(durOutcomeSlide,options,dataFile,0);

        if options.task.showPoints
            Screen('DrawTexture', options.screen.windowPtr,stimuli.plus,[],options.screen.rect, 0);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
        end

    elseif isnan(resp)
        [~,dataFile] = eventListener.logData(-1,predictField,'congruent',dataFile,trial);
        outcomeSlide = 'noCoin'; % if outcome is 0
        dataFile     = eventListener.logEvent('exp','_missedTrial ',dataFile,1,trial);
        Screen('DrawTexture', options.screen.windowPtr,stimuli.minus,[],options.screen.rect, 0);
        DrawFormattedText(options.screen.windowPtr, options.messages.timeOut,'center',[], options.screen.grey);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
    else
        [~,dataFile] = eventListener.logData(-1,predictField,'congruent',dataFile,trial);
        if strcmp(expMode,'experiment')
            outcomeSlide = 'noCoin'; % if outcome is 0
            durOutcomeSlide = options.dur.showOutcome;

        elseif resp==1 % if NOT experiment mode, show coin and comment as a function of choice made by participant
            outcomeSlide = 'collectNoCoin'; % collected bad egg
            durOutcomeSlide = options.dur.showReadyScreen;

        elseif resp==0
            outcomeSlide = 'rejectNoCoin';% rejected good egg
            durOutcomeSlide = options.dur.showReadyScreen;
        end

        % show outcome with different duration and slide as specified in exp-practice loop above!
        Screen('DrawTexture', options.screen.windowPtr,stimuli.(outcomeSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(durOutcomeSlide,options,dataFile,0);

        if options.task.showPoints
            Screen('DrawTexture', options.screen.windowPtr,stimuli.minus,[],options.screen.rect, 0);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
        end
    end

    % Show Fixation cross % ADD JITTER with optseq2!!!!
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
dataFile = tools.cleanDataFields(dataFile,trial,predictField,questField);
dataFile.(questField).sliderStart = options.task.slidingBarStart;

% save all data to
output.saveData(options,dataFile);

% show end screen
DrawFormattedText(options.screen.windowPtr,options.screen.expEndText,'center','center',[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);

if strcmp(expMode,'experiment')
    tools.showPoints(options,dataFile.Summary.points);
end

end