function options = prepEnvironment

%% _______________________________________________________________________________%
% prepEnvironment.m ensures a 'fresh start' for the task to run by closing
%                   and resetting everything that might be left over from
%                   previous runs of this task and saves information on
%                   devices used into options struct.
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
%   AUTHOR:         Coded by: Katharina V. Wellstein, December 2019 as part of VAGUS
%                             Amended for SAP task October 2024
%                             katharina.wellstein@newcastle.edu.au
%                             https://github.com/kwellstein
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
        options.OS       = 'Mac';
        options.PC       = 'Kwellstein';
        options.KBNumber = eventListener.commandLine.findKeyboardNumber(options.OS);
        Screen('Preference', 'SkipSyncTests', 1);
        ListenChar(-1);
        
    case 'user' %  LINUX
        PsychPortAudio('Close');
        PsychRTBox('CloseAll');
        options.OS       = 'Linux';
        options.KBNumber = eventListener.commandLine.findKeyboardNumber();   
        ListenChar(-1);
    
    case  'desktop-gs6gd6n\testing' % EEG computer ("stimmy")
        PsychRTBox('CloseAll'); 
        options.OS       = 'Windows';
        options.PC       = 'EEGLab_Computer';
        options.KBNumber = eventListener.commandLine.findKeyboardNumber(options.OS);
        Screen('Preference', 'SkipSyncTests', 1);
        ListenChar(-1);
        
    case  'desktop-sqh0ch5\hmri' % fMRI scanner computer ("showy")
        PsychRTBox('CloseAll'); 
        options.OS       = 'Windows';
        options.PC       = 'Scanner_Computer';
        options.EMG.portAddress = 16360;
        options.KBNumber = eventListener.commandLine.findKeyboardNumber(options.OS);
        Screen('Preference', 'SkipSyncTests', 1);
        ListenChar(-1);
end

end
