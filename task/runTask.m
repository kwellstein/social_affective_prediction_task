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

Screen('DrawTexture', options.screen.windowPtr, stimuli.intro); %[], options.screen.rect);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showIntroScreen,options,dataFile,0);

Screen('DrawTexture', options.screen.windowPtr, stimuli.ITI);
Screen('Flip', options.screen.windowPtr);
[~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showScreen,options,dataFile,0);  
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

% pick slides
firstSlide = [char(avatar),'_neutral'];

% smileQSlide = ['stimuli/',char(avatar),'_neutral.png'];
% choiceSlide = ['stimuli/',char(avatar),'_neutral.png'];

if outcome
    outcomeSlide = [char(avatar),'_smile'];
else
    outcomeSlide = [char(avatar),'_neutral'];
end

% show first presentation of avatar
Screen('DrawTexture', options.screen.windowPtr, stimuli.(firstSlide));% , [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showScreen,options,dataFile,0);

% showSlidingBarQuestion(cues,options,dataFile,expInfo,taskSaveName,trial)
% To do, write line and text onto stimuluslide, maybe using this:
% https://psychtoolbox.discourse.group/t/scale-slider-how-can-i-do-it/4650/2
qResp = tools.showSlidingBarQuestion(firstSlide,options,dataFile,options.task.name,trial);

% show answerpromt

% show outcome
Screen('DrawTexture', options.screen.windowPtr,stimuli.(firstSlide));% , [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);
% [elapsed,difference,dataFile] = wait2(timeout,options,dataFile,trial)
eventListener.commandLine.wait2(options.dur.showScreen,options,dataFile,0);

if trial == options.task.nTrials
    taskRunning = 0;
end

end

    % check if task timed out
    tocID = toc();
     
    if tocID > maxDur
        DrawFormattedText(options.screen.windowPtr, options.messages.timeOut, 'center', 'center', options.screen.black)
        Screen('Flip', options.screen.windowPtr)
        stepping       = 0;
        dataFile.(task).painThreshold = options.painDetect.amplitudeMax;
        disp(['<strong> Task time out</strong>, pain detection Threshold was set to ', num2str(options.painDetect.amplitudeMax),'.'])
        fprintf('\n');
        timeOut        = 1;
        amplitudeReset = 1;
        dataFile = eventListener.logEvent(options.task.name,'_amplitudeReset',dataFile,amplitudeReset,nStep);
        dataFile = eventListener.logEvent(options.task.name,'_timeOut',dataFile,timeOut,[]);
    end
 

%% SAVE data
dataFile = eventListener.logEvent(task,'_off',dataFile,[],[]);

options.calib.amplitudeMax          = dataFile.(options.task.name).painThreshold - options.calib.stepSize;
options.stair.startValueDown        = dataFile.(options.task.name).painThreshold - options.painDetect.stepSize;

dataFile = output.cleanDataFields(dataFile,task,nStep);
dataFile = output.calib2painDetect(dataFile,task);


%% END pain detection calibration
% show end screen


Screen('DrawTexture', options.screen.windowPtr, cues.thankYou, [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showOff,options,expInfo,dataFile,nStep);

if strcmp(task,'painDetect_rerun')
    disp('continuing normal course of experiment now...');
    
else
    Screen('DrawTexture', options.screen.windowPtr, cues.(slideName1), [], options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showOff,options,expInfo,dataFile,nStep);

    Screen('DrawTexture', options.screen.windowPtr, cues.movementBreak, [], options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showScreen,options,expInfo,dataFile,nStep);

    Screen('DrawTexture', options.screen.windowPtr, cues.(slideName2), [], options.screen.rect, 0);
    Screen('Flip', options.screen.windowPtr);
    eventListener.commandLine.wait2(options.dur.showOff,options,expInfo,dataFile,nStep);
end

% save structs along the way in case the program crashes during the study
output.saveInterimData(protocol,options,dataFile,expInfo);
[dataFile,options,expInfo,protocol] = tools.checkOutOfBounds(dataFile,options,expInfo,protocol,task);

%% PLOT data

if options.doPlot
    output.plotAmplitudes('painDetect','pain',expInfo.expMode,dataFile,expInfo);
end

fprintf('\n');
fprintf(['<strong> IMPORTANT: The pain threshold is at ', num2str(dataFile.(task).painThreshold),' mV</strong>.']);
fprintf('\n');

end