####### SETUP ######
using ActionModels, HierarchicalGaussianFiltering #For creating HGFs
using Distributions #For defining distributions
using StatsPlots #For plotting
using Random, Missings #For random number generation and missing values
using DelimitedFiles #For reading and writing files
using DataFrames
using CSV


#path_to_folder = "HGF_simulations/"
path_to_folder = ""

#Read functions for creating agents and input sequences
include(path_to_folder * "create_agent.jl")
include(path_to_folder * "create_input_sequence.jl")
include(path_to_folder * "helper_functions.jl")

####### OPTIONS ######

# get input sequence
#load(path_to_folder * "input_sequence.csv")#
#How many avatars to use
n_avatars = 3

 input_sequence = create_input_sequence(
   avatarProbs  = (avatar1 = 0.9, avatar2 = 0.2, avatar3 = 0.6),
   avatarTrials = 40,
   phaseProb    = [0.80, 0.20, 0.80, 0.60, 0.20, 0.80],
   phaseLength  = [40, 10, 10, 20, 20, 20]
  )

#Colors for the different avatars
avatar_colors = [:red, :blue, :green, :purple]


#Agent parameter
agent_parameters = Dict(
        #Parameters for the probability nodes    
        "xprob_volatility"                => -2,
        "xprob_initial_precision"         => 100,
        "xprob_initial_mean"              => 0,

        #Parameters for the volatility node
        ("xvol", "volatility")            => -8,
        ("xvol", "initial_precision")     => 1,
        ("xvol", "initial_mean")          => 1,

        #Action noise parameter
        "action_noise"                    => 1,

        #Coupling strengths
        "xbinary_xprob_coupling_strength" => 1,
        "xprob_xvol_coupling_strength"    => 1,
)


##### SIMULATION #####

#Save input sequence
writedlm( "generated_data/input_sequence.csv",  input_sequence, ',')

#
    
    #println("......... processing agent no. $nAgent ........")
    #Create HGF agent that works for 4 avatars
    agent = create_premade_hgf_agent(n_avatars)
    #Set parameters
    set_parameters!(agent, agent_parameters) 
    #Reset the agent
    reset!(agent)

    #Give the inputs to the agent
    simulated_actions = give_inputs!(agent, input_sequence)

    # Model inversion
    priors = Dict(
        "xprob_volatility" => Normal(-2, 2),
        "action_noise" => truncated(Normal(0, 2), lower = 0),
    )
    results = fit_model(agent, priors, input_sequence, simulated_actions)
    #plot(results)
    plot_parameter_distribution(results, priors)
#end

give_inputs!(agent, input_sequence)

plot_belief_trajectory(agent, n_avatars, avatar_colors)

















#
#for i in 1:n_avatars
###    plot!(agent, "u$i", label = "avatar $i", color = avatar_colors[i])
#end


if i == n_avatars
    savefig("BeliefTraj_.png")
end


# TO DO: save dataframe

### DO PARAMETER ESTIMATION ###
### For loop over: different input sequences, different true omega values, different priors
### Create dataframe
### Fit all the models
### Pick the input sequence that gives the best recovery for the parameter values of interest




## DATAFRAME VERSION
#results = fit_model(agent, priors, dataframe, 
#                    input_cols = [:colname], 
#                    action_cols = [:colname], 
#                    independent_group_cols = [:colname],
#                    n_cores = 4,
#                    n_chains = 4,
#                    iterations = 1000)


#plot_trajectory(hgf, "xvol")

#get_parameters(hgf)


########### NOTES ##########

# #Single agent fitting





# ##### JGET MODEL ####
# agent = premade_agent("hgf_gaussian", Dict(
#     "HGF" => premade_hgf("JGET")
# ))




#Step 1: try manually input sequences and parameter settings to see agent belief behaviour 
#Step 2: try manually looking for differences in priors and posteriors 
#Step 3: brutoe force method:

#### BRUTE FORCE METHOD ###
# FOR LOOP WITH DIFFERENT INPUT SEQUENCES
    #FOR LOOP WITH DIFFERENT PARAMETER SETTINGS
        # FOR LOOP WITH MULTIPLE AGENTS