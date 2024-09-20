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


%% SHOW intro

Screen('DrawTexture', options.screen.windowPtr, stimuli.intro,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showIntroScreen,options,dataFile,0);

Screen('DrawTexture', options.screen.windowPtr, stimuli.ready,[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);
dataFile = eventListener.logEvent(expMode,'_startTime',dataFile,[],[]);

%% INITIALIZE
dataFile.events.exp_startTime = GetSecs();
taskRunning = 1;
trial       = 0;
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
        outcomeSlide = [char(avatar),'_neutral']; % if outcome is 0
    end

    % show first presentation of avatar
    Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);

    % % first version with sliding bar before stimulus presentation!
    % % showSlidingBarQuestion(cues,options,dataFile,expInfo,taskSaveName,trial)
    % dataFile = tools.showSlidingBarQuestion(stimuli.(firstSlide),options,dataFile,[options.task.name,'Question'],trial);
    %
    % % show answer promt
    % [dataFile,~,resp] = tools.showResponseScreen(expMode,stimuli.(firstSlide),options,dataFile,[options.task.name,'Prediction'],trial);

    % % new version with sliding bar after stimulus presentation and choice
    % and before outcome. This allows for some more time to recover from producing a smile
    [dataFile,~,resp] = tools.askPrediction(expMode,stimuli.(firstSlide),options,dataFile,[options.task.name,'Prediction'],trial,'start');
    
    % show first presentation of avatar
    Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showSmile,options,dataFile,0);

    if resp == 1
% I dont remember what I did this if else statement for... :p
        % if strcmp(expType,'fmri')
            ticID   = tic();
            dataFile = tools.showSlidingBarQuestion(stimuli.(firstSlide),options,dataFile,[options.task.name,'Question'],trial);
            % show stimulus again
            Screen('DrawTexture', options.screen.windowPtr,stimuli.(firstSlide),[],options.screen.rect, 0);
            Screen('Flip', options.screen.windowPtr);
            eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);
            dataFile = tools.askPrediction(expMode,stimuli.(firstSlide),options,dataFile,[options.task.name,'Prediction'],trial,'stop');
            RT = toc(ticID);
            [~,dataFile] = eventListener.logData(RT,[options.task.name,'SmileTime'],'rt',dataFile,trial);
        % else
        %     Screen('DrawTexture', options.screen.windowPtr,stimuli.(firstSlide),[],options.screen.rect, 0);
        %     Screen('Flip', options.screen.windowPtr);
        %     eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);
        % end
    else
        dataFile = tools.showSlidingBarQuestion(stimuli.(firstSlide),options,dataFile,[options.task.name,'Question'],trial);
        % show stimulus again
        Screen('DrawTexture', options.screen.windowPtr,stimuli.(firstSlide),[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);
    end

    % show stimulus again
    Screen('DrawTexture', options.screen.windowPtr,stimuli.(firstSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showStimulus,options,dataFile,0);

    % show outcome
    Screen('DrawTexture', options.screen.windowPtr,stimuli.(outcomeSlide),[],options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showOutcome,options,dataFile,0);

    % log congruency and show points slide
    if resp==outcome
        [~,dataFile] = eventListener.logData(1,[options.task.name,'Prediction'],'congruent',dataFile,trial);
        Screen('DrawTexture', options.screen.windowPtr,stimuli.plus,[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
    elseif isnan(resp)
        [~,dataFile] = eventListener.logData(-1,[options.task.name,'Prediction'],'congruent',dataFile,trial);
        Screen('DrawTexture', options.screen.windowPtr,stimuli.minus,[],options.screen.rect, 0);
        DrawFormattedText(options.screen.windowPtr, options.messages.timeOut,'center',[], options.screen.grey);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
    else
        [~,dataFile] = eventListener.logData(-1,[options.task.name,'Prediction'],'congruent',dataFile,trial);
        Screen('DrawTexture', options.screen.windowPtr,stimuli.minus,[],options.screen.rect, 0);
        Screen('Flip', options.screen.windowPtr);
        eventListener.commandLine.wait2(options.dur.showPoints,options,dataFile,0);
    end


    if strcmp(expMode,'experiment')
        % calculate total points
        score = sum(dataFile.SAPPrediction.congruent);

        if score == options.task.firstTarget
            Screen('TextSize', options.screen.windowPtr, 50);
            % DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
            DrawFormattedText(options.screen.windowPtr,options.screen.firstTagetText,'center','center',[255 255 255],[],[],[],2);
            Screen('Flip', options.screen.windowPtr);
        elseif score == options.task.finalTarget
            Screen('TextSize', options.screen.windowPtr, 50);
            % DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
            DrawFormattedText(options.screen.windowPtr,options.screen.finalTagetText,'center','center',[255 255 255],[],[],[],2);
            Screen('Flip', options.screen.windowPtr);
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

% clean datafields, incl. deleting leftover zeros from structs in initDatafile
dataFile = tools.cleanDataFields(dataFile,trial);
dataFile.SAPQuestion.sliderStart = options.task.slidingBarStart;

% save all data to
output.saveData(options,dataFile);

% show end screen
DrawFormattedText(options.screen.windowPtr,options.screen.expEndText,'center',[],[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.screen.expEndText,options,dataFile,0);

end