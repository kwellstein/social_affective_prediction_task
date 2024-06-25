using ActionModels, HierarchicalGaussianFiltering
using Distributions
using StatsPlots
using Random
using Missings

### MAKE SUITABLE HGF ###
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
    edges = Dict{Tuple{String, String}, HierarchicalGaussianFiltering.CouplingType}()
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
        push!(grouped_xbinary_xprob_coupling_strength, ("xbinary$i", "xprob$i", "coupling_strength"))
        push!(grouped_xprob_xvol_coupling_strength, ("xprob$i", "xvol", "coupling_strength"))

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
        ParameterGroup("xprob_volatility",
            grouped_xprob_volatility,
            config[("xvol", "volatility")],
        ),
        ParameterGroup("xprob_drift",
            grouped_xprob_drift,
            config[("xvol", "drift")],
        ),
        ParameterGroup("xprob_autoconnection_strength",
            grouped_xprob_autoconnection_strength,
            config[("xvol", "autoconnection_strength")],
        ),
        ParameterGroup("xprob_initial_mean",
            grouped_xprob_initial_mean,
            config[("xvol", "initial_mean")],
        ),
        ParameterGroup("xprob_initial_precision",
            grouped_xprob_initial_precision,
            config[("xvol", "initial_precision")],
        ),
        ParameterGroup("xbinary_xprob_coupling_strength",
            grouped_xbinary_xprob_coupling_strength,
            config[("xbinary", "xprob", "coupling_strength")],
        ),
        ParameterGroup("xprob_xvol_coupling_strength",
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
end

## ADD FUNCTION CREATING INPUT SEQUENCE
# create general task trajectory

avatarProbs  = (avatar1 = 0.9, avatar2 = 0.1, avatar3 = 0.7,avatar4 = 0.3)
avatarTrials = 40
nAvatars     = length(avatarProbs)
nTrials      = (avatarTrials*length(avatarProbs))
respArray    = fill(0,nTrials)
phaseProb    = [0.80, 0.20, 0.80, 0.20, 0.60]
phaseLength  = [40, 20, 20, 40, 40]
nPhases      = length(phaseLength)
nSmileTrials = Int(sum(phaseProb.*phaseLength))
smileIdxArray = fill(0,nSmileTrials)
neutralIdxArray = fill(0,Int(nTrials-nSmileTrials))

for phase in 1:nPhases
    if phase == 1
    startIdx = 1
    startSmileIdx   = 1
    startNeutralIdx = 1
    else
        startIdx = sum(phaseLength[1:phase-1])+1
        smileTrialArray = smileTrialIdx;
        startSmileIdx   = sum(respArray)+1
    end 
    
    nPhaseTrials  = phaseLength[phase]
    currPhaseProb = phaseProb[phase]
    nSmileTrials  = Int(currPhaseProb*nPhaseTrials)
    endIdx = (startIdx+nPhaseTrials)-1
    trialIdx = shuffle(startIdx:endIdx)[1:nPhaseTrials]
    smileTrialIdx = trialIdx[1:nSmileTrials]
    neutralTrialIdx = trialIdx[nSmileTrials+1:end]

    for iSmiles in 1:nSmileTrials
    respArray[smileTrialIdx[iSmiles]] = 1;
    end

endSmileIdx = length(smileTrialIdx)
    for iSmileIdx in 1:endSmileIdx
        i = (startSmileIdx+iSmileIdx)-1
        smileIdxArray[i] = smileTrialIdx[iSmileIdx];
    end

endNeutralIdx = nPhaseTrials-endSmileIdx
    for iNeutralIdx in 1:endNeutralIdx
            j = (startNeutralIdx+iNeutralIdx)-1
            neutralIdxArray[j] = neutralTrialIdx[iNeutralIdx]
    end
    startNeutralIdx = startNeutralIdx+endNeutralIdx
end
println("end debug")

if sum(phaseProb.*phaseLength)>nTrials/sum(avatarProbs)
    diff = Int(sum(phaseProb.*phaseLength)-nTrials/sum(avatarProbs))
    diffValues = ones(Int(diff))
    addSmileTrials = zeros(nAvatars)

    for i in 1:diff
        if i > nAvatars
            n = 1
            addSmileTrials[n] = diffValues[n] + diffValues[i] 
            n += 1
        else
            addSmileTrials[i] = diffValues[i]
        end
    end
else 
    diff = 0
end

# create matrix of different avatars
# format required, cols = avatars, rows = trials:
# input_sequence = [
#     [missing, missing, missing, 0],
#     [missing, missing, missing, 0],
#     [missing, missing, missing, 0],
#     [missing, missing, missing, 0],
#     [missing, missing, missing, 0],
#     [missing, missing, missing, 0],
# ]

smileIdxArray   = shuffle(smileIdxArray)
neutralIdxArray = shuffle(neutralIdxArray)
input_sequence  = allowmissing(zeros(Int8,nTrials, nAvatars))

for iAvatar in 1:nAvatars
    if diff > 0
        nSmiles  = Int(avatarTrials*avatarProbs[iAvatar] + addSmileTrials[iAvatar])
        nNeutral = Int(avatarTrials-nSmiles)
    else
    nSmiles  = Int(avatarTrials*avatarProbs[iAvatar])
    nNeutral = Int(avatarTrials-nSmiles)
    end

    if iAvatar == 1
        startSmileIdx   = 1
        startNeutralIdx = 1
        endSmileIdx     = nSmiles
        endNeutralIdx   = nNeutral
    else
        startSmileIdx   = endSmileIdx+1
        startNeutralIdx = endNeutralIdx+1
        endSmileIdx     = startSmileIdx + nSmiles-1
        endNeutralIdx   = startNeutralIdx + nNeutral-1
    end

    smileIdx   = sort(smileIdxArray[startSmileIdx:endSmileIdx])
    neutralIdx = sort(neutralIdxArray[startNeutralIdx:endNeutralIdx])

    j = 1
    k = 1
    for i in 1:nTrials
        iRow = i
        if iRow == smileIdx[j]
            input_sequence[smileIdx[j],iAvatar] = 1
            if nSmiles<j
            j+=1
            end
        elseif iRow == neutralIdx[k]
            input_sequence[neutralIdx[k],iAvatar] = 0
            if nNeutral<k
            k+=1
            end
        else
            input_sequence[i,iAvatar] = missing
        end
    end
end

# test task length and volatile vs stable

give_inputs!(hgf, input_sequence)

plot_trajectory(hgf, "xvol")

get_parameters(hgf)


### MAKE AGENT WITH RESPONSE MODEL ###
function respond_to_avatar(agent::Agent, input::Any)

    ### SETUP ###
    #Unpack the input into which avatar has been observed, and what the observation was
    observed_avatar, observation = input

    #Extract the HGF
    hgf = agent.substruct

    #Get the action noise parameter
    action_precision = 1 / agent.parameters["action_noise"]


    ### MAKE PREDICTION ###

    #On the first timestep
    if ismissing(agent.states["action"])
        #Act randomly
        action_distribution = Bernoulli(0.5)  
    else

        #Get prediction
        predicted_probability = get_states(hgf, ("xbinary$observed_avatar", "prediction_mean"))

        #Use a unit squared sigmoid transform to get the action probability 
        action_probability =
        predicted_probability^action_precision /
            (predicted_probability^action_precision + (1 - predicted_probability)^action_precision)

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
    hgf_input = Vector{Union{Int, Missing}}(missing, length(hgf.input_nodes))

    #Change the missing to the atual observation for the bandit that was observed
    hgf_input[observed_avatar] = observation

    #Pass the observation to the HGF
    update_hgf!(hgf, hgf_input)

    return action_distribution
end


### CREATE AGENT ###
function create_premade_hgf_agent(n_avatars::Int = 4)

    hgf = multi_binary_hgf(
        Dict("n_avatars" => n_avatars)
    )

    #Add the temeprature parmaeter for the action model
    parameters = Dict("action_noise" => 1)

    #create the agent
    agent = init_agent(
        respond_to_avatar, 
        substruct = hgf,
        parameters = parameters
    )

end