function expInfo = prepEnvironment(expInfo)
%% _______________________________________________________________________________%
% prepEnvironment.m ensures a 'fresh start' for the task to run by closing
%                   and resetting everything that might be left over from
%                   previous runs of this task and saves information on
%                   devices used into expInfo struct.
%
%   SYNTAX:         expInfo = tools.prepEnvironment(expInfo)
%
%   IN:             expInfo: struct containing general info regarding this
%                        experiment run
%
%   OUT:            expInfo: struct, updated file containing KBNumber, OS
%       
%   SUBFUNCTIONS:   findKeyboardNumber.m; PsychDefaultSetup;
%
%   AUTHOR:         Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%

%% close audio devices and response boxes and check keys

[~, uid] = unix('whoami');
switch uid(1: end-1)
    case 'kwellste' % Mac User
        PsychPortAudio('Close');
        PsychRTBox('CloseAll');
        expInfo.KBNumber = eventListener.commandLine.findKeyboardNumber();
        expInfo.OS       = 'Mac';
        Screen('Preference', 'SkipSyncTests', 1);
        
    case 'user' % Interoception Lab LINUX
        PsychPortAudio('Close');
        PsychRTBox('CloseAll');
        expInfo.KBNumber = eventListener.commandLine.findKeyboardNumber();
        expInfo.OS       = 'Linux';
        
    case 'siglesias' % Windows User
         PsychRTBox('CloseAll'); 
         expInfo.OS       = 'Windows';     
    
%     case 'yourID' % Windows User
%         PsychRTBox('CloseAll'); 
%         expInfo.OS       = 'OS'; 
%         expInfo.KBNumber = eventListener.commandLine.findKeyboardNumber();
%         expInfo.OS       = 'OS';
%         Screen('Preference', 'SkipSyncTests', 1);
end

end
