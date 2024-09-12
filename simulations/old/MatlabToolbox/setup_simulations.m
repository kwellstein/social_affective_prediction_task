function [] = setup_simulations

%% setup_simulations
% Simulate synthetic agents by sampling from the prior distributions of the
% models used in the analyses.
%
% SYNTAX:       setup_simulations
%
% OUT:    sim.mat: struct, includes all simulated agents' responses and
%                  model parameters
%         Figures: {fig, png}, all belief predictions on the lowest level by all agents
%                  across all trials
%agent. 
%
% Subfunctions: gen_trajectory.m
%
% Original: XX.XX.XXXX - Katharina V. Wellstein
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

addpath(genpath(options.paths.toolbox));
disp('************************************** SETUP_SIMULATIONS **************************************');
disp('*');
disp('*');


%% GENERATE synthetic agents using default priors from toolbox
sim.agent  = struct();
input      = struct();

for m = 1:numel(modelFeatures.model.space)

    for n = 1:options.sim.nSamples

        % sample free parameter values
        input.prc.transInp = modelFeatures.modelSpace(m).prc_config.priormus;
        input.obs.transInp = modelFeatures.modelSpace(m).obs_config.priormus;

        for j = 1:size(modelFeatures.modelSpace(m).prc_idx,2)
            input.prc.transInp(modelFeatures.modelSpace(m).prc_idx(j)) = ...
                normrnd(modelFeatures.modelSpace(m).prc_config.priormus(modelFeatures.modelSpace(m).prc_idx(j)),...
                abs(sqrt(modelFeatures.modelSpace(m).prc_config.priorsas(modelFeatures.modelSpace(m).prc_idx(j)))));
        end
        for k = 1:size(modelFeatures.modelSpace(m).obs_idx,2)
            input.obs.transInp(modelFeatures.modelSpace(m).obs_idx(k)) = ...
                normrnd(modelFeatures.modelSpace(m).obs_config.priormus(modelFeatures.modelSpace(m).obs_idx(k)),...
                abs(sqrt(modelFeatures.modelSpace(m).obs_config.priorsas(modelFeatures.modelSpace(m).obs_idx(k)))));
        end

        % create simulation input vectors (native space)
        c.c_prc = modelFeatures.modelSpace(m).prc_config;
        input.prc.nativeInp = modelFeatures.modelSpace(m).prc_config.transp_prc_fun(c, input.prc.transInp);
        c.c_obs = modelFeatures.modelSpace(m).obs_config;
        input.obs.nativeInp = modelFeatures.modelSpace(m).obs_config.transp_obs_fun(c, input.obs.transInp);

        % simulate predictions for SNR calculation
        stable = 0;

        while stable == 0
            try %tapas_simModel(inputs, prc_model, prc_pvec, varargin)
                sim_est = tapas_simModel(options.task.u,...
                    modelFeatures.modelSpace(m).prc,...
                    input.prc.nativeInp,...
                    modelFeatures.modelSpace(m).obs,...
                    input.obs.nativeInp,...
                    modelFeatures.rng.settings.State(modelFeatures.rng.idx, 1));
                stable = 1;

            catch
                fprintf('simulation failed for synth. agent %1.0f \n',n);
            end

            % save simulation input
            sim.agent(n,m).data = sim_est;

            % Update the rng state idx
            modelFeatures.rng.idx    = modelFeatures.rng.idx+1;
            if modelFeatures.rng.idx == (length(modelFeatures.rng.settings.State)+1)
                modelFeatures.rng.idx = 1;
            end
        end

    end
end

%% PLOT predictions

for n = 1:options.sim.nSamples
    any(strcmp('muhat',fieldnames(sim.agent(1).data.traj)));
    plot(sim.agent(n).data.traj.muhat(:,1), 'color', options.col.tnub)
    ylabel('$\hat{\mu}_{1}$', 'Interpreter', 'Latex')
    hold on;
end

ylim([-0.1 1.1])
plot(sim.agent(1).data.u,'o','Color','b');
plot(options.plotting.probStr,'Color','b');
xlabel('trials')
txt = ['model: ', modelFeatures.model.space]; % only coded for case 1 model
title(txt)

figdir = fullfile([options.sim.saveDir,'/predictions']);
save([figdir,'.fig'])
print(figdir, '-dpng');
close;

% reset rng state idx
options.rng.idx = 1;

%% SAVE model simulation specs as struct
save([options.sim.saveDir,'/sim'], '-struct', 'sim');

disp('simulated data successfully created.')

end