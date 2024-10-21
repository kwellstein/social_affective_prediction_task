function dataFile = showSlidingBarQuestion(cue,options,dataFile,task,trial)

% -----------------------------------------------------------------------
% showSlidingBarQuestion.m shows sliding bar question and records the response
%
%   SYNTAX:     [dataFile] = tools.showSlidingBarQuestion(cues,options,dataFile,expInfo,taskSaveName,trial)
%
%   IN:         cues:         struct, containing general  options and task specific
%               options:      struct, options the tasks will run with
%               dataFile:     struct, data file initiated in initDataFile.m
%               expInfo:      struct, contains key info on how the experiment is 
%                                   run instance, incl. keyboard number 
%               task:         string, name of how task output will be
%                                     saved, i.e. task incl task run
%               trial:        integer, trial number, i.e. "question trial"
%
%   OUT:        dataFile: struct, updated dataFile with responses
%
%   SUBFUNCTION(S): logData.m; logEvents.m; detectKey.m
%
%   AUTHOR(S):  based on:    David M. Cole, 2016
%               amended by:  Sandra Iglesias & Katharina V. Wellstein, February 2020
%               last change: amended for SAPS study by 
%                            Katharina V.Wellstein, October 2024
%                            katharina.wellstein@newcastle.edu.au
%                            https://github.com/kwellstein
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

%% INITIALIZE variables
oscillationAmp = options.screen.ypixels*0.25; % space the bar will slide accross
angFreq        = 0.85;                        % sliding bar speed
startPhase     = options.task.slidingBarStart(trial); % starting point of sliding bar
time           = 0;                           % initialized as "0", is updated in sliding bar loop
baseRect       = [0 0 10 100];                % size of rectangles making up slider and min, max
% middleRect     = [0 0 10 50]; 
KBNumber       = options.KBNumber; 
doKeyboard     = options.doKeyboard;
waitingForResp = 1;

%% PREPARE Screen

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(options.screen.rect);

%% START Sliding Bar

% Loop the animation until a key is pressed
loopStartTime = GetSecs();

    while waitingForResp == 1
    
        Screen('DrawTexture', options.screen.windowPtr, cue,[], options.screen.rect, 0);
        Screen('TextSize', options.screen.windowPtr, 50);
        DrawFormattedText(options.screen.windowPtr,options.screen.qText,'center',[],[255 255 255],[],[],[],1.5);
        
        % Position of the square on this frame
        % positive values indicate right side to center, negative values left side
         xPosition = oscillationAmp * sin(angFreq * time + startPhase);

        % This is the point we want our square to oscillate around
        squareXposL    = xCenter - (options.screen.ypixels*0.25);  % left tic
        squareXposR    = xCenter + (options.screen.ypixels*0.25);  % right tic
        squareYPos     = yCenter + (options.screen.xpixels*0.2);
        squareXpos     = xCenter + xPosition;

        % create horizontal line
        baseRectLong   = [0 0 (squareXposR-squareXposL) 10];
        
        % Center the rectangle on the centre of the screen
        centeredRect     = CenterRectOnPointd(baseRect+(xPosition-1), squareXpos, squareYPos);
        centeredRectL    = CenterRectOnPointd(baseRect, squareXposL, squareYPos);
        centeredRectR    = CenterRectOnPointd(baseRect, squareXposR, squareYPos);
        centeredRectLong = CenterRectOnPointd(baseRectLong, xCenter, squareYPos);
        % centeredRectM    =
        % CenterRectOnPointd(middleRect,(squareXposL+((squareXposR-squareXposL)/2)),squareYPos); % centertic

        % Draw the rect to the screen: [function format: Screen(‘FillRect’,windowPtr [,color] [,rect] )]
        Screen('FillRect', options.screen.windowPtr, [],[centeredRect' centeredRectL'...
              centeredRectR' centeredRectLong']);
        % Screen('FillRect', options.screen.windowPtr, [],centeredRectM);
        % [function format: DrawFormattedText(win, tstring [, sx][, sy][,color]
        % [, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])}
        DrawFormattedText(options.screen.windowPtr,options.screen.qTextL,'left',squareYPos,[255 255 255],[],[],[],1.5);
        DrawFormattedText(options.screen.windowPtr,options.screen.qTextR,'right',squareYPos,[255 255 255],[],[],[],1.5);
        Screen('Flip', options.screen.windowPtr);

        % Increment the time
        time = time + options.screen.flipInterval;
        
       % wait for response
        keyCode = eventListener.commandLine.detectKey(KBNumber,doKeyboard);

        if any(keyCode == options.keys.escape)
            DrawFormattedText(options.screen.windowPtr, options.messages.abortText,...
                'center', 'center', options.screen.grey);
            Screen('Flip', options.screen.windowPtr);
            dataFile        = eventListener.logEvent('exp','_abort',dataFile,1,trial);
            disp('Game was aborted.')
            Screen('CloseAll');
            sca
            return;
            
        elseif keyCode == options.keys.stop
            waitingForResp = 0;

        elseif ~isempty(keyCode) % only used when only a specific button can stop the sliding bar!
            DrawFormattedText(options.screen.windowPtr,options.messages.wrongButton,'center','center',[0 1 1],[],[],[],1.5);
            Screen('Flip', options.screen.windowPtr);
            [~,~,dataFile] = eventListener.commandLine.wait2(options.dur.showWarning,options,dataFile,0);
            % disp(['Participant pressed wrong button on trial ',num2str(trial),'... ']);
        end
    end

%% RECORD Response
RT           = GetSecs() - loopStartTime;
[~,dataFile] = eventListener.logData(RT,task,'rt',dataFile,trial);
[~,dataFile] = eventListener.logData(xPosition,task,'response',dataFile,trial);
    
end
