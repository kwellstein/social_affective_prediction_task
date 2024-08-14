using DataFrames

#Create input sequence
#input_sequence = create_input_sequence(
 #   avatarProbs  = (avatar1 = 0.9, avatar2 = 0.1, avatar3 = 0.7,avatar4 = 0.3),
  #  avatarTrials = 40,
 #   phaseProb    = [0.80, 0.20, 0.80, 0.20, 0.60],
 #   phaseLength  = [40, 20, 20, 40, 40]
  #  )
 # input_sequence = create_input_sequence(
 #   avatarProbs  = (avatar1 = 0.9, avatar2 = 0.2, avatar3 = 0.6),
 #   avatarTrials = 50,
 #   phaseProb    = [0.80, 0.20, 0.80, 0.20, 0.80],
 #   phaseLength  = [40, 15, 15, 40, 40]
#  )

 #   avatarProbs  = (avatar1 = 0.9, avatar2 = 0.2, avatar3 = 0.6),
 #   avatarTrials = 50,
 #   phaseProb    = [0.80, 0.20, 0.80, 0.20, 0.80],
 #   phaseLength  = [40, 15, 15, 40, 40]
 
function create_input_sequence(;
    avatarProbs,
    avatarTrials,
    phaseProb,
    phaseLength,
    )

    nAvatars     = length(avatarProbs)
    nTrials      = (avatarTrials*length(avatarProbs))
    respArray    = fill(0,nTrials)
    nPhases      = length(phaseLength)
    nSmileTrials = Int(round(sum(phaseProb.*phaseLength)))

    smileIdxArray   = fill(0,nSmileTrials)
    neutralIdxArray = fill(0,Int(nTrials-nSmileTrials))

    for phase in 1:nPhases
        if phase == 1
            startIdx = 1
            startSmileIdx   = 1
            startNeutralIdx = 1

        else
            @show phase
            @show sum(phaseLength[1:phase-1])
            @show smileTrialIdx
            
            startIdx = sum(phaseLength[1:phase-1])+1
            smileTrialArray = smileTrialIdx;
            startSmileIdx   = sum(respArray)+1
        end 
        
        nPhaseTrials  = phaseLength[phase]
        currPhaseProb = phaseProb[phase]
        nPhaseSmileTrials  = Int(round(currPhaseProb*nPhaseTrials))
        endIdx   = (startIdx+nPhaseTrials)-1
        trialIdx = shuffle(startIdx:endIdx)[1:nPhaseTrials]
        smileTrialIdx   = trialIdx[1:nPhaseSmileTrials]
        neutralTrialIdx = trialIdx[nPhaseSmileTrials+1:end]

        for iSmiles in 1:nPhaseSmileTrials
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

    if sum(phaseProb.*phaseLength)>nTrials/sum(avatarProbs)
        diff = Int(sum(phaseProb.*phaseLength)-nTrials/sum(avatarProbs))
        diffValues = ones(Int(diff))
        addSmileTrials = zeros(nAvatars)
        n = 1
        for i in 1:diff
            if i > nAvatars
                addSmileTrials[n] = diffValues[n] + diffValues[i] 
                n += 1
            else
                addSmileTrials[i] = diffValues[i]
            end
        end
    else 
        diff = 0
        addSmileTrials = zeros(nAvatars)
    end

    # create matrix assigning different avatar numbers in the first column
    # and responses in the second column

    smileIdxArray   = shuffle(smileIdxArray)
    neutralIdxArray = shuffle(neutralIdxArray)
    input_sequence  = Vector{Vector}(undef,nTrials)

    for i in 1:nTrials
        input_sequence[i] = [0,0]
    end

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

        if iAvatar == nAvatars
            smileIdx   = sort(smileIdxArray[startSmileIdx:end])
            neutralIdx = sort(neutralIdxArray[startNeutralIdx:end])
        else
        smileIdx   = sort(smileIdxArray[startSmileIdx:endSmileIdx])
        neutralIdx = sort(neutralIdxArray[startNeutralIdx:endNeutralIdx])
        end

        for i in 1:size(smileIdx,1)
            iSmileTrials = smileIdx[i]
            input_sequence[iSmileTrials] = [iAvatar,1]

        end

        for i in 1:size(neutralIdx,1)
            iNeutralTrials = neutralIdx[i]
            input_sequence[iNeutralTrials] = [iAvatar,0]
        end
    end

    return input_sequence
  #Save input sequence
writedlm( "generated_data/input_sequence.csv",  input_sequence, ',')
dict = Dict(input_sequence, :auto)


end