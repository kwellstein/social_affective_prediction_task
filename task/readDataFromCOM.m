function readDataFromCOM

%% _______________________________________________________________________________%
% readDataFromCOM.m reads data from a device connected with a serialport
% and saves data after experiment is finished
%
% SYNTAX:  readDataFromCOM(options)
%
% IN:       options:  struct containing general and task specific options

%
%  AUTHOR:  Coded by: Katharina V. Wellstein, XX.2024
%                     katharina.wellstein@newcastle.edu.au
%                     https://github.com/kwellstein
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

sObj = serialport("COM3",9600);

flush(sObj);
save('sObj.mat');
reading = 1;

fileID = fopen('ppu_data.txt','w');
fprintf(fileID,'%6s %12s\n','data','time');

while reading
    data = str2num(readline(sObj));
    time = extractAfter(char(datetime('now')),12);
    fprintf(fileID,'%d %12s\n',data,time);
end

end