recoveryData = readtable('/Users/kwellste/projects/SEPAB/tasks/social_affective_prediction_task/simulations/generated_data/parameter_recovery_results_3avatars.csv')

histogram(recoveryData.Column1(recoveryData.input_sequence_idx==1),100)
hold on
histogram(recoveryData.Column1(recoveryData.input_sequence_idx==2),100)
title('Parameter Recovery - avatar ''learning rate'' for 2 outcome sequences');
xlabel('Reliability: Difference btw prior and posterior value');
R1 = corr(recoveryData.true__xprob_volatility(recoveryData.input_sequence_idx==1),recoveryData.estimated__xprob_volatility(recoveryData.input_sequence_idx==1));
R2 = corr(recoveryData.true__xprob_volatility(recoveryData.input_sequence_idx==2),recoveryData.estimated__xprob_volatility(recoveryData.input_sequence_idx==2));
legend({['OutcomeSeq1: R squared = ' num2str(R1)],['OutcomeSeq2: R squared = ' num2str(R2)],'FontSize',14})


figure
histogram(recoveryData.Column2(recoveryData.input_sequence_idx==1),100)
hold on
histogram(recoveryData.Column2(recoveryData.input_sequence_idx==2),100)
title('Parameter Recovery - avatar ''action noise'' for 2 outcome sequences');
xLabel('Goodness of fit: Difference btw prior and posterior value');