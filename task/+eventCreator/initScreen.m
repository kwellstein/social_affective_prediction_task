function options = initScreen(options,expMode)

% -----------------------------------------------------------------------
% initScreen.m initializes and opens the screen for the task
%
%   SYNTAX:     options = initScreen(options)
%
%   IN:         options: struct, options the tasks will run, 
%                                e.g. screen information in options.screen
%
%   OUT:        options: struct, updated information in options.screen
%
%   AUTHOR:     Based on: Frederike Petzschner, April 2017
%               Amended:  Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%
%% Setting up screen options and open screen

% Get size of the on screen window 
[options.screen.xpixels, options.screen.ypixels] = Screen('WindowSize', options.screen.number);

% Open window
if strcmp(expMode,'debug')
    % [win, winRect] = Screen('OpenWindow', screenid, clearcolor, winRect, pixelSize, numbuffers, stereomode, multiSample, imagingMode, specialFlags, clientRect, fbOverrideRect, vrrParams);
[options.screen.windowPtr,~] = PsychImaging('OpenWindow', options.screen.number, options.screen.black, ...
    options.screen.rect,[options.screen.xpixels, options.screen.ypixels]);
else
[options.screen.windowPtr,~] = PsychImaging('OpenWindow', options.screen.number, 'General','Full');
end
% Query the frame duration: [ monitorFlipInterval nrValidSamples stddev ]
[options.screen.flipInterval,~,~] = Screen('GetFlipInterval', options.screen.windowPtr);

end

