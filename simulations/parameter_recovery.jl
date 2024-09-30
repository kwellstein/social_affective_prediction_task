####### SETUP ######
using Distributed #For parallel processing
using StatsPlots #For plotting
include("helper_functions/helper_functions.jl") #Plots for the simulations

#Active cores
addprocs(4)

#On all cores
@everywhere begin
    using ActionModels, HierarchicalGaussianFiltering #For creating HGFs
    using CSV, Tables #For reading and writing files

    #Functions for creating agents and input sequences
    include("helper_functions/create_agent.jl")
    include("helper_functions/create_input_sequence.jl")

    ##### SETTINGS #####
    #Which input sequences to use
    input_sequence = CSV.File("generated_data/input_sequence.csv") |> Tables.matrix
    
    #Number of avatars
    n_avatars = 3

    #Set the default parameters
    default_parameters = Dict(
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

    #Agent model to do recovery on
    agent = create_premade_hgf_agent(n_avatars)
    #Set parameters
    set_parameters!(agent, default_parameters) 
    #Reset the agent
    reset!(agent)

    ## The ranges of parameters to be recovered ##
    true_parameters = Dict(
        "xprob_volatility" => collect(-10:1:-1),
        "action_noise" => collect(0.1:0.3:2.5),
    )

    ## Priors to use ##
    priors = Dict(
        "xprob_volatility" => truncated(Normal(-5, 2), upper = -0.5),
        "action_noise" => truncated(Normal(0, 1), lower = 0),
    )

    #Times to repeat each recovery
    n_repetitions = 3

    #Sampler settings
    sampler_settings = (;n_iterations = 1000)
end

#Run parameter recovery
results_df = parameter_recovery(
    agent,
    true_parameters,
    input_sequence,
    priors,
    n_repetitions,
    sampler_settings = sampler_settings,
    parallel = true,
    show_progress = true,
)


#Turn off extra cores
rmprocs(workers())


#Save the results
CSV.write("parameter_recovery_results.csv",results_df)
