####### SETUP ######
using ActionModels, HierarchicalGaussianFiltering
using Distributions
using StatsPlots
using Random, Missings 

categProbs  = (avatar1 = 0.9, avatar2 = 0.2, avatar3 = 0.6)
categTrials = 40
phaseProb    = [0.80, 0.20, 0.80, 0.60, 0.20, 0.80]
phaseLength  = [40, 10, 10, 20, 20, 20]

    nCategories = length(categProbs)
    nTrials     = (categTrials*length(categProbs))
    respArray   = fill(0,nTrials)
    nPhases     = length(phaseLength)
    nTrueTrials = Int(round(sum(phaseProb.*phaseLength)))

   trueIdxArray  = fill(0,nTrueTrials)
   falseIdxArray = fill(0,Int(nTrials-nTrueTrials))
   input_sequence = Vector{Vector}(undef,nTrials) # initialize vector for input sequence

   ## LOOPING over task phases and creating response arrays

   global startTrueIdx
   global startFalseIdx
    for phase in 1:nPhases

        if phase == 1
            startTrueIdx  = 1
            startFalseIdx = 1
        end 

        startIdx = sum(phaseLength[1:phase-1])+1   
        nCurrPhaseTrials = phaseLength[phase]  # how many trials are in the current phase
        currPhaseProb    = phaseProb[phase]     # whats the current probability of this phase
        nCurrTrueTrials  = Int(round(currPhaseProb*nCurrPhaseTrials)) # how many trials in this phase have outcome = 1
        endIdx           = (startIdx+nCurrPhaseTrials)-1 # whats the last trial number of this phase
        shuffledTrials   = shuffle(startIdx:endIdx)[1:nCurrPhaseTrials] # shuffle trial indices within this phase
        trueTrialIdxs    = shuffledTrials[1:nCurrTrueTrials] # extract some trial indices (nCurrTrueTrials) that will have outcome = 1
        falseTrialIdxs   = shuffledTrials[nCurrTrueTrials+1:end] # rest of the indices is assigned to outcome = 0
        nCurrFalseTrials = length(falseTrialIdxs)

        # assign ones to the trials that should have outcome = 1
        for iTrue in 1:nCurrTrueTrials
            respArray[trueTrialIdxs[iTrue]] = 1; 
        end

        # save the indices of all the trials with outcome = 1 into an array
        # this could probably done without a loop but rather my stacking trueTrialIdxs ontop of eachother
        for iTrueIdx in 1:nCurrTrueTrials
            i = (startTrueIdx+iTrueIdx)-1
            trueIdxArray[i] = trueTrialIdxs[iTrueIdx];
        end

        # assign ones to the trials that should have outcome = 0
        for iFalseIdx in 1:nCurrFalseTrials
                j = (startFalseIdx+iFalseIdx)-1
                falseIdxArray[j] = falseTrialIdxs[iFalseIdx]
        end


    # update start index for filling in the index array for outcome = 0 in prep for next phase iteration
    startFalseIdx = startFalseIdx+nCurrFalseTrials      
    # update start index for filling in the index array for outcome = 1 in prep for next phase iteration
    startTrueIdx = startTrueIdx+nCurrTrueTrials
    
    end # end phases loop

## sometimes the combination of the probabilities of the task phases and categories may not lead to real numbers.
# taking that into account here

    if sum(phaseProb.*phaseLength)>nTrials/sum(categProbs) # if the category probabilities dont fully map onto all trials...
        delta = Int(sum(phaseProb.*phaseLength)-round(nTrials/sum(categProbs))) #calculate the difference and make it a real number by rounding
        diffValues = ones(Int(delta)) # create a vector that contains a one for each trial that has not been considered due to this
        addTrueTrials  = zeros(nCategories) # create a vector of zeros for each category that will be considered to "fill in the difference"
        
        n = 1 # initialize loop
        for i in 1:delta
            if i > nCategories # if there are more trials that have to be filled up than there are categories, 
                addTrueTrials[n] = diffValues[n] + diffValues[i] 
                n += 1
            else
                addTrueTrials[i] = diffValues[i] # add a trial with outcome = 1 to
            end
        end
    else 
        delta = 0
        addTrueTrials = zeros(nCategories)
    end

    ## create matrix assigning different avatar numbers in the first column and responses in the second column

    trueIdxArray  = shuffle(trueIdxArray)
    falseIdxArray = shuffle(falseIdxArray)

    for i in 1:nTrials
        input_sequence[i] = [0,0]
    end

    for iCategory in 1:nCategories
        if delta > 0
            nTrues  = Int(categTrials*categProbs[iCategory] + addTrueTrials[iCategory])
            nFalses = Int(categTrials-nTrues)
        else
            nTrues  = Int(categTrials*categProbs[iCategory])
            nFalses = Int(categTrials-nTrues)
        end

        if iCategory == 1
            startTrueIdx  = 1
            startFalseIdx = 1
            endTrueIdx    = nTrues
            endFalseIdx   = nFalses
        else
            startTrueIdx  = endTrueIdx+1
            startFalseIdx = endFalseIdx+1
            endTrueIdx    = startSmileIdx + nSmiles-1
            endFalseIdx   = startNeutralIdx + nNeutral-1
        end

        if iCategory == nAvatars
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
