function dataFile = showSlidingBarQuestion(cues,options,dataFile,expInfo,taskSaveName,trial)

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
%               taskSaveName: string, name of how task output will be
%                                     saved, i.e. task incl task run
%               trial:        integer, trial number, i.e. "question trial"
%
%   OUT:        dataFile: struct, updated dataFile with responses
%
%   SUBFUNCTION(S): logData.m
%
%   AUTHOR(S):  based on:    David M. Cole, 2016
%               amended by:  Sandra Iglesias & Katharina V. Wellstein, February 2020
%               last change: Katharina V. Wellstein, May 2021
% -------------------------------------------------------------------------

%% INITIALIZE variables
oscillationAmp = options.screen.yPixels*0.55; % space the bar will slide accross
angFreq        = 0.8;                         % sliding bar speed
startPhase     = rand(1)*100;                 % starting point of sliding bar
time           = 0;                           % initialized as "0", is updated in sliding bar loop
baseRect       = [0 0 10 100];                % size of rectangles making up slider and min, max
KBNumber       = expInfo.KBNumber; 
doKeyboard     = options.doKeyboard;
recordedResp   = 0;

%% PREPARE Screen

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(options.screen.rect);

%[nx, ny, textbounds, wordbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
Screen('DrawTexture', options.screen.windowPtr, cues.slider, [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);

%% START Sliding Bar

% Loop the animation until a key is pressed
loopStartTime = GetSecs();

    while recordedResp == 0

         Screen('DrawTexture', options.screen.windowPtr, cues.slider, [], options.screen.rect, 0);
        
        % Position of the square on this frame
        % positive values indicate right side to center, negative values left side
         xPosition = oscillationAmp * sin(angFreq * time + startPhase);

        % This is the point we want our square to oscillate around
        squareXpos     = xCenter + xPosition;
        squareXposL    = xCenter - (options.screen.yPixels*0.55);
        squareXposR    = xCenter + (options.screen.yPixels*0.55);

        % create horizontal line
        baseRectLong   = [0 0 (squareXposR-squareXposL) 10];
        
        % Center the rectangle on the centre of the screen
        centeredRect   = CenterRectOnPointd(baseRect+(xPosition-1), squareXpos, yCenter);
        centeredRectL  = CenterRectOnPointd(baseRect, squareXposL, yCenter);
        centeredRectR  = CenterRectOnPointd(baseRect, squareXposR, yCenter);
        centeredRectLong = CenterRectOnPointd(baseRectLong, xCenter, yCenter);

        % Draw the rect to the screen
        Screen('FillRect', options.screen.windowPtr, [],[centeredRect' centeredRectL'...
              centeredRectR' centeredRectLong']);
        Screen('Flip', options.screen.windowPtr);

        % Increment the time
        time = time + options.screen.flipInterval;
        
       % wait for response
        keyCode      = eventListener.commandLine.detectKey(KBNumber,doKeyboard);
        
        if ~isempty(keyCode)
            recordedResp = 1;
        end
    end

%% RECORD Response
RT           = GetSecs() - loopStartTime;
[~,dataFile] = eventListener.logData(RT,taskSaveName,'rt',dataFile,trial);
[~,dataFile] = eventListener.logData(xPosition,taskSaveName,'response',dataFile,trial);
    
end