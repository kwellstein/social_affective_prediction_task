using Distributed, ActionModels

#Choose number of cores
#addprocs(1)

## Send info to all workers
@everywhere begin

    ## Load packages and functions ##
    using ActionModels
    include("helper_functions/create_agent.jl")
    include("helper_functions/create_input_sequence.jl")
    include("helper_functions/helper_functions.jl")

    ### CREATE INPUT ARRAYS HERE! ###
    input_sequences = [[1 0; 2 0], [1 0; 2 0]]

    ## SETTINGS ##
    #Settings to use for the sampling
    sampler_settings = (n_iterations = 10, n_chains = 1) #SET TO 2000 samples for final run

    #Number of simulations to run for each parameter combination, for each input sequence
    #KEEP THIS LOW IF YOU HAVE MANY INPUT input_sequences_to_use
    n_simulations = 3

    #Define a dictionary called parameter_ranges to store the ranges of different parameters
    #CURRENTLY, THIS IS A _LOT_ OF COMBINATIONS; MIGHT WANNA MAKE THEM SMALLER
    #CAN ALSO JUST BE VECTORS
    agent_parameters = Dict(
        #Parameters for the probability nodes    
        "xprob_volatility" => collect(-7:1:-1), #ω₂ - IMPORTANT
        #Parameters for the volatility node
        ("xvol", "volatility") => collect(-6:2:0), #ω₃ - IMPORTANT
        #Action noise parameter
        "action_noise" => collect(0.1:0.3:1), #β - IMPORTANT
    )

    #Set priors for inference
    priors = Dict(
        ("xprob", "volatility") => truncated(Normal(-3, 1), upper = -0.5),
        ("xvol", "volatility") => Normal(-6, 1),
        "action_noise" => truncated(Normal(0.2, 1), lower = 0),
    )

    #Create agent
    n_avatars = 3
    agent = create_premade_hgf_agent(n_avatars)
end

#Run the parameter recovery
results_df = parameter_recovery(
    agent,
    parameter_ranges,
    input_vectors,
    priors,
    n_simulations,
    sampler_settings = sampler_settings,
    parallel = true,
)

#Remove workers
rmprocs(workers())

#Save results
@save "results/parameter_recovery.jld2" results_df