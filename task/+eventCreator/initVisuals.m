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
                imgMinus  = imread('stimuli/behav_practice_minuspoint','png');
                imgPlus   = imread('stimuli/behav_practice_pluspoint','png');

            case 'experiment'
                imgIntro  = imread('stimuli/behav_main_intro','png');
                imgMinus  = imread('stimuli/minus_point','png');
                imgPlus   = imread('stimuli/plus_point','png');

        end

    case 'fmri'
        imgMinus      = imread('stimuli/minus_point','png');
        imgPlus       = imread('stimuli/plus_point','png');

        switch expMode
            case 'practice'
                imgIntro  = imread('stimuli/fmri_practice_intro','png');

            case 'experiment'
                imgIntro  = imread('stimuli/fmri_main_intro','png');
                imgMinus  = imread('stimuli/minus_point','png');
                imgPlus   = imread('stimuli/plus_point','png');

            case 'debug'
                imgIntro  = imread('stimuli/fmri_practice_intro','png');
        end
end

imgIntroPointsAllTasks = imread('stimuli/intro_points_allTasks','png');
imgIntroPoints2Tasks   = imread('stimuli/intro_points_2Tasks','png');

imgF1_neutral = imread('stimuli/f1_neutral','png');
imgF2_neutral = imread('stimuli/f2_neutral','png');
imgF3_neutral = imread('stimuli/f3_neutral','png');
imgF4_neutral = imread('stimuli/f4_neutral','png');
imgM1_neutral = imread('stimuli/m1_neutral','png');
imgM2_neutral = imread('stimuli/m2_neutral','png');
imgM3_neutral = imread('stimuli/m3_neutral','png');
imgM4_neutral = imread('stimuli/m4_neutral','png');

imgF1_noSmile = imread('stimuli/f1_noSmile','png');
imgF2_noSmile = imread('stimuli/f2_noSmile','png');
imgF3_noSmile = imread('stimuli/f3_noSmile','png');
imgF4_noSmile = imread('stimuli/f4_noSmile','png');
imgM1_noSmile = imread('stimuli/m1_noSmile','png');
imgM2_noSmile = imread('stimuli/m2_noSmile','png');
imgM3_noSmile = imread('stimuli/m3_noSmile','png');
imgM4_noSmile = imread('stimuli/m4_noSmile','png');

imgF1_smile = imread('stimuli/f1_smile','png');
imgF2_smile = imread('stimuli/f2_smile','png');
imgF3_smile = imread('stimuli/f3_smile','png');
imgF4_smile = imread('stimuli/f4_smile','png');
imgM1_smile = imread('stimuli/m1_smile','png');
imgM2_smile = imread('stimuli/m2_smile','png');
imgM3_smile = imread('stimuli/m3_smile','png');
imgM4_smile = imread('stimuli/m4_smile','png');

imgITI   = imread('stimuli/iti_fixation','png');
imgReady = imread('stimuli/task_starting','png');

%% MAKE images into a textures that can be drawn to the screen
stimuli.intro  = Screen('MakeTexture', options.screen.windowPtr, imgIntro);
stimuli.minus  = Screen('MakeTexture', options.screen.windowPtr, imgMinus);
stimuli.plus   = Screen('MakeTexture', options.screen.windowPtr, imgPlus);

stimuli.f1_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF1_neutral);
stimuli.f2_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF2_neutral);
stimuli.f3_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF3_neutral);
stimuli.f4_neutral = Screen('MakeTexture', options.screen.windowPtr, imgF4_neutral);
stimuli.m1_neutral = Screen('MakeTexture', options.screen.windowPtr, imgM1_neutral);
stimuli.m2_neutral = Screen('MakeTexture', options.screen.windowPtr, imgM2_neutral);
stimuli.m3_neutral = Screen('MakeTexture', options.screen.windowPtr, imgM3_neutral);
stimuli.m4_neutral = Screen('MakeTexture', options.screen.windowPtr, imgM4_neutral);

stimuli.f1_noSmile = Screen('MakeTexture', options.screen.windowPtr, imgF1_noSmile);
stimuli.f2_noSmile = Screen('MakeTexture', options.screen.windowPtr, imgF2_noSmile);
stimuli.f3_noSmile = Screen('MakeTexture', options.screen.windowPtr, imgF3_noSmile);
stimuli.f4_noSmile = Screen('MakeTexture', options.screen.windowPtr, imgF4_noSmile);
stimuli.m1_noSmile = Screen('MakeTexture', options.screen.windowPtr, imgM1_noSmile);
stimuli.m2_noSmile = Screen('MakeTexture', options.screen.windowPtr, imgM2_noSmile);
stimuli.m3_noSmile = Screen('MakeTexture', options.screen.windowPtr, imgM3_noSmile);
stimuli.m4_noSmile = Screen('MakeTexture', options.screen.windowPtr, imgM4_noSmile);

stimuli.f1_smile = Screen('MakeTexture', options.screen.windowPtr, imgF1_smile);
stimuli.f2_smile = Screen('MakeTexture', options.screen.windowPtr, imgF2_smile);
stimuli.f3_smile = Screen('MakeTexture', options.screen.windowPtr, imgF3_smile);
stimuli.f4_smile = Screen('MakeTexture', options.screen.windowPtr, imgF4_smile);
stimuli.m1_smile = Screen('MakeTexture', options.screen.windowPtr, imgM1_smile);
stimuli.m2_smile = Screen('MakeTexture', options.screen.windowPtr, imgM2_smile);
stimuli.m3_smile = Screen('MakeTexture', options.screen.windowPtr, imgM3_smile);
stimuli.m4_smile = Screen('MakeTexture', options.screen.windowPtr, imgM4_smile);

stimuli.intro_points_allTasks = Screen('MakeTexture', options.screen.windowPtr, imgIntroPointsAllTasks);
stimuli.intro_points_2Tasks   = Screen('MakeTexture', options.screen.windowPtr, imgIntroPoints2Tasks);
stimuli.ITI    = Screen('MakeTexture', options.screen.windowPtr, imgITI);
stimuli.ready  = Screen('MakeTexture', options.screen.windowPtr, imgReady);
end

