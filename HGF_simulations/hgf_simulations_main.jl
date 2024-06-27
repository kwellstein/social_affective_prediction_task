####### SETUP ######
using ActionModels, HierarchicalGaussianFiltering
using Distributions
using StatsPlots

include("create_agent.jl")
include("create_input_sequence.jl")


agent = create_agent()


####### PARAMETER RECOVERY #######
get_parameters(agent)


#Different parameter settings
set_parameters!(agent,Dict(
    #Main parameters    
    "xprob_volatility" => -8,
    "action_noise" => 1,
    
    ("xvol", "volatility") => -4,
    "xbinary_xprob_coupling_strength" => 1,
    "xprob_xvol_coupling_strength" => 1,
)
) 

reset!(agent)

#Different input sequences
# To do: loop over different possibilities
input_sequence = create_input_sequence()

### SIMULATE RESPONSES ###

simulated_actions = give_inputs!(agent, input_sequence) #Put these in dataframe with the inputs and some ID
#plot_trajectory(agent, "xprob")

### DO PARAMETER ESTIMATION ###
### For loop over: different input sequences, different true omega values, different priors
### Create dataframe
### Fit all the models
### Pick the input sequence that gives the best recovery for the parameter values of interest


priors = Dict(
    "xprob_volatility" => Normal(-4, 2),
    "action_noise" => truncated(Normal(0, 2), lower = 0),
)

## DATAFRAME VERSION
results = fit_model(agent, priors, dataframe, 
                    input_cols = [:colname], 
                    action_cols = [:colname], 
                    independent_group_cols = [:colname],
                    n_cores = 4,
                    n_chains = 4,
                    iterations = 1000)








plot_trajectory(hgf, "xvol")

get_parameters(hgf)






########### NOTES ##########

# #Single agent fitting

# results = fit_model(agent, priors, input_sequence, simulated_actions)
# plot(results)
# plot_parameter_distribution(results, priors)



# ##### JGET MODEL ####
# agent = premade_agent("hgf_gaussian", Dict(
#     "HGF" => premade_hgf("JGET")
# ))

