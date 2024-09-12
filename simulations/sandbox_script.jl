#TODO: Fix the function for generating multiple input sequences
#TODO: Set up a function for parameter recovery
#TODO (other model options):
#   - add a shared value parent so participants think that avatars are correlated
#   - use autoregression to control the forgetting rate 





using ActionModels, HierarchicalGaussianFiltering #For creating HGFs
using Distributions #For defining distributions
#using StatsPlots #For plotting
using Random, Missings #For random number generation and missing values
using DelimitedFiles #For reading and writing files
using DataFrames

include("helper_functions/create_agent.jl")
include("helper_functions/create_input_sequence.jl")
include("helper_functions/helper_functions.jl")

#How many avatars to use
n_avatars = 3
#Colors for the different avatars
avatar_colors = [:red, :blue, :green, :purple]

#Create input sequence
input_sequence = create_input_sequence(
    avatarProbs = (avatar1 = 0.9, avatar2 = 0.1, avatar3 = 0.7, avatar4 = 0.3),
    avatarTrials = 40,
    phaseProb = [0.80, 0.20, 0.80, 0.20, 0.60],
    phaseLength = [40, 20, 20, 40, 40],
)




# ####### SETUP ######
# using ActionModels, HierarchicalGaussianFiltering
# using Distributions
# using StatsPlots

# include("create_agent.jl")


# ### CREATE INPUT SEQUENCES ###








# ####### PARAMETER RECOVERY #######

# agent = create_premade_hgf_agent()



# get_parameters(agent)


# #Different parameter settings
# set_parameters!(agent,Dict(
#     #Main parameters    
#     "xprob_volatility" => -8,
#     "action_noise" => 1,

#     ("xvol", "volatility") => -4,
#     "xbinary_xprob_coupling_strength" => 1,
#     "xprob_xvol_coupling_strength" => 1,
# )
# ) 

# reset!(agent)

# #Different input sequences
# input_sequence = create_input_sequence()

# ### SIMULATE RESPONSES ###

# simulated_actions = give_inputs!(agent, input_sequence) #Put these in dataframe with the inputs and some ID
# #plot_trajectory(agent, "xprob")

# ### DO PARAMETER ESTIMATION ###
# ### For loop over: different input sequences, different true omega values, different priors
# ### Create dataframe
# ### Fit all the models
# ### Pick the input sequence that gives the best recovery for the parameter values of interest


# priors = Dict(
#     "xprob_volatility" => Normal(-4, 2),
#     "action_noise" => truncated(Normal(0, 2), lower = 0),
# )

# ## DATAFRAME VERSION
# results = fit_model(agent, priors, dataframe, 
#                     input_cols = [:colname], 
#                     action_cols = [:colname], 
#                     independent_group_cols = [:colname],
#                     n_cores = 4,
#                     n_chains = 4,
#                     iterations = 1000)










# ########### NOTES ##########

# # #Single agent fitting

# # results = fit_model(agent, priors, input_sequence, simulated_actions)
# # plot(results)
# # plot_parameter_distribution(results, priors)



# # ##### JGET MODEL ####
# # agent = premade_agent("hgf_gaussian", Dict(
# #     "HGF" => premade_hgf("JGET")
# # ))








