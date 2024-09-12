function modelFeatures = set_hgf_features(options)

%% set_hgf_features
%  Invert simulated agents with models in the modelspace. This step will be
%  executed if options.doSimulations = 1;
%
%   SYNTAX:       modelFeatures = set_hgf_features(options)
%
%   IN:       options: struct, containing all info for this analysis that
%                      had to be specified, e.g. paths, filenames, task inputs, etc.
%
%   OUT:      modelFeatures: struct, containing all relevant features and
%                            settings for model inversion
%
% Original: Roughly based on code snippets by Alexander Hess (XX.XXXX). 
%           See this code for a full pipeline featuring parts of this
%           function: https://gitlab.ethz.ch/tnu/code/hessetal_spirl_analysis
%
% Amended:  XX.XX.XXXX - Katharina V. Wellstein
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
% =======================================================================

%% optimization algorithm
addpath(genpath(options.paths.toolbox));

modelFeatures.hgf.opt_config              = eval('tapas_quasinewton_optim_config');
modelFeatures.hgf.opt_config.nRandInit    = 100; %%

%% seed for random number generator
modelFeatures.rng.idx      = 1; % Set counter for random number states
modelFeatures.rng.settings = rng(123, 'twister');

%% define model and its related functions
modelFeatures.model.space      = {'eHGF binary'};
modelFeatures.model.prc        = {'tapas_ehgf_binary'};
modelFeatures.model.prc_config = {'tapas_ehgf_binary_config'};
modelFeatures.model.obs	     = {'tapas_unitsq_sgm'};
modelFeatures.model.obs_config = {'tapas_unitsq_sgm_config'};
modelFeatures.model.optim      = {'tapas_quasinewton_optim_config'};
modelFeatures.model.hgf_plot   ={'tapas_ehgf_binary_plotTraj'};
modelFeatures.plot.plot_fits = @tapas_ehgf_binary_plotTraj;

modelSpace = struct();

%% SETUP config files for Perceptual models
for i = 1:numel(modelFeatures.model.space)
    modelSpace(i).prc        = modelFeatures.model.prc{i};
    modelSpace(i).prc_config = eval(modelFeatures.model.prc_config{i});
    pr = priorPrep(options.task.u);

    % Replace placeholders in parameter vectors with their calculated values
    modelSpace(i).prc_config.priormus(modelSpace(i).prc_config.priormus==99991) = pr.plh.p99991;
    modelSpace(i).prc_config.priorsas(modelSpace(i).prc_config.priorsas==99991) = pr.plh.p99991;

    modelSpace(i).prc_config.priormus(modelSpace(i).prc_config.priormus==99992) = pr.plh.p99992;
    modelSpace(i).prc_config.priorsas(modelSpace(i).prc_config.priorsas==99992) = pr.plh.p99992;

    modelSpace(i).prc_config.priormus(modelSpace(i).prc_config.priormus==99993) = pr.plh.p99993;
    modelSpace(i).prc_config.priorsas(modelSpace(i).prc_config.priorsas==99993) = pr.plh.p99993;

    modelSpace(i).prc_config.priormus(modelSpace(i).prc_config.priormus==-99993) = -pr.plh.p99993;
    modelSpace(i).prc_config.priorsas(modelSpace(i).prc_config.priorsas==-99993) = -pr.plh.p99993;

    modelSpace(i).prc_config.priormus(modelSpace(i).prc_config.priormus==99994) = pr.plh.p99994;
    modelSpace(i).prc_config.priorsas(modelSpace(i).prc_config.priorsas==99994) = pr.plh.p99994;

    % Get fieldnames. If a name ends on 'mu', that field defines a prior mean.
    % If it ends on 'sa', it defines a prior variance.
    names  = fieldnames(modelSpace(i).prc_config);
    fields = struct2cell(modelSpace(i).prc_config);

    % Loop over names
    for n = 1:length(names)
        if regexp(names{n}, 'mu$')
            priormus = [];
            priormus = [priormus, modelSpace(i).prc_config.(names{n})];
            priormus(priormus==99991)  = pr.plh.p99991;
            priormus(priormus==99992)  = pr.plh.p99992;
            priormus(priormus==99993)  = pr.plh.p99993;
            priormus(priormus==-99993) = -pr.plh.p99993;
            priormus(priormus==99994)  = pr.plh.p99994;
            modelSpace(i).prc_config.(names{n}) = priormus;
            clear priormus;

        elseif regexp(names{n}, 'sa$')
            priorsas = [];
            priorsas = [priorsas, modelSpace(i).prc_config.(names{n})];
            priorsas(priorsas==99991)  = pr.plh.p99991;
            priorsas(priorsas==99992)  = pr.plh.p99992;
            priorsas(priorsas==99993)  = pr.plh.p99993;
            priorsas(priorsas==-99993) = -pr.plh.p99993;
            priorsas(priorsas==99994)  = pr.plh.p99994;
            modelSpace(i).prc_config.(names{n}) = priorsas;
            clear priorsas;
        end
    end

    % find parameter names of mus and sas:
    expnms_mu_prc=[];
    expnms_sa_prc=[];
    n_idx      = 0;
    for k = 1:length(names)
        if regexp(names{k}, 'mu$')
            for l= 1:length(fields{k})
                n_idx = n_idx + 1;
                expnms_mu_prc{1,n_idx} = [names{k},'_',num2str(l)];
            end
        elseif regexp(names{k}, 'sa$')
            for l= 1:length(fields{k})
                n_idx = n_idx + 1;
                expnms_sa_prc{1,n_idx} = [names{k},'_',num2str(l)];
            end
        end
    end
    modelSpace(i).expnms_mu_prc=expnms_mu_prc(~cellfun('isempty',expnms_mu_prc));
    modelSpace(i).expnms_sa_prc=expnms_sa_prc(~cellfun('isempty',expnms_sa_prc));
end

%% SETUP config files for Observational models
for i = 1:numel(modelFeatures.model.space)
    modelSpace(i).name       = modelFeatures.model.space{i};
    modelSpace(i).obs        = modelFeatures.model.obs{i};
    modelSpace(i).obs_config = eval(modelFeatures.model.obs_config{i});

    % Get fieldnames. If a name ends on 'mu', that field defines a prior mean.
    % If it ends on 'sa', it defines a prior variance.
    names  = fieldnames(modelSpace(i).obs_config);
    fields = struct2cell(modelSpace(i).obs_config);
    % find parameter names of mus and sas:
    expnms_mu_obs=[];
    expnms_sa_obs=[];
    n_idx      = 0;
    for k = 1:length(names)
        if regexp(names{k}, 'mu$')
            for l= 1:length(fields{k})
                n_idx = n_idx + 1;
                expnms_mu_obs{1,n_idx} = [names{k},'_',num2str(l)];
            end
        elseif regexp(names{k}, 'sa$')
            for l= 1:length(fields{k})
                n_idx = n_idx + 1;
                expnms_sa_obs{1,n_idx} = [names{k},'_',num2str(l)];
            end
        end
    end
    modelSpace(i).expnms_mu_obs=expnms_mu_obs(~cellfun('isempty',expnms_mu_obs));
    modelSpace(i).expnms_sa_obs=expnms_sa_obs(~cellfun('isempty',expnms_sa_obs));
end

%% find free parameters & convert parameters to native space

for i = 1:size(modelSpace,2)

    % Perceptual model
    prc_idx = modelSpace(i).prc_config.priorsas;
    prc_idx(isnan(prc_idx)) = 0;
    modelSpace(i).prc_idx = find(prc_idx);
    % find names of free parameters:
    modelSpace(i).free_expnms_mu_prc=modelSpace(i).expnms_mu_prc(modelSpace(i).prc_idx);
    modelSpace(i).free_expnms_sa_prc=modelSpace(i).expnms_sa_prc(modelSpace(i).prc_idx);
    c.c_prc = (modelSpace(i).prc_config);
    % transform values into natural space for the simulations
    modelSpace(i).prc_mus_vect_nat = c.c_prc.transp_prc_fun(c, c.c_prc.priormus);
    modelSpace(i).prc_sas_vect_nat = c.c_prc.transp_prc_fun(c, c.c_prc.priorsas);

    % Observational model
    obs_idx = modelSpace(i).obs_config.priorsas;
    obs_idx(isnan(obs_idx)) = 0;
    modelSpace(i).obs_idx = find(obs_idx);
    % find names of free parameters:
    modelSpace(i).free_expnms_mu_obs=modelSpace(i).expnms_mu_obs(modelSpace(i).obs_idx);
    modelSpace(i).free_expnms_sa_obs=modelSpace(i).expnms_sa_obs(modelSpace(i).obs_idx);
    c.c_obs = (modelSpace(i).obs_config);
    % transform values into natural space for the simulations
    modelSpace(i).obs_vect_nat = c.c_obs.transp_obs_fun(c, c.c_obs.priormus);
end

modelFeatures.modelSpace = modelSpace;

% NOTE: THIS IS A COPY from hgf function tapas_fitModel:
% --------------------------------------------------------------------------------------------------
    function pr = priorPrep(options)

    % Initialize data structure to be returned
    pr = struct;

    % Store responses and inputs
    pr.u  = options;

    % Calculate placeholder values for configuration files

    % First input
    % Usually a good choice for the prior mean of mu_1
    pr.plh.p99991 = pr.u(1,1);

    % Variance of first 20 inputs
    % Usually a good choice for the prior variance of mu_1
    if length(pr.u(:,1)) > 20
        pr.plh.p99992 = var(pr.u(1:20,1),1);
    else
        pr.plh.p99992 = var(pr.u(:,1),1);
    end

    % Log-variance of first 20 inputs
    % Usually a good choice for the prior means of log(sa_1) and alpha
    if length(pr.u(:,1)) > 20
        pr.plh.p99993 = log(var(pr.u(1:20,1),1));
    else
        pr.plh.p99993 = log(var(pr.u(:,1),1));
    end

    % Log-variance of first 20 inputs minus two
    % Usually a good choice for the prior mean of omega_1
    if length(pr.u(:,1)) > 20
        pr.plh.p99994 = log(var(pr.u(1:20,1),1))-2;
    else
        pr.plh.p99994 = log(var(pr.u(:,1),1))-2;
    end

    end % function priorPrep
% --------------------------------------------------------------------------------------------------

        

end