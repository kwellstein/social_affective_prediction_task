
using ActionModels, HierarchicalGaussianFiltering

##########################################
### FUNCTION FOR CREATING SUITABLE HGF ###
##########################################
function multi_binary_hgf(config::Dict = Dict())

    #Defaults
    spec_defaults = Dict(
        "n_avatars" => 4,
        ("xprob", "volatility") => -2,
        ("xprob", "drift") => 0,
        ("xprob", "autoconnection_strength") => 1,
        ("xprob", "initial_mean") => 0,
        ("xprob", "initial_precision") => 1,
        ("xvol", "volatility") => -2,
        ("xvol", "drift") => 0,
        ("xvol", "autoconnection_strength") => 1,
        ("xvol", "initial_mean") => 0,
        ("xvol", "initial_precision") => 1,
        ("xbinary", "xprob", "coupling_strength") => 1,
        ("xprob", "xvol", "coupling_strength") => 1,
        "update_type" => EnhancedUpdate(),
        "save_history" => true,
    )

    #Merge to overwrite defaults
    config = merge(spec_defaults, config)

    #Initialize list of nodes
    nodes = HierarchicalGaussianFiltering.AbstractNodeInfo[]
    edges = Dict{Tuple{String,String},HierarchicalGaussianFiltering.CouplingType}()
    grouped_xprob_volatility = []
    grouped_xprob_drift = []
    grouped_xprob_autoconnection_strength = []
    grouped_xprob_initial_mean = []
    grouped_xprob_initial_precision = []
    grouped_xbinary_xprob_coupling_strength = []
    grouped_xprob_xvol_coupling_strength = []

    #For each "avatar"
    for i = 1:config["n_avatars"]

        #Add input node
        push!(nodes, BinaryInput("u$i"))

        #Add binary node
        push!(nodes, BinaryState("xbinary$i"))

        #Add probability node
        push!(
            nodes,
            ContinuousState(
                name = "xprob$i",
                volatility = config[("xprob", "volatility")],
                drift = config[("xprob", "drift")],
                autoconnection_strength = config[("xprob", "autoconnection_strength")],
                initial_mean = config[("xprob", "initial_mean")],
                initial_precision = config[("xprob", "initial_precision")],
            ),
        )

        #Group the parameters for each binary HGF
        push!(grouped_xprob_volatility, ("xprob$i", "volatility"))
        push!(grouped_xprob_drift, ("xprob$i", "drift"))
        push!(grouped_xprob_autoconnection_strength, ("xprob$i", "autoconnection_strength"))
        push!(grouped_xprob_initial_mean, ("xprob$i", "initial_mean"))
        push!(grouped_xprob_initial_precision, ("xprob$i", "initial_precision"))
        push!(
            grouped_xbinary_xprob_coupling_strength,
            ("xbinary$i", "xprob$i", "coupling_strength"),
        )
        push!(
            grouped_xprob_xvol_coupling_strength,
            ("xprob$i", "xvol", "coupling_strength"),
        )

        #Add edges
        push!(edges, ("u$i", "xbinary$i") => ObservationCoupling())
        push!(
            edges,
            ("xbinary$i", "xprob$i") =>
                ProbabilityCoupling(config[("xbinary", "xprob", "coupling_strength")]),
        )
        push!(
            edges,
            ("xprob$i", "xvol") =>
                VolatilityCoupling(config[("xprob", "xvol", "coupling_strength")]),
        )

    end

    #Add the shared volatility parent
    push!(
        nodes,
        ContinuousState(
            name = "xvol",
            volatility = config[("xvol", "volatility")],
            drift = config[("xvol", "drift")],
            autoconnection_strength = config[("xvol", "autoconnection_strength")],
            initial_mean = config[("xvol", "initial_mean")],
            initial_precision = config[("xvol", "initial_precision")],
        ),
    )

    parameter_groups = [
        ParameterGroup(
            "xprob_volatility",
            grouped_xprob_volatility,
            config[("xvol", "volatility")],
        ),
        ParameterGroup("xprob_drift", grouped_xprob_drift, config[("xvol", "drift")]),
        ParameterGroup(
            "xprob_autoconnection_strength",
            grouped_xprob_autoconnection_strength,
            config[("xvol", "autoconnection_strength")],
        ),
        ParameterGroup(
            "xprob_initial_mean",
            grouped_xprob_initial_mean,
            config[("xvol", "initial_mean")],
        ),
        ParameterGroup(
            "xprob_initial_precision",
            grouped_xprob_initial_precision,
            config[("xvol", "initial_precision")],
        ),
        ParameterGroup(
            "xbinary_xprob_coupling_strength",
            grouped_xbinary_xprob_coupling_strength,
            config[("xbinary", "xprob", "coupling_strength")],
        ),
        ParameterGroup(
            "xprob_xvol_coupling_strength",
            grouped_xprob_xvol_coupling_strength,
            config[("xprob", "xvol", "coupling_strength")],
        ),
    ]

    #Initialize the HGF
    hgf = init_hgf(
        nodes = nodes,
        edges = edges,
        parameter_groups = parameter_groups,
        verbose = false,
        node_defaults = NodeDefaults(update_type = config["update_type"]),
        save_history = config["save_history"],
    )

    return hgf
end

##########################################
######## ACTION MODEL FUNCTION  ##########
##########################################
function respond_to_avatar(
    attributes::ModelAttributes,
    observed_avatar::Int64,
    observation::Int64,
)
    ### SETUP ###
    prev_action = load_actions(attributes).choice

    #Load action precision (i.e. inverse action noise)
    β⁻¹ = 1/load_parameters(attributes).action_noise

    #Extract the HGF
    hgf = attributes.submodel

    ### MAKE PREDICTION ###

    #Get prediction from the HGF
    predicted_probability = get_states(
        hgf,
        Symbol(join(["xbinary$observed_avatar", "prediction_mean"], "_")),
    )

    #If the avatar has not been seen before
    if ismissing(predicted_probability)
        #Act randomly
        action_distribution = Bernoulli(0.5)
    else
        #Use a unit squared sigmoid transform to get the action probability 
        action_probability =
            predicted_probability^β⁻¹ /
            (predicted_probability^β⁻¹ + (1 - predicted_probability)^β⁻¹)

        #If the action probability is not between 0 and 1
        if !(0 <= action_probability <= 1)
            #Throw an error that will reject samples when fitted
            throw(
                RejectParameters(
                    "With these parameters and inputs, the action probability became $action_probability, which should be between 0 and 1. Try other parameter settings",
                ),
            )
        end

        #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
        action_distribution = Bernoulli(action_probability)
    end

    ### UPDATE HGF BASED ON TRUE OBSERVATION ###
    #Create empty vector of observations
    hgf_input = Vector{Union{Int64,Missing}}(missing, length(hgf.input_nodes))

    #Change the missing to the atual observation for the bandit that was observed
    hgf_input[observed_avatar] = observation

    #Pass the observation to the HGF
    update_hgf!(hgf, hgf_input)

    return action_distribution
end

##########################################
### FUNCTION FOR CREATING HGF AGENT ######
##########################################
function create_premade_action_model(n_avatars::Int = 4)

    hgf = multi_binary_hgf(Dict("n_avatars" => n_avatars))

    parameters = (action_noise = Parameter(1),)

    observations = (;
        observed_avatar = Observation(Int64),   # The avatar that is observed
        observation = Observation(Int64),       # The observation for the avatar
    )

    actions = (; choice = Action(Bernoulli),)

    return ActionModel(
        respond_to_avatar,
        parameters = parameters,
        observations = observations,
        actions = actions,
        submodel = hgf,
    )

end