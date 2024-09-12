function options = set_options

%% hgf_set_analysis_options
%  - specify settings for computational analyses
%  - Note: participant IDs for the pilot dataset as well as the main dataset are
%    hardcoded in this function!
%
%   SYNTAX:       options = set_options
%
%   OUT:          options:  struct containing settings and global variables for
%                           the comutational models as well as the participant
%                           IDs for the pilot as well as the main dataset
%
% Original: XXX; Katharina V. Wellstein
% -------------------------------------------------------------------------
% Copyright (C) 2024, Katharina V. Wellstein,
% katharina.wellstein@newcastle.edu.au
%
% This file is released under the terms of the GNU General Public Licence
% (GPL), version 3. You can redistribute it and/or modify it under the
% terms of the GPL (either version 3 or, at your option, any later version).
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details:
% <http://www.gnu.org/licenses/>
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% _________________________________________________________________________
% =========================================================================

%% ANALYSIS STEPS to exectute
options.doSimulations      = 1;
options.doPlotTrajectories = 1;

%% SPECIFY PATHS

% specify analysis stage
stage = 'synthData'; % synthData pilotData % mainData

switch stage
    case 'genTraj'
        [probStr,savepath]        = gen_trajectory;
        options.sim.saveDir       = savepath;
        options.files.inputs      = [savepath,'/inputs.mat'];
        options.paths.toolbox     = '/Users/kwellste/projects/Toolboxes/tapas-6.0.1';
        options.plotting.probStr  = probStr;
        
    case 'simulations'
        date     = char(datetime('today'));
        options.sim.saveDir   = [pwd,'/simulations_',date];
        options.files.inputs  = [options.sim.saveDir,'/inputs.mat'];
        options.paths.toolbox = '/Users/kwellste/projects/Toolboxes/tapas-6.0.1';


    case 'synthData'
        options.sim.saveDir   = pwd;
        options.files.inputs  = [pwd,'/simulations_17-Apr-2024/inputs.mat'];
        options.paths.toolbox = '/Users/kwellste/projects/Toolboxes/tapas-6.0.1';

    case 'pilotData'
    case 'mainData'
end

if ~exist(options.sim.saveDir,'dir')
    mkdir(options.sim.saveDir)
end

%% SPECIFY FILE NAMES

%% SPECIFY EXPERIMENT-RELATED options
options.task = load(options.files.inputs,'u');
options.task.acronym = 'SEPAB_';

%% SPECIFY ANALYSIS SETTINGS

% simulation analyses
options.sim.nSamples = 100;


%% colors for plotting
% define colors
options.col.wh   = [1 1 1];
options.col.gry  = [0.5 0.5 0.5];
options.col.tnub = [0 110 182]/255;
options.col.tnuy = [255 166 22]/255;
options.col.grn  = [0 0.6 0];

end