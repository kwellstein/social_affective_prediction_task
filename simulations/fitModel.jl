using ActionModels, HierarchicalGaussianFiltering #For creating HGFs
using CSV, Tables #For reading and writing files
using Distributions
using StatsPlots #For plotting
include("helper_functions/helper_functions.jl")
include("helper_functions/create_agent.jl")

inputsPath = "/Users/kwellste/projects/SEPAB/tasks/social_affective_prediction_task/task/+eventCreator/"
dataPath   = "/Users/kwellste/projects/SEPAB/tasks/data/experiment/SAPS_1001/"

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

agent_parameters = extract_quantities(model, fitted_model)
estimates_df = get_estimates(hgf_parameters, DataFrame)
state_trajectories = get_trajectories(model, fitted_model, [“value”, “action”])
trajectory_estimates_df = get_estimates(state_trajectories)

plot(fitted_model)
plot_parameter_distribution(fitted_model, hgf_parameters)

get_posteriors(fitted_model)

return fitted_model