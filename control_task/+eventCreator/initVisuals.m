function stimuli = initVisuals(options,expMode,expType)

% -----------------------------------------------------------------------
% initVisuals.m prepares the experiment slides so that they can be
%               presented via PsychToolbox
%
%   SYNTAX:       stimuli = eventCreator.initVisuals(options,expMode,expType)
%
%   IN:          options:  struct, options the tasks will run with
%
%                expMode: - In 'debug' mode timings are shorter, and the experiment
%                           won't be full screen. You may use breakpoints.
%                         - In 'practice' mode you are running the entire
%                           the practice round as it has been specified in
%                           specifyOptions.m
%                         - In 'experiment' mode you are running the entire
%                           experiment as it has been specified in
%                           specifyOptions.m
%
%                 expType: - 'behav': use keyboard and different instructions and
%                            more as specified in specifyOptions.m
%                          - 'fmri': use button box and different instructions
%                            more as specified in specifyOptions.m
%
%   OUT:          stimuli: struct, contains names of slides initiated in
%                                 initiate Visuals
%
%   AUTHOR:     Coded by: Katharina V. Wellstein, December 2019
%                         Amended for SAPS study October 2024
%                         katharina.wellstein@newcastle.edu.au
%                         https://github.com/kwellstein
%
% -------------------------------------------------------------------------
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

%% LOAD images

switch expType
    case 'behav'
        switch expMode
            case 'practice'
                imgIntro  = imread('stimuli/behav_practice_intro','png');
                imgIntro2 = imread('stimuli/behav_practice_intro2','png');
                imgIntro3 = imread('stimuli/behav_practice_intro3','png');
                imgMinus  = imread('stimuli/behav_practice_minuspoint','png');
                imgPlus   = imread('stimuli/behav_practice_pluspoint','png');
                imgCollectCoin   = imread('stimuli/outcome_collected_coin','png');
                imgRejectCoin    = imread('stimuli/outcome_collected_coin','png');
                imgCollectNoCoin = imread('stimuli/outcome_collected_noCoin','png');
                imgRejectNoCoin  = imread('stimuli/outcome_rejected_noCoin','png');
                stimuli.intro2 = Screen('MakeTexture', options.screen.windowPtr, imgIntro2);
                stimuli.intro3        = Screen('MakeTexture', options.screen.windowPtr, imgIntro3);
                stimuli.collectCoin   = Screen('MakeTexture', options.screen.windowPtr,imgCollectCoin);
                stimuli.rejectCoin    = Screen('MakeTexture', options.screen.windowPtr,imgRejectCoin);
                stimuli.collectNoCoin = Screen('MakeTexture', options.screen.windowPtr,imgCollectNoCoin);
                stimuli.rejectNoCoin  = Screen('MakeTexture', options.screen.windowPtr,imgRejectNoCoin);

            case 'experiment'
                imgIntro  = imread('stimuli/behav_main_intro','png');

        end

    case 'fmri'
        switch expMode
            case 'practice'
                imgIntro  = imread('stimuli/fmri_practice_intro','png');
                imgIntro2 = imread('stimuli/fmri_practice_intro2','png');
                imgIntro3 = imread('stimuli/fmri_practice_intro3','png');
                imgCollectCoin   = imread('stimuli/outcome_collected_coin','png');
                imgRejectCoin    = imread('stimuli/outcome_collected_coin','png');
                imgCollectNoCoin = imread('stimuli/outcome_collected_noCoin','png');
                imgRejectNoCoin  = imread('stimuli/outcome_rejected_noCoin','png');
                stimuli.intro2 = Screen('MakeTexture', options.screen.windowPtr, imgIntro2);
                stimuli.intro3        = Screen('MakeTexture', options.screen.windowPtr, imgIntro3);
                stimuli.collectCoin   = Screen('MakeTexture', options.screen.windowPtr,imgCollectCoin);
                stimuli.rejectCoin    = Screen('MakeTexture', options.screen.windowPtr,imgRejectCoin);
                stimuli.collectNoCoin = Screen('MakeTexture', options.screen.windowPtr,imgCollectNoCoin);
                stimuli.rejectNoCoin  = Screen('MakeTexture', options.screen.windowPtr,imgRejectNoCoin);

            case 'experiment'
                imgIntro  = imread('stimuli/fmri_main_intro','png');

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

imgMinus = imread('stimuli/minus_point','png');
imgPlus  = imread('stimuli/plus_point','png');
imgCoin   = imread('stimuli/outcome_coin','png');
imgNoCoin = imread('stimuli/outcome_noCoin','png');
imgITI    = imread('stimuli/iti_fixation','png');
imgReady  = imread('stimuli/task_starting','png');

%% MAKE images into a textures that can be drawn to the screen
stimuli.intro  = Screen('MakeTexture', options.screen.windowPtr, imgIntro);

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

