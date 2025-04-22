function options = initScreen(options)

% -----------------------------------------------------------------------
% initScreen.m initializes and opens the screen for the task
%
%   SYNTAX:     options = eventCreator.initScreen(options,expMode)
%
%   IN:         options: struct, options the tasks will run,
%                                e.g. screen information in options.screen
%
%               expMode: string, 'debug','practice', or 'experiment'
%
%   OUT:        options: struct, updated information in options.screen
%
%   AUTHOR:     Based on: Frederike Petzschner, April 2017
%               Amended:  Katharina V. Wellstein, December 2019
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

%% Setting up screen options and open screen

% Get size of the on screen window
[options.screen.xpixels, options.screen.ypixels] = Screen('WindowSize', options.screen.number);

% Open window
[options.screen.windowPtr,~] = PsychImaging('OpenWindow', options.screen.number, options.screen.task, ...
    options.screen.rect,[options.screen.xpixels, options.screen.ypixels]);
[options.screen.flipInterval,~,~] =Screen('GetFlipInterval', options.screen.windowPtr);

end

