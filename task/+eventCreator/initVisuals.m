function stimuli = initVisuals(options)
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

        imgIntro         = imread('stimuli/practice/behav_practice_intro','png');
        imgQBackgr_F1    = imread('stimuli/pactice/behav_practice_f1_questionBackground','png');
        imgRespPrompt_F1 = imread('stimuli/pactice/behav_practice_f1_respPromt','png');
        imgMinus         = imread('stimuli/pactice/behav_practice_minuspoint','png');
        imgPlus          = imread('stimuli/pactice/behav_practice_pluspoint','png');

        % MAKE images into a textures that can be drawn to the screen
        stimuli.intro         = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
        stimuli.qBackgr_F1    = Screen('MakeTexture', options.screen.windowPtr, imgQBackgr_F1);
        stimuli.respPrompt_F1 = Screen('MakeTexture', options.screen.windowPtr, imgRespPrompt_F1);
        stimuli.minus         = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
        stimuli.plus          = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

    case 'fmri'
        imgMinus         = imread('stimuli/minuspoint','png');
        imgPlus          = imread('stimuli/pluspoint','png');
        stimuli.minus         = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
        stimuli.plus          = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

        switch expMode
            case 'practice'
                imgIntro         = imread('stimuli/practice/fmri_practice_intro','png');
                imgQBackgr_F1    = imread('stimuli/pactice/fmri_practice_f1_questionBackground','png');
                imgRespPrompt_F1 = imread('stimuli/pactice/fmri_practice_f1_respPromt','png');

                % make images into a textures that can be drawn to the screen
                stimuli.intro         = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.qBackgr_F1    = Screen('MakeTexture', options.screen.windowPtr, imgQBackgr_F1);
                stimuli.respPrompt_F1 = Screen('MakeTexture', options.screen.windowPtr, imgRespPrompt_F1);

            case 'experiment'
                imgIntro         = imread('stimuli/practice/fmri_exp_intro','png');
                imgQBackgr_F1    = imread('stimuli/pactice/fmri_exp_f1_questionBackground','png');
                imgRespPrompt_F1 = imread('stimuli/pactice/fmri_exp_f1_respPromt','png');

                % make images into a textures that can be drawn to the screen
                stimuli.intro         = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.qBackgr_F1    = Screen('MakeTexture', options.screen.windowPtr, imgQBackgr_F1);
                stimuli.respPrompt_F1 = Screen('MakeTexture', options.screen.windowPtr, imgRespPrompt_F1);

            case 'debug'
                imgIntro         = imread('stimuli/practice/fmri_practice_intro','png');
                imgQBackgr_F1    = imread('stimuli/pactice/fmri_practice_f1_questionBackground','png');
                imgRespPrompt_F1 = imread('stimuli/pactice/fmri_practice_f1_respPromt','png');

                % make images into a textures that can be drawn to the screen
                stimuli.intro         = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
                stimuli.qBackgr_F1    = Screen('MakeTexture', options.screen.windowPtr, imgQBackgr_F1);
                stimuli.respPrompt_F1 = Screen('MakeTexture', options.screen.windowPtr, imgRespPrompt_F1);
        end
end

imgF1_neutral = imread('stimuli/f1_neutral','png');
imgITI        = imread('stimuli/iti_fixation','png');

% Make images into a textures that can be drawn to the screen
stimuli.F1_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF1_neutral);
stimuli.ITI        = Screen('MakeTexture', options.screen.windowPtr, imgITI );
end

