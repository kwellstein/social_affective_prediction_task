function options = prepEnvironment(options)
%% _______________________________________________________________________________%
% prepEnvironment.m ensures a 'fresh start' for the task to run by closing
%                   and resetting everything that might be left over from
%                   previous runs of this task and saves information on
%                   devices used into expInfo struct.
%
%   SYNTAX:         options = tools.prepEnvironment(options)
%
%   IN:             options: struct containing general options needed to
%                            run this task plus general technical information 
%                            about the task run.
%
%   OUT:            options: struct, updated file containing KBNumber, OS
%       
%   SUBFUNCTIONS:   findKeyboardNumber.m; PsychDefaultSetup;
%
%   AUTHOR:         Katharina V. Wellstein, December 2019 as part of VAGUS
%                   task adapted for SAP task
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

%% close audio devices and response boxes and check keys

[~, uid] = unix('whoami');
switch uid(1: end-1)
    case 'kwellste' % Mac User
        PsychPortAudio('Close');
        PsychRTBox('CloseAll');
        options.KBNumber = eventListener.commandLine.findKeyboardNumber();
        options.OS       = 'Mac';
        options.saveRoot = [pwd,'/data'];
        Screen('Preference', 'SkipSyncTests', 1);
        
%     case 'user' %  LINUX
%         PsychPortAudio('Close');
%         PsychRTBox('CloseAll');
%         options.KBNumber = eventListener.commandLine.findKeyboardNumber();
%         options.OS       = 'Linux';
        
%     case 'user' % Windows User
%          PsychRTBox('CloseAll'); 
%          options.OS       = 'Windows';     
    
%     case 'yourID' % Windows User
%         PsychRTBox('CloseAll'); 
%         options.OS       = 'OS'; 
%         options.KBNumber = eventListener.commandLine.findKeyboardNumber();
%         options.OS       = 'OS';
%         Screen('Preference', 'SkipSyncTests', 1);
end

end
