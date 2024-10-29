recoveryData = readtable('/Users/kwellste/projects/SEPAB/tasks/social_affective_prediction_task/simulations/generated_data/parameter_recovery_results_3avatars.csv')

figure
histogram(recoveryData.Column1(recoveryData.input_sequence_idx==2),100)
title('Parameter Recovery - avatar ''learning rate'' for - Sequequence 2');
xlabel('Reliability: Difference btw prior and posterior value');
R2 = corr(recoveryData.true__xprob_volatility(recoveryData.input_sequence_idx==2),recoveryData.estimated__xprob_volatility(recoveryData.input_sequence_idx==2));
legend(['R squared = ' num2str(R2)])

figure
histogram(recoveryData.Column1(recoveryData.input_sequence_idx==1),100)
hold on
title('Parameter Recovery - avatar ''learning rate'' for - Sequequence 1');
xlabel('Reliability: Difference btw prior and posterior value');
R1 = corr(recoveryData.true__xprob_volatility(recoveryData.input_sequence_idx==1),recoveryData.estimated__xprob_volatility(recoveryData.input_sequence_idx==1));
legend(['R squared = ' num2str(R1)])

figure
histogram(recoveryData.Column2(recoveryData.input_sequence_idx==1),100)
hold on
histogram(recoveryData.Column2(recoveryData.input_sequence_idx==2),100)
title('Parameter Recovery - avatar ''action noise'' for 2 outcome sequences');
xLabel('Goodness of fit: Difference btw prior and posterior value');

means1 = zeros(81,1);
rows = 1:10:810;
for i = 1:81
means1(i) = mean(recoveryData.Column1(rows(i):rows(i)+9));
end

means2 = zeros(81,1);
rows = 811:10:1620;
for i = 1:81
means2(i) = mean(recoveryData.Column1(rows(i):rows(i)+9));
end

figure;
plot(means1,'LineWidth',2,'Color','k')
hold on
rows = 1:10:810;
bins = 1:81;
for i = 1:81
scatter(bins(i),recoveryData.Column1(rows(i):rows(i)+9),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
hold on
end
title('differences btw estimated and true parameters - Sequence 2','FontSize',20);

figure;
plot(means2,'LineWidth',2,'Color','k')
hold on
rows = 811:10:1620;
bins = 1:81;
for i = 1:81
scatter(bins(i),recoveryData.Column1(rows(i):rows(i)+9),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
hold on
end
title('differences btw estimated and true parameters - Sequence 1','FontSize',20);

histogram(recoveryData.Column1(1:10),100)
hold on
histogram(recoveryData.Column1(11:20),100)
hold on
histogram(recoveryData.Column1(21:30),100)
hold on
histogram(recoveryData.Column1(31:40),100)
hold on
histogram(recoveryData.Column1(41:50),100)
hold on
histogram(recoveryData.Column1(51:60),100)
hold on
histogram(recoveryData.Column1(61:70),100)

histogram(recoveryData.Column1(recoveryData.input_sequence_idx==2),100)
title('Parameter Recovery - avatar ''learning rate'' for 2 outcome sequences');
xlabel('Reliability: Difference btw prior and posterior value');
R1 = corr(recoveryData.true__xprob_volatility(recoveryData.input_sequence_idx==1),recoveryData.estimated__xprob_volatility(recoveryData.input_sequence_idx==1));
R2 = corr(recoveryData.true__xprob_volatility(recoveryData.input_sequence_idx==2),recoveryData.estimated__xprob_volatility(recoveryData.input_sequence_idx==2));
legend({['OutcomeSeq1: R squared = ' num2str(R1)],['OutcomeSeq2: R squared = ' num2str(R2)],'FontSize',14})