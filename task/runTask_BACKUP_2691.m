<<<<<<< HEAD
function runTask(expMode,expType,options,dataFile)
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
Screen('DrawTexture', options.screen.windowPtr, stimuli.intro , [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);
% [elapsed,difference,dataFile] = wait2(timeout,options,dataFile,trial)
eventListener.commandLine.wait2(options.dur.showOff,options,dataFile,0);

    
dataFile = eventListener.logEvent(task,'_on',dataFile,[],[]); %amend

%% INITIALIZE

nTrial = 1;
%% START task trials

while taskNotDone
nTrial  = nTrial + 1; % next step
currAvatar  = d; % draw from array
currOutcome = u; % draw from array

Screen('DrawTexture', options.screen.windowPtr, stimuli.intro , [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);
% [elapsed,difference,dataFile] = wait2(timeout,options,dataFile,trial)
eventListener.commandLine.wait2(options.dur.showOff,options,dataFile,0);

if nTrial == options.task.nTrials
    taskNotDone = 0;
end

end


    % stimulate
     if calib2painT == 0
       switch task 
           case 'painDetect_rerun'
               if isempty(dataFile.painDetect_rerun.detectThreshold)
                 task = 'calib_rerun'; % ask Calibation questions first "did you feel the stimulation?"
               end
           case 'painDetect' 
               if isempty(dataFile.painDetect.detectThreshold)
                  task = 'calib'; % ask Calibation questions first "did you feel the stimulation?"
               end
       end   
        if options.doInitStim
           [A,dataFile,resp] = stimulation.adaptiveStimulation(A,cues,options,expInfo,dataFile,task,nStep);
           detectAmplitude = A;
           if resp == 1 && strcmp(task,'calib_rerun')
               task = 'painDetect_rerun';
           elseif resp == 1 && strcmp(task,'calib')
               task = 'painDetect';
           end
        else
           [A,dataFile,resp] = stimulation.simulateStimAmps(A,cues,options,expInfo,dataFile,task,nStep);
           detectAmplitude = A;
           if resp == 1 && strcmp(task,'calib_rerun')
               task = 'painDetect_rerun';
           elseif resp == 1 && strcmp(task,'calib')
               task = 'painDetect';
           end
        end
   
    % print Amplitude to commandwindow
    disp(['task: Pain Detection | trial: ',num2str(nStep),' | stimulated with (mV): '...
        ,num2str(A),' | response: ',num2str(resp)])  
    else
        if options.doInitStim
           [A,dataFile,resp] = stimulation.adaptiveStimulation(A,cues,options,expInfo,dataFile,task,nStep);
        else
           [A,dataFile,resp] = stimulation.simulateStimAmps(A,cues,options,expInfo,dataFile,task,nStep);
        end
        
    % print Amplitude to commandwindow
    disp(['task: Pain Detection |trial: ',num2str(nStep),' | stimulated with (mV): ',num2str(A),...
    ' | response: ',num2str(resp)]) 
    end
    
    % find next amplitude
    response = resp;
    
  if calib2painT == 0
    if response == 0  % stimulation not perceived
        A = A + options.painDetect.stepSize;     % update amplitude
        
        if  A > options.painDetect.amplitudeMax  % if we reach the maximum amplitude without having felt the stimulation
            A = options.painDetect.amplitudeMax; % reset to max amplitude
            dataFile.(task).painThreshold = A;
            amplitudeReset = 1;                  % save this as a reset event
            disp(['<strong>Amplitude too high! </strong> It was reset to ', num2str(options.painDetect.amplitudeMax),'!'])
            stepping       = 0;                  % stop stepping
            
            % abort message
            DrawFormattedText(options.screen.window, options.messages.ampMaxText, 'center', 'center', options.screen.black);
            Screen('Flip', options.screen.window);
            
            % save interim data
            dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
            dataFile = eventListener.logEvent(task,'_off',dataFile,[],[]);
            dataFile.(task).detectThreshold = A;
            options.stair.startValueDown        = options.calib.amplitudeMax;
            dataFile = output.cleanDataFields(dataFile,task,nStep);
            dataFile = output.calib2painDetect(dataFile,task);
            output.saveInterimData(protocol,options,dataFile,expInfo);
            
          else
            amplitudeReset = 0;
        end
        
    elseif response == 1 && A < 101 % response stimulation was perceived when A<100mV for the first time
        if repeatStep    == 0       % if this step has not been repeated before
           amplitudeReset = 1;      % save this as a reset event
           dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
           disp('<strong> Amplitude too low </strong> to plausibly be felt. This step will be repeated once again.');
           stepping       = 1;      % continue stepping
           repeatStep     = 1;      % repeat this step as this might be a typo
           
        else                       
           amplitudeReset = 0; % if this happenes again, we do not assume a typo any longer
           dataFile.(task).detectThreshold = A; % save this as the true detection threshold
           A = A + options.painDetect.stepSize;     % go to next higher amplitude in next step
           stepping       = 1; % continue stepping
           firstPainStep  = 1; % this will be the first step in calibrating to pain threshold
           calib2painT    = 1; % in the next step we start calibrating to pain threshold
        end
        
    elseif response == -99
           amplitudeReset = 1;      % save this as a reset event
           dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
           disp('<strong> Missed trial </strong>. This step will be repeated once again.');
           stepping       = 1;      % continue stepping
           
        else
           dataFile.(task).detectThreshold = A; % save this as the detection threshold
           A = A + options.painDetect.stepSize;    % go to next higher amplitude in next step
           amplitudeReset = 0;  % not a reset event
           stepping       = 1;  % continue stepping
           firstPainStep  = 1;  % this will be the first step in calibrating to the pain threshold
           calib2painT    = 1; % in the next step we start calibrating to pain threshol   
    end
    
  elseif calib2painT == 1
      if response == 0  % stimulation not painful
        A = A + options.painDetect.stepSize;     % update amplitude
        
        if  A > options.painDetect.amplitudeMax  % if we reach the maximum amplitude without stimulation being painful
            A = options.painDetect.amplitudeMax; % reset to max amplitude
            dataFile.(task).painThreshold = A;
            amplitudeReset = 1;                  % save this as a reset event
            dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
            disp(['<strong>Stimulation was not painful until now </strong>. Painthreshold will be ', num2str(options.painDetect.amplitudeMax),'!'])
            stepping       = 0;                  % stop stepping
          else
            amplitudeReset = 0;
            firstPainStep  = 0; % this is not the first step calibrating toward pain threshold any longer
        end
        
    elseif response == 1 && firstPainStep == 1 % response stimulation was painful at the first step calibrating toward the pain threshold
           amplitudeReset = 1;      % save this as a reset event
           dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
           disp('This is only a little bit higher than the detection threshold. This step will be repeated once again.');
           stepping       = 1;      % continue stepping
           repeatStep     = 1;      % repeat this step as this might be a typo
           firstPainStep  = 0;
           
     elseif response == 1 && firstPainStep == 0                    
           amplitudeReset = 0;                    % if this happenes again, we do not assume a typo any longer
           dataFile.(task).painThreshold = A; % save this as the true pain threshold
           stepping       = 0;                    % stop stepping
           
      else % if response = -99
           amplitudeReset = 1;      % save this as a reset event
           dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
           disp('<strong> Missed trial </strong>. This step will be repeated once again.');
           stepping       = 1;      % continue stepping
           repeatStep     = 1;      % repeat this step as this might be a typo
           firstPainStep  = 0;
        end 
        
  end
  
    % show slide indicating that on the next step we will be asking if the stimulation was painful
    if firstPainStep && calib2painT
       Screen('DrawTexture', options.screen.windowPtr, cues.painDetect5, [], options.screen.rect, 0);
       Screen('Flip', options.screen.windowPtr);

       Screen('DrawTexture', options.screen.windowPtr, cues.painDetect6, [], options.screen.rect, 0);
       Screen('Flip', options.screen.windowPtr);
       dataFile = eventListener.commandLine.waitForNextKey(options,expInfo,dataFile);
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
        dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
        dataFile = eventListener.logEvent(task,'_timeOut',dataFile,timeOut,[]);
    end
 

%% SAVE data
dataFile = eventListener.logEvent(task,'_off',dataFile,[],[]);

options.calib.amplitudeMax          = dataFile.(task).painThreshold - options.calib.stepSize;
options.stair.startValueDown        = dataFile.(task).painThreshold - options.painDetect.stepSize;

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
=======
function runTask(expMode,expType,options,dataFile)
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
Screen('DrawTexture', options.screen.windowPtr, stimuli.intro , [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);
% [elapsed,difference,dataFile] = wait2(timeout,options,dataFile,trial)
eventListener.commandLine.wait2(options.dur.showOff,options,dataFile,0);

    
dataFile = eventListener.logEvent(task,'_on',dataFile,[],[]); %amend

%% INITIALIZE

nTrial = 1;
%% START task trials

while taskNotDone
nTrial  = nTrial + 1; % next step
currAvatar  = d; % draw from array
currOutcome = u; % draw from array

Screen('DrawTexture', options.screen.windowPtr, stimuli.intro , [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);
% [elapsed,difference,dataFile] = wait2(timeout,options,dataFile,trial)
eventListener.commandLine.wait2(options.dur.showOff,options,dataFile,0);

if nTrial == options.task.nTrials
    taskNotDone = 0;
end

end


    % stimulate
     if calib2painT == 0
       switch task 
           case 'painDetect_rerun'
               if isempty(dataFile.painDetect_rerun.detectThreshold)
                 task = 'calib_rerun'; % ask Calibation questions first "did you feel the stimulation?"
               end
           case 'painDetect' 
               if isempty(dataFile.painDetect.detectThreshold)
                  task = 'calib'; % ask Calibation questions first "did you feel the stimulation?"
               end
       end   
        if options.doInitStim
           [A,dataFile,resp] = stimulation.adaptiveStimulation(A,cues,options,expInfo,dataFile,task,nStep);
           detectAmplitude = A;
           if resp == 1 && strcmp(task,'calib_rerun')
               task = 'painDetect_rerun';
           elseif resp == 1 && strcmp(task,'calib')
               task = 'painDetect';
           end
        else
           [A,dataFile,resp] = stimulation.simulateStimAmps(A,cues,options,expInfo,dataFile,task,nStep);
           detectAmplitude = A;
           if resp == 1 && strcmp(task,'calib_rerun')
               task = 'painDetect_rerun';
           elseif resp == 1 && strcmp(task,'calib')
               task = 'painDetect';
           end
        end
   
    % print Amplitude to commandwindow
    disp(['task: Pain Detection | trial: ',num2str(nStep),' | stimulated with (mV): '...
        ,num2str(A),' | response: ',num2str(resp)])  
    else
        if options.doInitStim
           [A,dataFile,resp] = stimulation.adaptiveStimulation(A,cues,options,expInfo,dataFile,task,nStep);
        else
           [A,dataFile,resp] = stimulation.simulateStimAmps(A,cues,options,expInfo,dataFile,task,nStep);
        end
        
    % print Amplitude to commandwindow
    disp(['task: Pain Detection |trial: ',num2str(nStep),' | stimulated with (mV): ',num2str(A),...
    ' | response: ',num2str(resp)]) 
    end
    
    % find next amplitude
    response = resp;
    
  if calib2painT == 0
    if response == 0  % stimulation not perceived
        A = A + options.painDetect.stepSize;     % update amplitude
        
        if  A > options.painDetect.amplitudeMax  % if we reach the maximum amplitude without having felt the stimulation
            A = options.painDetect.amplitudeMax; % reset to max amplitude
            dataFile.(task).painThreshold = A;
            amplitudeReset = 1;                  % save this as a reset event
            disp(['<strong>Amplitude too high! </strong> It was reset to ', num2str(options.painDetect.amplitudeMax),'!'])
            stepping       = 0;                  % stop stepping
            
            % abort message
            DrawFormattedText(options.screen.window, options.messages.ampMaxText, 'center', 'center', options.screen.black);
            Screen('Flip', options.screen.window);
            
            % save interim data
            dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
            dataFile = eventListener.logEvent(task,'_off',dataFile,[],[]);
            dataFile.(task).detectThreshold = A;
            options.stair.startValueDown        = options.calib.amplitudeMax;
            dataFile = output.cleanDataFields(dataFile,task,nStep);
            dataFile = output.calib2painDetect(dataFile,task);
            output.saveInterimData(protocol,options,dataFile,expInfo);
            
          else
            amplitudeReset = 0;
        end
        
    elseif response == 1 && A < 101 % response stimulation was perceived when A<100mV for the first time
        if repeatStep    == 0       % if this step has not been repeated before
           amplitudeReset = 1;      % save this as a reset event
           dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
           disp('<strong> Amplitude too low </strong> to plausibly be felt. This step will be repeated once again.');
           stepping       = 1;      % continue stepping
           repeatStep     = 1;      % repeat this step as this might be a typo
           
        else                       
           amplitudeReset = 0; % if this happenes again, we do not assume a typo any longer
           dataFile.(task).detectThreshold = A; % save this as the true detection threshold
           A = A + options.painDetect.stepSize;     % go to next higher amplitude in next step
           stepping       = 1; % continue stepping
           firstPainStep  = 1; % this will be the first step in calibrating to pain threshold
           calib2painT    = 1; % in the next step we start calibrating to pain threshold
        end
        
    elseif response == -99
           amplitudeReset = 1;      % save this as a reset event
           dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
           disp('<strong> Missed trial </strong>. This step will be repeated once again.');
           stepping       = 1;      % continue stepping
           
        else
           dataFile.(task).detectThreshold = A; % save this as the detection threshold
           A = A + options.painDetect.stepSize;    % go to next higher amplitude in next step
           amplitudeReset = 0;  % not a reset event
           stepping       = 1;  % continue stepping
           firstPainStep  = 1;  % this will be the first step in calibrating to the pain threshold
           calib2painT    = 1; % in the next step we start calibrating to pain threshol   
    end
    
  elseif calib2painT == 1
      if response == 0  % stimulation not painful
        A = A + options.painDetect.stepSize;     % update amplitude
        
        if  A > options.painDetect.amplitudeMax  % if we reach the maximum amplitude without stimulation being painful
            A = options.painDetect.amplitudeMax; % reset to max amplitude
            dataFile.(task).painThreshold = A;
            amplitudeReset = 1;                  % save this as a reset event
            dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
            disp(['<strong>Stimulation was not painful until now </strong>. Painthreshold will be ', num2str(options.painDetect.amplitudeMax),'!'])
            stepping       = 0;                  % stop stepping
          else
            amplitudeReset = 0;
            firstPainStep  = 0; % this is not the first step calibrating toward pain threshold any longer
        end
        
    elseif response == 1 && firstPainStep == 1 % response stimulation was painful at the first step calibrating toward the pain threshold
           amplitudeReset = 1;      % save this as a reset event
           dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
           disp('This is only a little bit higher than the detection threshold. This step will be repeated once again.');
           stepping       = 1;      % continue stepping
           repeatStep     = 1;      % repeat this step as this might be a typo
           firstPainStep  = 0;
           
     elseif response == 1 && firstPainStep == 0                    
           amplitudeReset = 0;                    % if this happenes again, we do not assume a typo any longer
           dataFile.(task).painThreshold = A; % save this as the true pain threshold
           stepping       = 0;                    % stop stepping
           
      else % if response = -99
           amplitudeReset = 1;      % save this as a reset event
           dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
           disp('<strong> Missed trial </strong>. This step will be repeated once again.');
           stepping       = 1;      % continue stepping
           repeatStep     = 1;      % repeat this step as this might be a typo
           firstPainStep  = 0;
        end 
        
  end
  
    % show slide indicating that on the next step we will be asking if the stimulation was painful
    if firstPainStep && calib2painT
       Screen('DrawTexture', options.screen.windowPtr, cues.painDetect5, [], options.screen.rect, 0);
       Screen('Flip', options.screen.windowPtr);

       Screen('DrawTexture', options.screen.windowPtr, cues.painDetect6, [], options.screen.rect, 0);
       Screen('Flip', options.screen.windowPtr);
       dataFile = eventListener.commandLine.waitForNextKey(options,expInfo,dataFile);
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
        dataFile = eventListener.logEvent(task,'_amplitudeReset',dataFile,amplitudeReset,nStep);
        dataFile = eventListener.logEvent(task,'_timeOut',dataFile,timeOut,[]);
    end
 

%% SAVE data
dataFile = eventListener.logEvent(task,'_off',dataFile,[],[]);

options.calib.amplitudeMax          = dataFile.(task).painThreshold - options.calib.stepSize;
options.stair.startValueDown        = dataFile.(task).painThreshold - options.painDetect.stepSize;

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
>>>>>>> 9f631d041dff21a58ab3d7694b516e47d77a9470
