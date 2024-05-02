function options = specifyOptions(expMode,expType)

% -----------------------------------------------------------------------
% specifyOptions.m creates structs for the different stages in the task
%                  Change this file if you would like to change task settings
%
%   SYNTAX:     options = specifyOptions(expMode,stairType)
%
%   IN:         expMode:   string, 'debug' or 'experiment'
%               stairType: string, 'simpleUp','simpleDown','interleaved'
%
%   OUT:        options: struct containing general and task specific
%                        options
%
%   AUTHOR:     Katharina V. Wellstein, XX 2024
%
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
%% specifing what steps will be executed

switch expMode
    case 'experiment'
        % stimulus durations
        options.screen.nIntroSlides = 6;     % no. intro slides
        options.screen.rect         = [0, 0, 1200, 600];
        screens                     = Screen('Screens');
        options.screen.number       = max(screens);
        options.expMode             = 'experiment';

    case 'debug'
        % stimulus durations
        options.screen.nIntroSlides = 6;     % no. intro slides
        options.screen.rect         = [20, 10, 900, 450];
        screens                     = Screen('Screens');
        options.screen.number       = max(screens);  
        options.expMode             = 'debug';
end

%% options screen
options.screen.white = WhiteIndex(options.screen.number);
options.screen.black = BlackIndex(options.screen.number);
options.screen.grey  = options.screen.white / 2;
options.screen.inc   = options.screen.white - options.screen.grey;

%% options keyboard
switch expType
    case 'behav'
        options.keys.startSmile = KbName('j'); % CHANGE
        options.keys.stopSmile  = KbName('n'); % CHANGE
        options.keys.noSmile    = KbName('w'); % CHANGE
        options.keys.escape     = KbName('ESCAPE');
        options.expType         = 'behav';

    case 'fmri'
        options.keys.startSmile = KbName('j'); % CHANGE
        options.keys.stopSmile  = KbName('n'); % CHANGE
        options.keys.noSmile    = KbName('w'); % CHANGE
        options.keys.escape     = KbName('ESCAPE');
        options.expType         = 'fmri';
end

%% options duration of events
% CHANGE
options.dur.waitnxtkeypress   = 5000; % in ms
options.dur.showScreen        = 3000;
options.dur.showIntroScreen   = 10000;
options.dur.showReadyScreen   = 2000;
options.dur.countdown         = 1000;
options.dur.showOff           = 1000; 
options.dur.endWait           = 2000; 
options.dur.rtTimeout         = 100;

%% messages
options.messages.abortText    = 'the experimen was aborted';
options.messages.timeOut      = 'you did not answer in time';

end