function stimuli = initVisuals(options,expMode,expType)
% -----------------------------------------------------------------------
% initVisuals.m prepares the experiment slides so that they can be
%               presented via PsychToolbox
%
%   SYNTAX:       stimuli = initVisuals(options)
%
%   IN:           options:  struct, options the tasks will run with
%
%   OUT:          stimuli:     struct, contains names of slides initiated in
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

switch expType
    case 'behav'
        switch expMode
            case 'practice'
                imgIntro = imread('stimuli/behav_practice_intro','png');
                imgMinus = imread('stimuli/behav_practice_minuspoint','png');
                imgPlus  = imread('stimuli/behav_practice_pluspoint','png');

                % MAKE images into a textures that can be drawn to the screen
                stimuli.intro = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.minus = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
                stimuli.plus  = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

            case 'experiment'
                imgIntro = imread('stimuli/behav_main_intro','png');
                imgMinus = imread('stimuli/minus_point','png');
                imgPlus  = imread('stimuli/plus_point','png');

                % MAKE images into a textures that can be drawn to the screen
                stimuli.intro = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.minus = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
                stimuli.plus  = Screen('MakeTexture', options.screen.windowPtr, imgPlus);
        end

    case 'fmri'
        imgMinus      = imread('stimuli/minus_point','png');
        imgPlus       = imread('stimuli/plus_point','png');
        stimuli.minus = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
        stimuli.plus  = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

        switch expMode
            case 'practice'
                imgIntro      = imread('stimuli/fmri_practice_intro','png');

                % make images into a textures that can be drawn to the screen
                stimuli.intro = Screen('MakeTexture', options.screen.windowPtr, imgIntro);

            case 'experiment'
                imgIntro = imread('stimuli/fmri_main_intro','png');
                imgMinus = imread('stimuli/minus_point','png');
                imgPlus  = imread('stimuli/plus_point','png');

                % MAKE images into a textures that can be drawn to the screen
                stimuli.intro = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.minus = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
                stimuli.plus  = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

            case 'debug'
                imgIntro      = imread('stimuli/fmri_practice_intro','png');

                % make images into a textures that can be drawn to the screen
                stimuli.intro = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
        end
end

imgF1_egg = imread('stimuli/f1_eggFace','png');
imgF2_egg = imread('stimuli/f2_eggFace','png');
imgF3_egg = imread('stimuli/f3_eggFace','png');
imgF4_egg = imread('stimuli/f4_eggFace','png');
imgM1_egg = imread('stimuli/m1_eggFace','png');
imgM2_egg = imread('stimuli/m2_eggFace','png');
imgM3_egg = imread('stimuli/m3_eggFace','png');
imgM4_egg = imread('stimuli/m4_eggFace','png');

imgCoin   = imread('stimuli/outcome_coin','png');
imgNoCoin = imread('stimuli/outcome_noCoin','png');
imgITI    = imread('stimuli/iti_fixation','png');
imgReady  = imread('stimuli/task_starting','png');

% Make images into a textures that can be drawn to the screen
stimuli.f1_egg = Screen('MakeTexture', options.screen.windowPtr, imgF1_egg);
stimuli.f2_egg = Screen('MakeTexture', options.screen.windowPtr, imgF2_egg);
stimuli.f3_egg = Screen('MakeTexture', options.screen.windowPtr, imgF3_egg);
stimuli.f4_egg = Screen('MakeTexture', options.screen.windowPtr, imgF4_egg);
stimuli.m1_egg = Screen('MakeTexture', options.screen.windowPtr, imgM1_egg);
stimuli.m2_egg = Screen('MakeTexture', options.screen.windowPtr, imgM2_egg);
stimuli.m3_egg = Screen('MakeTexture', options.screen.windowPtr, imgM3_egg);
stimuli.m4_egg = Screen('MakeTexture', options.screen.windowPtr, imgM4_egg);

stimuli.coin   = Screen('MakeTexture', options.screen.windowPtr, imgCoin);
stimuli.noCoin = Screen('MakeTexture', options.screen.windowPtr, imgNoCoin);
stimuli.ITI    = Screen('MakeTexture', options.screen.windowPtr, imgITI);
stimuli.ready  = Screen('MakeTexture', options.screen.windowPtr, imgReady);
end

