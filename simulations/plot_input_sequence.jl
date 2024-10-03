####### SETUP ######
using ActionModels, HierarchicalGaussianFiltering #For creating HGFs
using Distributions #For defining distributions
using StatsPlots #For plotting
using Random, Missings #For random number generation and missing values
using DelimitedFiles #For reading and writing files
using DataFrames
using CSV

#Read functions for creating agents and input sequences
include("helper_functions/create_agent.jl")
include("helper_functions/helper_functions.jl")
include("helper_functions/create_input_sequence.jl")

####### OPTIONS ######

#Colors for the different avatars
avatar_colors = [
    :red, 
    :blue, 
    :green, 
    #:purple
    ]

n_avatars = length(avatar_colors)

#Generate input sequence
input_sequence = create_input_sequence(;
categProbs  = (avatar1 = 0.9, avatar2 = 0.2, avatar3 = 0.6),
nCategTrials = 40,
phaseProb    = [0.80, 0.30, 0.80, 0.30, 0.60, 0.80],
phaseLength  = [40, 10, 10, 20, 20, 20],
)

#Agent parameter
agent_parameters = Dict(
        #Parameters for the probability nodes    
        "xprob_volatility"                => -3, #This is typically between -3 and -8 ish
        "xprob_initial_precision"         => 1,
        "xprob_initial_mean"              => 0,

        #Parameters for the volatility node
        ("xvol", "volatility")            => -2, #This shouldn't really matter much
        ("xvol", "initial_precision")     => 1,
        ("xvol", "initial_mean")          => 1,

        #Action noise parameter
        "action_noise"                    => 1,

        #Coupling strengths
        "xbinary_xprob_coupling_strength" => 1,
        "xprob_xvol_coupling_strength"    => 1,
)


##### SIMULATION #####

#Create HGF agent 
agent = create_premade_hgf_agent(n_avatars)
#Set parameters
set_parameters!(agent, agent_parameters) 
#Reset the agent
reset!(agent)

#Give the inputs to the agent
simulated_actions = give_inputs!(agent, input_sequence);

#Plot the belief trajectory
plt = plot_belief_trajectory(agent, n_avatars, avatar_colors)

#Save the plot
savefig(plt,"generated_data/belief_trajectory$n_avatars.png")

#This line can save the generated input sequence
writedlm( "generated_data/input_sequence$n_avatars.csv", input_sequence, ',')
