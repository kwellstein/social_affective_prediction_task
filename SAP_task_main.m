
%% _______________________________________________________________________________%
%% MAIN Script for Social-Affective Prediction (SAP) Task 
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
%
%% _______________________________________________________________________________%
% vagus_study.m allows the experimenter to specify information on the mode the 
%               task will be run in, the participant's PPID, and the visit number.
%               The latter will be converted to the protocol type, depending 
%               on the PPID. This ensures the anonymous randomisation of study 
%               visits per PPID as defined a-priori by an external entity.
%
% SYNTAX:  [expMode,PPID,visitNo,stairType] = vagus_study
%
% OUT:      expMode: - In 'debug' mode timings are shorter, and the experiment
%                     won't be full screen. You may use breakpoints.
%                   - In 'experiment' mode you are running the entire
%                     experiment as it is intended
%
%           PPID:    A 4-digit integer (0001:0999) PPIDs have
%                   been assigned to participants a-priori
%
%           visitNo: A 1-digit integer (1:4). Each participant will be doing
%                   this task 4 times.
%
%  AUTHOR:  Coded by: Katharina V. Wellstein, December 2019
% _______________________________________________________________________________%

%% INITIALIZE
close all;
clearvars;
clc; 

%% SPECIFY inputs
expMode   = input('Enter ''debug'' or ''experiment'' ','s');
expType   = input('Enter ''behav'' or ''fmri'' ','s');
PPID      = input('SNG_SAPS_','s');

%% Check if inputs are correct

if strcmp(expMode, 'debug')     % expMode check
   disp('You are running the SAP task in DEBUG mode'); 
    elseif strcmp(expMode, 'experiment')
           disp('You are running the SAP task in EXPERIMENT mode');
    else
        expMode = input('Your input is not correct, type either ''debug'' or ''experiment'' :','s');
end                             % END of mode check

if strcmp(stairType, 'behav')% expType check
   disp('You are running the SAP task behaviorally'); 
elseif strcmp(stairType, 'fmri')
           disp('You are running the the SAP task in the scanner'); 
    else
        stairType = input('Your input is not correct, type either ''behav'' or ''fmri'' :','s');
end % END expType check

if ~numel(PPID) == 4 % PPID check
    disp('PPID has to be a 4 digit string');
end                  % END PPID check
    
%% SETUP OPTIONS
options = eventCreator.specifyOptions(expMode,expType);

%% SETUP ENVIRONMENT
options = tools.prepEnvironment(options);

%%