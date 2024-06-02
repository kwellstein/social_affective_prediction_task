function KBNumber = findKeyboardNumber(OS)

% -----------------------------------------------------------------------
% findKeyboardNumber.m sometimes in Mac there are multiple devices and also
%                      multiple keyboards. if you want to wait for a KB response
%                      it can happem that KbCheck is looking at the wrong keyboard. 
%                      This script returns the correct device number for the 
%                      first keyboard detected
%
%   SYNTAX:     KBNumber = eventListener.commandLine.findKeyboardNumber(OS)
%
%   OUT:        KBNumber: integer, number of the first found keyboard device
%
%   AUTHOR:     coded by: Frederike Petzschner, April 2017
%               amended:  Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%

% Enumerate all HID devices:
if strcmp(OS,'Windows') || strcmp(OS,'Linux')
    % On Linux or Windows we only enumerate type 4 - slave keyboard devices. These are what we want:
    LoadPsychHID;
    devices = PsychHID('Devices', 4);
else
    % On other OS'es enumerate everything and filter later:
    devices = PsychHID('Devices');
end

for k=1:length(devices)
    if strcmp(OS,'Windows') || strcmp(OS,'Linux')
        dT=devices(k).transport;
        dU=devices(k).usageName;
        if strcmp('Keyboard',dT)
            KBNumber=devices(k).index;
            break % takes first device that is a keyboard (no break would take last)
            
        else strcmp('slave keyboard',dU)
            KBNumber=devices(k).index;
            break % takes first device that is a keyboard (no break would take last)
        end
    else
        dN=devices(k).usageName;
        if strcmp('Keyboard',dN)
            KBNumber=devices(k).index;
            break % takes first device that is a keyboard (no break would take last)
        end
    end
end