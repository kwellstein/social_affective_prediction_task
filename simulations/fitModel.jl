using ActionModels, HierarchicalGaussianFiltering #For creating HGFs
using CSV, Tables #For reading and writing files
using Distributions
using StatsPlots #For plotting
include("helper_functions/helper_functions.jl")
include("helper_functions/create_agent.jl")

inputsPath = "/Users/kwellste/projects/SEPAB/tasks/social_affective_prediction_task/task/+eventCreator/"
dataPath   = "/Users/kwellste/projects/SEPAB/tasks/data/experiment/SAPS_1001/"
avatar_colors = [
    :red, 
    :blue, 
    :green,
    #:purple
    ]

# load input sequence
input_sequence = CSV.File("/Users/kwellste/projects/SEPAB/tasks/social_affective_prediction_task/task/+eventCreator/input_sequence.csv") |> Tables.matrix

# load participant responses
actions = CSV.File("/Users/kwellste/projects/SEPAB/tasks/data/experiment/SAPS_1001/SAP_responses.csv") |> Tables.matrix

#Number of avatars (the max of the inputs)
n_avatars = findmax(input_sequence[:,1])[1]

#Set the default parameters
hgf_parameters = Dict(
    "xprob_volatility" => truncated(Normal(-2, 2), upper = -0.5),
    "action_noise" => truncated(Normal(0.1, 1), lower = 0),
)
#Agent model to do recovery on
agent = create_premade_hgf_agent(n_avatars)

#Reset the agent
reset!(agent)


#Create model
model = create_model(agent, hgf_parameters, input_sequence, actions)

#Fit single chain with 10 iterations
fitted_model = fit_model(model; n_iterations = 10, n_chains = 1)

plot(fitted_model)

parameter_estimates_full = extract_quantities(model, fitted_model)
estimates_df     = get_estimates(parameter_estimates_full, DataFrame)
state_trajectories = get_trajectories(model, fitted_model, [("xprob1", "precision_prediction_error"),("xbinary1", "posterior_precision"),("xbinary1", "posterior_mean"),
("xprob2", "precision_prediction_error"),("xbinary2", "posterior_precision"),("xbinary2", "posterior_mean"),
("xprob3", "precision_prediction_error"),("xbinary3", "posterior_precision"),("xbinary3", "posterior_mean"),("xvol", "posterior_mean"),("xvol", "posterior_precision")]) # [“value”, “action”]
trajectory_estimates_df = ActionModels.get_estimates(state_trajectories)


plt = plot_belief_trajectory(agent, n_avatars, avatar_colors)
plot_parameter_distribution(fitted_model, hgf_parameters)

param_posteriors = get_posteriors(fitted_model)

CSV.write("generated_data/Traj_values_SAPS_1001.csv",trajectory_estimates_df)
CSV.write("generated_data/Posteriors_SAPS_1001.csv",param_posteriors)