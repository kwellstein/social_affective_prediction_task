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
        imgIntro         = imread('stimuli/behav_practice_intro','png');
        imgQBackgr_F1    = imread('stimuli/behav_practice_f1_questionBackground','png');
        imgRespPrompt_F1 = imread('stimuli/behav_practice_f1_respPromt','png');
        imgMinus         = imread('stimuli/behav_practice_minuspoint','png');
        imgPlus          = imread('stimuli/behav_practice_pluspoint','png');

        % MAKE images into a textures that can be drawn to the screen
        stimuli.intro         = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
        stimuli.qBackgr_F1    = Screen('MakeTexture', options.screen.windowPtr, imgQBackgr_F1);
        stimuli.respPrompt_F1 = Screen('MakeTexture', options.screen.windowPtr, imgRespPrompt_F1);
        stimuli.minus         = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
        stimuli.plus          = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

    case 'fmri'
        imgMinus         = imread('stimuli/minuspoint','png');
        imgPlus          = imread('stimuli/pluspoint','png');
        stimuli.minus    = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
        stimuli.plus     = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

        switch expMode
            case 'practice'
                imgIntro         = imread('stimuli/fmri_practice_intro','png');
                imgQBackgr_F1    = imread('stimuli/fmri_practice_f1_questionBackground','png');
                imgRespPrompt_F1 = imread('stimuli/fmri_practice_f1_respPromt','png');

                % make images into a textures that can be drawn to the screen
                stimuli.intro         = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.qBackgr_F1    = Screen('MakeTexture', options.screen.windowPtr, imgQBackgr_F1);
                stimuli.respPrompt_F1 = Screen('MakeTexture', options.screen.windowPtr, imgRespPrompt_F1);

            case 'experiment'
                imgIntro         = imread('stimuli/fmri_exp_intro','png');
                imgQBackgr_F1    = imread('stimuli/fmri_exp_f1_questionBackground','png');
                imgRespPrompt_F1 = imread('stimuli/fmri_exp_f1_respPromt','png');

                % make images into a textures that can be drawn to the screen
                stimuli.intro         = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.qBackgr_F1    = Screen('MakeTexture', options.screen.windowPtr, imgQBackgr_F1);
                stimuli.respPrompt_F1 = Screen('MakeTexture', options.screen.windowPtr, imgRespPrompt_F1);

            case 'debug'
                imgIntro         = imread('stimuli/fmri_practice_intro','png');
                imgQBackgr_F1    = imread('stimuli/fmri_practice_f1_questionBackground','png');
                imgRespPrompt_F1 = imread('stimuli/fmri_practice_f1_respPromt','png');

                % make images into a textures that can be drawn to the screen
                stimuli.intro         = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.qBackgr_F1    = Screen('MakeTexture', options.screen.windowPtr, imgQBackgr_F1);
                stimuli.respPrompt_F1 = Screen('MakeTexture', options.screen.windowPtr, imgRespPrompt_F1);
        end
end

imgF1_neutral = imread('stimuli/f1_neutral','png');
imgF2_neutral = imread('stimuli/f2_neutral','png');
imgF3_neutral = imread('stimuli/f3_neutral','png');
imgF4_neutral = imread('stimuli/f4_neutral','png');
imgM1_neutral = imread('stimuli/m1_neutral','png');
imgM2_neutral = imread('stimuli/m2_neutral','png');
imgM3_neutral = imread('stimuli/m3_neutral','png');
imgM4_neutral = imread('stimuli/m4_neutral','png');

imgF1_smile = imread('stimuli/f1_smile','png');
imgF2_smile = imread('stimuli/f2_smile','png');
imgF3_smile = imread('stimuli/f3_smile','png');
imgF4_smile = imread('stimuli/f4_smile','png');
imgM1_smile = imread('stimuli/m1_smile','png');
imgM2_smile = imread('stimuli/m2_smile','png');
imgM3_smile = imread('stimuli/m3_smile','png');
imgM4_smile = imread('stimuli/m4_smile','png');

imgITI        = imread('stimuli/iti_fixation','png');

% Make images into a textures that can be drawn to the screen
stimuli.f1_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF1_neutral);
stimuli.f2_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF2_neutral);
stimuli.f3_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF3_neutral);
stimuli.f4_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF4_neutral);
stimuli.m1_neutral = Screen('MakeTexture', options.screen.windowPtr, imgM1_neutral);
stimuli.m2_neutral = Screen('MakeTexture', options.screen.windowPtr, imgM2_neutral);
stimuli.m3_neutral = Screen('MakeTexture', options.screen.windowPtr, imgM3_neutral);
stimuli.m4_neutral = Screen('MakeTexture', options.screen.windowPtr, imgM4_neutral);

stimuli.f1_smile = Screen('MakeTexture', options.screen.windowPtr, imgF1_smile);
stimuli.f2_smile = Screen('MakeTexture', options.screen.windowPtr, imgF2_smile);
stimuli.f3_smile = Screen('MakeTexture', options.screen.windowPtr, imgF3_smile);
stimuli.f4_smile = Screen('MakeTexture', options.screen.windowPtr, imgF4_smile);
stimuli.m1_smile = Screen('MakeTexture', options.screen.windowPtr, imgM1_smile);
stimuli.m2_smile = Screen('MakeTexture', options.screen.windowPtr, imgM2_smile);
stimuli.m3_smile = Screen('MakeTexture', options.screen.windowPtr, imgM3_smile);
stimuli.m4_smile = Screen('MakeTexture', options.screen.windowPtr, imgM4_smile);

stimuli.ITI        = Screen('MakeTexture', options.screen.windowPtr, imgITI );
end

