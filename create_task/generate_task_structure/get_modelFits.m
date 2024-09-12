function get_modelFits

%% INITIALIZE Variables for running this function
options       = set_options();             % specifications for this analysis
modelFeatures = set_hgf_features(options); % specifications regarding model features

disp('************************************** PLOT MODELFITS **************************************');
disp('*');
disp('*');

% find all Simulation directories
simInstances = dir([pwd '/Simulations_*']);
for n = 1:options.sim.nSamples
    for m_in = 1:numel(modelFeatures.model.space) % model data was generated with
        for m_est = 1:numel(modelFeatures.model.space) % model data will be estimated with
            for i = 1:numel(simInstances)
                est(i).agent(n,m_est) = load(fullfile(options.sim.saveDir,'/',simInstances(i).name ,'/',...
                    [options.task.acronym,'simulation_agent', num2str(n),'model_in',...
                    num2str(m_in),'_model_est',num2str(m_est),'.mat']));
                optim(n,i).model(m_est) = est(i).agent(n,m_est).optim;

                LMEs(n,i) = est(i).agent(n,m_est).optim.LME;
                negLl(n,i) = est(i).agent(n,m_est).optim.negLl;
                negLj(n,i) = est(i).agent(n,m_est).optim.negLj;
                AIC(n,i) = est(i).agent(n,m_est).optim.AIC;
                BIC(n,i) = est(i).agent(n,m_est).optim.AIC;
            end
        end
    end
end

%% PLOTTING

for i = 1:numel(simInstances)
    LME_hist = histogram(LMEs(:,i),'FaceColor',[0 i*0.1 i/i], 'EdgeColor',[0 0 0],'LineWidth',1.5,'Normalization','pdf');
    hold on
end
legend(LME_hist,simInstances(i).name);

figdir = fullfile([options.sim.saveDir,'/',options.task.acronym,'LME_histogram']);
save([figdir,'.fig'],'LME_hist');
print([figdir,'.png'], '-dpng')
close

for i = 1:numel(simInstances)
    AIC_hist = histogram(AIC(:,i),'FaceColor',[0 i*0.1 i/i], 'EdgeColor',[0 0 0],'LineWidth',2,'Normalization','pdf');
    hold on
end
legend(AIC_hist,simInstances(i).name);

figdir = fullfile([options.sim.saveDir,'/',options.task.acronym,'AIC_histogram']);
save([figdir,'.fig'],'AIC_hist')
print([figdir,'.png'], '-dpng')
close

for i = 1:numel(simInstances)
    BIC_hist = histogram(BIC(:,i),'FaceColor',[0 i*0.1 i/i], 'EdgeColor',[0 0 0],'LineWidth',2,'Normalization','pdf');
    hold on
end
legend(BIC_hist,simInstances(i).name);

figdir = fullfile([options.sim.saveDir,'/',options.task.acronym,'BIC_histogram']);
save([figdir,'.fig'],'BIC_hist')
print([figdir,'.png'], '-dpng')
close

for i = 1:numel(simInstances)
    negLl_hist = histogram(negLl(:,i),'FaceColor',[0 0 i/i],'LineWidth',2,'Normalization','pdf');
    hold on
end
legend(negLl_hist,simInstances(i).name);

figdir = fullfile([options.sim.saveDir,'/',options.task.acronym,'negLl_histogram']);
save([figdir,'.fig'],'negLl_hist')
print([figdir,'.png'], '-dpng')
close

for i = 1:numel(simInstances)
    negLj_hist = histogram(negLj(:,i),'FaceColor',[0 i*0.1 i/i], 'EdgeColor',[0 0 0],'LineWidth',2,'Normalization','pdf');
end
legend(negLj_hist,simInstances(i).name);

figdir = fullfile([options.sim.saveDir,'/',options.task.acronym,'negLj_histogram']);
save([figdir,'.fig'],'negLj_hist')
print([figdir,'.png'], '-dpng')
close

%% SAVING
save([options.sim.saveDir,'/optim.mat'], 'optim');
save([options.sim.saveDir,'/LMEs.mat'], 'LMEs');
save([options.sim.saveDir,'/negLl.mat'], 'negLl');
save([options.sim.saveDir,'/negLj.mat'], 'negLj');
end