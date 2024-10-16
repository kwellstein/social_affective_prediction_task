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
        imgIntro  = imread('stimuli/behav_main_intro','png');
        imgIntro2 = imread('stimuli/behav_main_intro2','png');

        switch expMode
            case 'practice'
                imgIntro3  = imread('stimuli/behav_practice_intro','png');
                imgMinus  = imread('stimuli/behav_practice_minuspoint','png');
                imgPlus   = imread('stimuli/behav_practice_pluspoint','png');
                imgCollectCoin   = imread('stimuli/outcome_collected_coin','png');
                imgRejectCoin    = imread('stimuli/outcome_collected_coin','png');
                imgCollectNoCoin = imread('stimuli/outcome_collected_noCoin','png');
                imgRejectNoCoin  = imread('stimuli/outcome_rejected_noCoin','png');
                stimuli.intro3 = Screen('MakeTexture', options.screen.windowPtr, imgIntro3);
                stimuli.collectCoin  = Screen('MakeTexture', options.screen.windowPtr,imgCollectCoin);
                stimuli.rejectCoin  = Screen('MakeTexture', options.screen.windowPtr,imgRejectCoin);
                stimuli.collectNoCoin  = Screen('MakeTexture', options.screen.windowPtr,imgCollectNoCoin);
                stimuli.rejectNoCoin  = Screen('MakeTexture', options.screen.windowPtr,imgRejectNoCoin);

            case 'experiment'
                imgMinus  = imread('stimuli/minus_point','png');
                imgPlus   = imread('stimuli/plus_point','png');

        end

    case 'fmri'
        imgIntro  = imread('stimuli/fmri_main_intro','png');
        imgIntro2 = imread('stimuli/fmri_main_intro2','png');
        imgMinus      = imread('stimuli/minus_point','png');
        imgPlus       = imread('stimuli/plus_point','png');

        switch expMode
            case 'practice'
                imgIntro3  = imread('stimuli/fmri_practice_intro','png');

                imgCollectCoin   = imread('stimuli/outcome_collected_coin','png');
                imgRejectCoin    = imread('stimuli/outcome_collected_coin','png');
                imgCollectNoCoin = imread('stimuli/outcome_collected_noCoin','png');
                imgRejectNoCoin  = imread('stimuli/outcome_rejected_noCoin','png');
                stimuli.intro3 = Screen('MakeTexture', options.screen.windowPtr, imgIntro3);
                stimuli.collectCoin  = Screen('MakeTexture', options.screen.windowPtr,imgCollectCoin);
                stimuli.rejectCoin  = Screen('MakeTexture', options.screen.windowPtr,imgRejectCoin);
                stimuli.collectNoCoin  = Screen('MakeTexture', options.screen.windowPtr,imgCollectNoCoin);
                stimuli.rejectNoCoin  = Screen('MakeTexture', options.screen.windowPtr,imgRejectNoCoin);
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
%
% imgF1_egg = imread('stimuli/f1_egg','png');
% imgF2_egg = imread('stimuli/f2_egg','png');
% imgF3_egg = imread('stimuli/f3_egg','png');
% imgF4_egg = imread('stimuli/f4_egg','png');
% imgM1_egg = imread('stimuli/m1_egg','png');
% imgM2_egg = imread('stimuli/m2_egg','png');
% imgM3_egg = imread('stimuli/m3_egg','png');
% imgM4_egg = imread('stimuli/m4_egg','png');

imgF1_eggCollected = imread('stimuli/f1_eggCollected','png');
imgF2_eggCollected = imread('stimuli/f2_eggCollected','png');
imgF3_eggCollected = imread('stimuli/f3_eggCollected','png');
imgF4_eggCollected = imread('stimuli/f4_eggCollected','png');
imgM1_eggCollected = imread('stimuli/m1_eggCollected','png');
imgM2_eggCollected = imread('stimuli/m2_eggCollected','png');
imgM3_eggCollected = imread('stimuli/m3_eggCollected','png');
imgM4_eggCollected = imread('stimuli/m4_eggCollected','png');
imgNo_eggCollected = imread('stimuli/no_eggCollected','png');

imgCoin   = imread('stimuli/outcome_coin','png');
imgNoCoin = imread('stimuli/outcome_noCoin','png');
imgITI    = imread('stimuli/iti_fixation','png');
imgReady  = imread('stimuli/task_starting','png');

%% MAKE images into a textures that can be drawn to the screen
stimuli.intro  = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
stimuli.intro2 = Screen('MakeTexture', options.screen.windowPtr, imgIntro2);

stimuli.minus  = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
stimuli.plus   = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

stimuli.f1_egg = Screen('MakeTexture', options.screen.windowPtr, imgF1_egg);
stimuli.f2_egg = Screen('MakeTexture', options.screen.windowPtr, imgF2_egg);
stimuli.f3_egg = Screen('MakeTexture', options.screen.windowPtr, imgF3_egg);
stimuli.f4_egg = Screen('MakeTexture', options.screen.windowPtr, imgF4_egg);
stimuli.m1_egg = Screen('MakeTexture', options.screen.windowPtr, imgM1_egg);
stimuli.m2_egg = Screen('MakeTexture', options.screen.windowPtr, imgM2_egg);
stimuli.m3_egg = Screen('MakeTexture', options.screen.windowPtr, imgM3_egg);
stimuli.m4_egg = Screen('MakeTexture', options.screen.windowPtr, imgM4_egg);

stimuli.f1_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgF1_eggCollected );
stimuli.f2_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgF2_eggCollected );
stimuli.f3_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgF3_eggCollected );
stimuli.f4_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgF4_eggCollected );
stimuli.m1_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgM1_eggCollected );
stimuli.m2_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgM2_eggCollected );
stimuli.m3_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgM3_eggCollected );
stimuli.m4_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgM4_eggCollected );
stimuli.no_eggCollected  = Screen('MakeTexture', options.screen.windowPtr, imgNo_eggCollected );

stimuli.coin   = Screen('MakeTexture', options.screen.windowPtr, imgCoin);
stimuli.noCoin = Screen('MakeTexture', options.screen.windowPtr, imgNoCoin);
stimuli.ITI    = Screen('MakeTexture', options.screen.windowPtr, imgITI);
stimuli.ready  = Screen('MakeTexture', options.screen.windowPtr, imgReady);
end

