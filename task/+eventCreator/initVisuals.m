function cues = initVisuals(options)
% -----------------------------------------------------------------------
% initVisuals.m prepares the experiment slides so that they can be
%               presented via PsychToolbox
%   
%   SYNTAX:       cues = initVisuals(options)
%
%   IN:           options:  struct, options the tasks will run with
%
%   OUT:          cues:     struct, contains names of slides initiated in
%                                 initiate Visuals
%
%   SUBFUNCTIONS: GetSecs.m; wait2.m adaptiveStimulation.m;
%                 simulateStimAmps.m; logEvent.m; logData.m;
%                 plotAmplitudes.m
%
%   AUTHOR:     Coded by: Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%
%% LOAD images

%~~~~~~~~~~~ general task introduction ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
imgIntro1             = imread('cues/vagus_intro_1','png');
imgIntro2             = imread('cues/vagus_intro_2','png');
imgIntro3             = imread('cues/vagus_intro_3','png');
imgIntro4             = imread('cues/vagus_intro_4','png');
imgIntro5             = imread('cues/vagus_intro_5','png');
imgIntro6             = imread('cues/vagus_intro_6','png');

%~~~~~~~~~~~ introduction to rest / physio phase ~~~~~~~~~~~~~~~~~~~~~~~~~~
imgRest1              = imread('cues/vagus_rest_1','png');
imgRest2              = imread('cues/vagus_rest_2','png');

%~~~~~~~~~~~ introduction to calibration to pain threshhold ~~~~~~~~~~~~~~~
imgPainDetect1        = imread('cues/vagus_painDetect_1','png');
imgPainDetect2        = imread('cues/vagus_painDetect_2','png');

%~~~~~~~~~~~ introduction to staircase measurement ~~~~~~~~~~~~~~~~~~~~~~~~
imgStair1             = imread('cues/vagus_stair_1','png');
imgStair2             = imread('cues/vagus_stair_2','png');
imgStair3             = imread('cues/vagus_stair_3','png');
imgStair4             = imread('cues/vagus_stair_4','png');
imgStair5             = imread('cues/vagus_stair_5','png');
imgStair6             = imread('cues/vagus_stair_6','png');

%~~~~~~~~~~~ introduction to calibration of stimulation threshold ~~~~~~~~~
imgCalib1             = imread('cues/vagus_calib_1','png');
imgCalib2             = imread('cues/vagus_calib_2','png');

%~~~~~~~~~~~ introduction to break ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
imgBreak              = imread('cues/vagus_break','png');

%~~~~~~~~~~~ introduction to task phases for stimulation ~~~~~~~~~~~~~~~~~~
imgStim1              = imread('cues/vagus_stim_1','png');
imgStim2              = imread('cues/vagus_stim_2','png');

%~~~~~~~~~~~ indication of end of phases ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
imgEndRestPhase1_1    = imread('cues/vagus_end_1','png');  % end of 1st rest phase
imgEndRestPhase1_1_2  = imread('cues/vagus_end_2','png');  
imgEndPainDetect1     = imread('cues/vagus_end_3','png');  % end of the pain detection
imgEndPainDetect1_2   = imread('cues/vagus_end_4','png');  
imgEndStair1          = imread('cues/vagus_end_5','png');  % end of staircase
imgEndStair1_2        = imread('cues/vagus_end_6','png');  
imgEndCalib           = imread('cues/vagus_end_7','png');  % end of calibration
imgEndBreak           = imread('cues/vagus_end_8','png');  % end of break
imgEndRestPhase2_1    = imread('cues/vagus_end_9','png');  % end of 2nd rest phase
imgEndRestPhase2_1_2  = imread('cues/vagus_end_10','png');
imgEndStimPhase1_1    = imread('cues/vagus_end_11','png');  % end of 1st stimulation phase
imgEndStimPhase1_1_2  = imread('cues/vagus_end_12','png'); 
imgEndRestPhase3_1    = imread('cues/vagus_end_13','png');  % end of 3rd rest phase
imgEndRestPhase3_1_2  = imread('cues/vagus_end_14','png'); 
imgEndStimPhase2_1    = imread('cues/vagus_end_15','png'); % end of 2nd stimulation phase
imgEndStimPhase2_1_2  = imread('cues/vagus_end_16','png'); 
imgEndExp             = imread('cues/vagus_end_exp','png'); % end of experimeny

%~~~~~~~~~~~ symbols for task ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
imgStimulationStart   = imread('cues/vagus_stimStart','png');
imgStimulationOn      = imread('cues/vagus_stimOn','png');
imgStimulationOff     = imread('cues/vagus_stimOff','png');
imgDetectionT_q       = imread('cues/vagus_detectionT_question','png');
imgPainT_q            = imread('cues/vagus_painDetect_question','png');
imgCountdown1         = imread('cues/vagus_countdown_1','png'); %shows "3..."
imgCountdown2         = imread('cues/vagus_countdown_2','png'); %shows "2..."
imgCountdown3         = imread('cues/vagus_countdown_3','png'); %shows "1..."
imgFixation           = imread('cues/vagus_attn','png');
imgTimeOut            = imread('cues/vagus_timeOut','png');
imgPainDetectRespYes  = imread('cues/vagus_painDetect_respYes','png');
imgPainDetectRespNo  = imread('cues/vagus_painDetect_respNo','png');
imgRespYes            = imread('cues/vagus_respYes','png');
imgRespNo             = imread('cues/vagus_respNo','png');
imgThankYou           = imread('cues/vagus_thankYou','png');

%% MAKE images into a textures that can be drawn to the screen

cues.intro1            = Screen('MakeTexture', options.screen.windowPtr, imgIntro1);
cues.intro2            = Screen('MakeTexture', options.screen.windowPtr, imgIntro2);
cues.intro3            = Screen('MakeTexture', options.screen.windowPtr, imgIntro3);
cues.intro4            = Screen('MakeTexture', options.screen.windowPtr, imgIntro4);
cues.intro5            = Screen('MakeTexture', options.screen.windowPtr, imgIntro5);
cues.intro6            = Screen('MakeTexture', options.screen.windowPtr, imgIntro6);

cues.rest1             = Screen('MakeTexture', options.screen.windowPtr, imgRest1);
cues.rest2             = Screen('MakeTexture', options.screen.windowPtr, imgRest2);

cues.painDetect1       = Screen('MakeTexture', options.screen.windowPtr, imgPainDetect1);
cues.painDetect2       = Screen('MakeTexture', options.screen.windowPtr, imgPainDetect2);

cues.stair1            = Screen('MakeTexture', options.screen.windowPtr, imgStair1);
cues.stair2            = Screen('MakeTexture', options.screen.windowPtr, imgStair2);
cues.stair3            = Screen('MakeTexture', options.screen.windowPtr, imgStair3);
cues.stair4            = Screen('MakeTexture', options.screen.windowPtr, imgStair4);
cues.stair5            = Screen('MakeTexture', options.screen.windowPtr, imgStair5);
cues.stair6            = Screen('MakeTexture', options.screen.windowPtr, imgStair6);

cues.calib1            = Screen('MakeTexture', options.screen.windowPtr, imgCalib1);
cues.calib2            = Screen('MakeTexture', options.screen.windowPtr, imgCalib2);

cues.break             = Screen('MakeTexture', options.screen.windowPtr, imgBreak);

cues.stim1             = Screen('MakeTexture', options.screen.windowPtr, imgStim1);
cues.stim2             = Screen('MakeTexture', options.screen.windowPtr, imgStim2);

cues.endRestPhase1_1   = Screen('MakeTexture', options.screen.windowPtr, imgEndRestPhase1_1);
cues.endRestPhase1_1_2 = Screen('MakeTexture', options.screen.windowPtr, imgEndRestPhase1_1_2);
cues.endPainDetect1    = Screen('MakeTexture', options.screen.windowPtr, imgEndPainDetect1);
cues.endPainDetect1_2  = Screen('MakeTexture', options.screen.windowPtr, imgEndPainDetect1_2);
cues.endStair1         = Screen('MakeTexture', options.screen.windowPtr, imgEndStair1);
cues.endStair1_2       = Screen('MakeTexture', options.screen.windowPtr, imgEndStair1_2);
cues.endCalib          = Screen('MakeTexture', options.screen.windowPtr, imgEndCalib);
cues.endBreak          = Screen('MakeTexture', options.screen.windowPtr, imgEndBreak);
cues.endRestPhase2_1   = Screen('MakeTexture', options.screen.windowPtr, imgEndRestPhase2_1);
cues.endRestPhase2_1_2 = Screen('MakeTexture', options.screen.windowPtr, imgEndRestPhase2_1_2);
cues.endStimPhase1_1   = Screen('MakeTexture', options.screen.windowPtr, imgEndStimPhase1_1);
cues.endStimPhase1_1_2 = Screen('MakeTexture', options.screen.windowPtr, imgEndStimPhase1_1_2);
cues.endRestPhase3_1   = Screen('MakeTexture', options.screen.windowPtr, imgEndRestPhase3_1);
cues.endRestPhase3_1_2 = Screen('MakeTexture', options.screen.windowPtr, imgEndRestPhase3_1_2);
cues.endStimPhase2_1   = Screen('MakeTexture', options.screen.windowPtr, imgEndStimPhase2_1);
cues.endStimPhase2_1_2 = Screen('MakeTexture', options.screen.windowPtr, imgEndStimPhase2_1_2);
cues.endExp            = Screen('MakeTexture', options.screen.windowPtr, imgEndExp);

cues.stimulationStart  = Screen('MakeTexture', options.screen.windowPtr, imgStimulationStart);
cues.stimulationOn     = Screen('MakeTexture', options.screen.windowPtr, imgStimulationOn);
cues.stimulationOff    = Screen('MakeTexture', options.screen.windowPtr, imgStimulationOff);
cues.detectionT_q      = Screen('MakeTexture', options.screen.windowPtr, imgDetectionT_q);
cues.painT_q            = Screen('MakeTexture', options.screen.windowPtr,imgPainT_q); 

cues.countdown1        = Screen('MakeTexture', options.screen.windowPtr, imgCountdown1);
cues.countdown2        = Screen('MakeTexture', options.screen.windowPtr, imgCountdown2);
cues.countdown3        = Screen('MakeTexture', options.screen.windowPtr, imgCountdown3);
cues.fixation          = Screen('MakeTexture', options.screen.windowPtr, imgFixation);
cues.timeOut           = Screen('MakeTexture', options.screen.windowPtr, imgTimeOut);
cues.painDetectRespYes = Screen('MakeTexture', options.screen.windowPtr, imgPainDetectRespYes);
cues.painDetectRespNo  = Screen('MakeTexture', options.screen.windowPtr, imgPainDetectRespNo);
cues.respYes           = Screen('MakeTexture', options.screen.windowPtr, imgRespYes);
cues.respNo            = Screen('MakeTexture', options.screen.windowPtr, imgRespNo);
cues.thankYou          = Screen('MakeTexture', options.screen.windowPtr, imgThankYou);

end

