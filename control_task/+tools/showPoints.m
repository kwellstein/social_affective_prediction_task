function showPoints(options,currPoints)
%% _______________________________________________________________________________%
%% MAIN Function for Social-Affective Prediction Control (SAPC) Task
%
% SYNTAX:  ....
%
% AUTHOR:  Coded by: Katharina V. Wellstein, XX.2024,
%                    katharina.wellstein@newcastle.edu.au
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

%% collect and sum up all points across tasks
points = zeros(1,options.task.sequenceIdx);
points(1) = currPoints;

if options.task.sequenceIdx>1

    for i = 2:options.task.sequenceIdx
        data = load(fullfile(options.files.savePath,filesep,'*',options.files.dataFileExtension));
        opt  = load(fullfile(options.files.savePath,filesep,'*',options.files.optionsFileExtension));
        fieldName = [opt.task.name,'Summary'];
        points(i) = data.(fieldName).points;
        clear data
        clear opt
    end
end

totalPoints = sum(points);

%% select text to be shown on screen
if totalPoints >= options.task.firstTarget
    targetText = options.screen.firstTagetText;
elseif totalPoints >= options.task.finalTarget
    targetText = options.screen.finalTagetText;
else
    targetText = options.screen.noTagetText;
end

pointsText = [options.screen.pointsText,num2str(totalPoints)];

%% show points screens
% show points screen
DrawFormattedText(options.screen.windowPtr,pointsText,'center',[],[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);

% show target screen
DrawFormattedText(options.screen.windowPtr,targetText,'center',[],[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showReadyScreen,options,dataFile,0);

end