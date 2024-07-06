####### SETUP ######
using ActionModels, HierarchicalGaussianFiltering #For creating HGFs
using Distributions #For defining distributions
using StatsPlots #For plotting
using Random, Missings #For random number generation and missing values
using DelimitedFiles #For reading and writing files

#path_to_folder = "HGF_simulations/"

#Read functions for creating agents and input sequences
#include(path_to_folder * "create_agent.jl")
#include(path_to_folder * "create_input_sequence.jl")
include("create_agent.jl")
include("create_input_sequence.jl")

####### PREPARATION ######

#Create input sequence
input_sequence = create_input_sequence(
    avatarProbs  = (avatar1 = 0.9, avatar2 = 0.1, avatar3 = 0.7,avatar4 = 0.3),
    avatarTrials = 40,
    phaseProb    = [0.80, 0.20, 0.80, 0.20, 0.60],
    phaseLength  = [40, 20, 20, 40, 40]
    )

#Save input sequence
writedlm( "generated_data/input_sequence.csv",  input_sequence, ',')

for nAgent in 1:100
    println("......... processing agent no. $nAgent ........")
#Create HGF agent that works for 4 avatars
n_avatars = 4
agent = create_premade_hgf_agent(n_avatars)

####### TESTRUN ######
#Check the parameters of the model
get_parameters(agent)

#Set parameters
set_parameters!(agent, Dict(
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
) 

#Reset the agent
reset!(agent)

#Give the inputs to the agent
simulated_actions = give_inputs!(agent, input_sequence)

#Colors for the different avatars
avatar_colors = [:red, :blue, :green, :purple]

#Plot the beliefs trajectories for the four avatars
for i in 1:n_avatars
    #Plot the belief trajectories (predictions about the timesteps)
    if i == 1
        plot_trajectory(agent, "xbinary$i", label = "avatar $i", color = avatar_colors[i])
    else
        plot_trajectory!(agent, "xbinary$i", label = "avatar $i", color = avatar_colors[i])
    end

    plot_trajectory!(agent, "u$i", label = "", color = avatar_colors[i])

    #Add title
    belief_plot = title!("Belief trajectories for the four avatars")

    display(belief_plot)
    if i ==n_avatars
    savefig("BeliefTraj_.png")
    end
end

# Model inversion
priors = Dict(
    "xprob_volatility" => Normal(-2, 2),
    "action_noise" => truncated(Normal(0, 2), lower = 0),
)
results = fit_model(agent, priors, input_sequence, simulated_actions)
#plot(results)
println("debugging...")
plot_parameter_distribution(results, priors)
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

