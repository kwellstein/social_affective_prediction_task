function showPoints(options,currPoints)

%% _______________________________________________________________________________%
%  showPoints.m calculates and shows participants the points they accumulated thus far at the end
%               of the task
%
%   SYNTAX:     tools.showPoints(options,currPoints)
%
%   IN:     options:    struct containing general and task specific
%                        options
%           currPoints: integer, points accumulated in this task
%
%   AUTHOR:     Katharina V. Wellstein, October 2024
%               katharina.wellstein@newcastle.edu.au
%               https://github.com/kwellstein
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

%% collect and sum up all points across tasks
points = zeros(1,options.task.sequenceIdx);

if options.task.sequenceIdx>1

    % find the indices for valid files that can be loaded
    d = dir(options.files.savePath);
    dFileIdx = zeros(1,size(d,1));
    for f = 1:size(d,1)
        if endsWith(d(f).name,'_dataFile.mat')
            dFileIdx(f) = f;
        else
            dFileIdx(f) = 0;
        end
    end

    dFileIdx(dFileIdx==0)=[];

    for i = 1:size(dFileIdx,2)
        dataFileName = d(dFileIdx(i)).name;
        data = load([options.files.savePath,filesep,dataFileName]);
        points(i+1) = data.dataFile.Summary.points;
        clear data;
    end

    totalPoints = sum(points);
else
    totalPoints = currPoints;
end

pointsText  = [options.screen.pointsText,num2str(totalPoints)];

%% select text to be shown on screen
if totalPoints >= options.task.finalTarget
    targetText = options.screen.finalTargetText;
elseif totalPoints >= options.task.firstTarget
    targetText = options.screen.firstTargetText;
else
    targetText = options.screen.noTargetText;
end


%% show points screens
% show points screen
DrawFormattedText(options.screen.windowPtr,pointsText,'center','center',[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showShortIntro,options,[],0);

% show target screen
DrawFormattedText(options.screen.windowPtr,targetText,'center','center',[255 255 255],[],[],[],1);
Screen('Flip', options.screen.windowPtr);
eventListener.commandLine.wait2(options.dur.showShortIntro,options,[],0);

end