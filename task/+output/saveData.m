function saveData(options,dataFile)

% -----------------------------------------------------------------------
% saveData.m saves all datafile and the options file that contains the
%            specifications for this task run in the appropriate place
%
%   SYNTAX:     output.saveData(options,dataFile)
%
%   IN:     options:  struct containing general and task specific
%                        options
%           dataFile: struct containing all data recorded during task,
%                     fields specified in initDataFile.m
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

mkdir(fullfile(options.files.savePath));

save(fullfile([options.files.savePath,options.files.dataFileName]),'dataFile');
save(fullfile([options.files.savePath,options.files.optionsFileName]),'options');

if options.doEye
    movefile(options.files.eyeFileName,options.files.savePath)
end

exist = dir([options.paths.codeDir,filesep,'ppu_data.txt']);
if ~isempty(exist)
    ppu_data      = readtable('ppu_data.txt');
    delete ppu_data.txt
    save(fullfile([options.files.savePath,filesep,options.files.ppuFileName,'.mat']),'ppu_data');
end

diary off
save(fullfile([options.files.savePath,filesep,options.task.name,'_diary.txt']));

end
