function [] = sim_data_modelinversion()

%% sim_data_modinversion
%  Invert simulated agents with models in the modelspace. This step will be
%  executed if options.doSimulations = 1;
%
%   SYNTAX:       sim_data_modinversion()
%
% Original:  XX.XX.XXXX - Katharina V. Wellstein
% -------------------------------------------------------------------------
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

%% INITIALIZE Variables for running this function
options       = set_options();             % specifications for this analysis
modelFeatures = set_hgf_features(options); % specifications regarding model features

disp('************************************** SIM_DATA_MODELINVERSION **************************************');
disp('*');
disp('*');

% simulation setup
sim = load(fullfile([options.sim.saveDir,'/sim.mat']));

for n = 1:options.sim.nSamples 
    for m_in = 1:numel(modelFeatures.model.space) % model data was generated with
        for m_est = 1:numel(modelFeatures.model.space) % model data will be estimated with
            
            %% MODEL INVERSION
            disp(['Model inversion for agent: ', num2str(n), ' | gen model ',...
                modelFeatures.modelSpace(m_in).name, ' | fitting model: ', modelFeatures.modelSpace(m_est).name]);

            est = tapas_fitModel(sim.agent(n,m_in).data.y,...    % responses
                sim.agent(n,m_in).data.u,...                     % input sequence
                modelFeatures.modelSpace(m_est).prc_config,...         % Prc fitting model
                modelFeatures.modelSpace(m_est).obs_config,...         % Obs fitting model
                modelFeatures.hgf.opt_config,...                       % Optimization algorithm
                0,...                                            % 0 = MAP estimation
                modelFeatures.rng.settings.State(modelFeatures.rng.idx, 1)); % seed for multistart


            %% SAVE model fit as struct
            save_path = fullfile(options.sim.saveDir, ...
                        [options.task.acronym,'simulation_agent', num2str(n),'model_in',...
                         num2str(m_in),'_model_est',num2str(m_est),'.mat']);
            save(save_path, '-struct', 'est');

            % plot trajectories
            if options.doPlotTrajectories
                tapas_hgf_plotTraj_mod(est) % Tapas fucntion modified sliglthy regarding style
            figdir = fullfile([save_path,options.task.acronym,'simulation_agent', num2str(n),'_trajectories']);
            save([figdir,'.fig'])
            print([figdir,'.png'], '-dpng')

            close all;
            end
        end
    end    
end


end