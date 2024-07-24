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
    nSmileTrials = Int(sum(phaseProb.*phaseLength))

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
        nSmileTrials  = Int(currPhaseProb*nPhaseTrials)
        endIdx   = (startIdx+nPhaseTrials)-1
        trialIdx = shuffle(startIdx:endIdx)[1:nPhaseTrials]
        smileTrialIdx   = trialIdx[1:nSmileTrials]
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

        smileIdx   = sort(smileIdxArray[startSmileIdx:endSmileIdx])
        neutralIdx = sort(neutralIdxArray[startNeutralIdx:endNeutralIdx])

        for i in 1:nSmiles
            iSmileTrials = smileIdx[i]
            input_sequence[iSmileTrials] = [iAvatar,1]

        end

        for i in 1:nNeutral
            iNeutralTrials = neutralIdx[i]
            input_sequence[iNeutralTrials] = [iAvatar,0]
        end
    end

    return input_sequence
end