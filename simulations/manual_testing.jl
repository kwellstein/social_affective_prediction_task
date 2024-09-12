
using ActionModels, HierarchicalGaussianFiltering #For creating HGFs
using StatsPlots #For plotting
using DataFrames, CSV #For data

include("helper_functions/create_agent.jl")
include("helper_functions/create_input_sequence.jl")
include("helper_functions/helper_functions.jl")



#How many avatars to use
#TODO: as output of input sequence function
n_avatars = 3
#Colors for the different avatars
avatar_colors = [:red, :blue, :green, :purple]

#Create input sequence
# input_sequence = create_input_sequence(
#     avatarProbs = (avatar1 = 0.9, avatar2 = 0.1, avatar3 = 0.7, avatar4 = 0.3),
#     avatarTrials = 40,
#     phaseProb = [0.80, 0.20, 0.80, 0.20, 0.60],
#     phaseLength = [40, 20, 20, 40, 40],
# )

input_sequence = Array(CSV.read("generated_data/input_sequence.csv", DataFrame))

#Agent parameter
agent_parameters = Dict(
    #Parameters for the probability nodes    
    "xprob_volatility" => -3, #ω₂ - IMPORTANT
    "xprob_initial_precision" => 100,
    "xprob_initial_mean" => 0,

    #Parameters for the volatility node
    ("xvol", "volatility") => -2, #ω₃ - IMPORTANT
    ("xvol", "initial_precision") => 1,
    ("xvol", "initial_mean") => 1,

    #Action noise parameter
    "action_noise" => 0.01, #β - IMPORTANT

    #Coupling strengths
    "xbinary_xprob_coupling_strength" => 1,
    "xprob_xvol_coupling_strength" => 1,
)


#Create agent
agent = create_premade_hgf_agent(n_avatars)

#Set parameters
set_parameters!(agent, agent_parameters)
#Reset the agent (in order to set the initial states correctly)
reset!(agent)

#Give the inputs to the agent
simulated_actions = give_inputs!(agent, input_sequence)

#Do some plotting
plot_belief_trajectory(agent, n_avatars, avatar_colors)
plot_belief_trajectory(agent, n_avatars, avatar_colors, "prob")

plot_trajectory(agent, "xvol")
