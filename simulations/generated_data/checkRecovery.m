recoveryData = readtable('/Users/kwellste/projects/SEPAB/tasks/social_affective_prediction_task/simulations/generated_data/parameter_recovery_results_2avatars.csv')

histogram(recoveryData.Column1(recoveryData.input_sequence_idx==1),100)
hold on
histogram(recoveryData.Column1(recoveryData.input_sequence_idx==2),100)

figure
histogram(recoveryData.Column2(recoveryData.input_sequence_idx==1),100)
hold on
histogram(recoveryData.Column2(recoveryData.input_sequence_idx==2),100)