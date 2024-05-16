function KBNumber = findKeyboardNumber(OS)

% -----------------------------------------------------------------------
% findKeyboardNumber.m sometimes in Mac there are multiple devices and also
%                      multiple keyboards. if you want to wait for a KB response
%                      it can happem that KbCheck is looking at the wrong keyboard.
%                      This script returns the correct device number for the
%                      first keyboard detected
%
%   SYNTAX:     KBNumber = findKeyboardNumber()
%
%   OUT:        KBNumber: integer, number of the first found keyboard device
%
%   AUTHOR:     Coded by: Frederike Petzschner, April 2017
%               Amended:  Katharina V. Wellstein, December 2019 for VAGUS study,
%	                                              XX.2024 for SAPS study
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

% Enumerate all HID devices:
if ~strcmp(OS,'Mac')
    % On Linux or Windows we only enumerate type 4 - slave keyboard devices. These are what we want:
    LoadPsychHID;
    devices = PsychHID('Devices', 4);
else
    % On other OS'es enumerate everything and filter later:
    devices = PsychHID('Devices');
end

for k = 1:length(devices)
    if  ~strcmp(OS,'Mac')
        dT = devices(k).transport;
        dU = devices(k).usageName;

        if strcmp('Keyboard',dT)
            KBNumber = devices(k).index;
            break % takes first device that is a keyboard (no break would take last)

        else strcmp('slave keyboard',dU)
            KBNumber = devices(k).index;
            break % takes first device that is a keyboard (no break would take last)
        end

    else
        dN = devices(k).usageName;
        if strcmp('Keyboard',dN)
            KBNumber = devices(k).index;
            break % takes first device that is a keyboard (no break would take last)
        end
    end
end