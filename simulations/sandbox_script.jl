####### SETUP ######
using ActionModels, HierarchicalGaussianFiltering
using Distributions
using StatsPlots
using Random, Missings 
using DelimitedFiles

categProbs  = (avatar1 = 0.9, avatar2 = 0.2, avatar3 = 0.6)
nCategTrials = 40
phaseProb    = [0.80, 0.20, 0.80, 0.60, 0.20, 0.80]
phaseLength  = [40, 10, 10, 20, 20, 20]

# find size indicators for different vectors
nCategories = length(categProbs)
nTrials     = (nCategTrials*length(categProbs))
nPhases     = length(phaseLength)
nTrueTrials = Int(round(sum(phaseProb.*phaseLength)))

# initialize arrays
input_sequence = Vector{Vector}(undef,nTrials) # initialize vector for input sequence

for i in 1:nTrials # put in required format (1st column for category indicator, 2nd column for outcome)
    input_sequence[i] = [0,0]
end

respArray   = fill(0,nTrials)
trueIdxArray  = fill(0,nTrueTrials)
falseIdxArray = fill(0,Int(nTrials-nTrueTrials))

## LOOPING over task phases and creating response arrays

   startTrueIdx = 1 # when the first outcome=1 starts in each phase: this is a variable that is updated throughout
   startFalseIdx = 1 # when the first outcome=0 starts in each phase: this is a variable that is updated throughout
    for phase in 1:nPhases

        if phase == 1
            startTrueIdx  = 1
            startFalseIdx = 1
        end 

        startIdx         = sum(phaseLength[1:phase-1])+1   # at what index this phase starts in the inut_structure
        nCurrPhaseTrials = phaseLength[phase]   # how many trials are in the current phase
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

## fill outcome column in input_sequence
#= for i in trueIdxArray # put in required format (1st column for category indicator, 2nd column for outcome)
    input_sequence[i] = [0,1]
end =#

## create matrix assigning different category indicators into the first column that 
# corresponds to both their inhereent categoriy probabilities and the already defined outcome array

# shuffle the array so that chunks of idxs can be cut out for each one of the categories
    trueIdxArray  = shuffle(trueIdxArray) 
    falseIdxArray = shuffle(falseIdxArray)

    endTrueIdx    = 0
    endFalseIdx   = 0

    for iCategory in 1:nCategories
        if delta > 0
            nTrues  = Int(nCategTrials*categProbs[iCategory] + addTrueTrials[iCategory])
            nFalses = Int(nCategTrials-nTrues)
        else
            nTrues  = Int(nCategTrials*categProbs[iCategory])
            nFalses = Int(nCategTrials-nTrues)
        end

        if iCategory == 1
            startTrueIdx  = 1
            startFalseIdx = 1
            endTrueIdx    = nTrues
            endFalseIdx   = nFalses

         else
            startTrueIdx  = endTrueIdx+1
            startFalseIdx = endFalseIdx+1
            endTrueIdx    = startTrueIdx + nTrues-1
            endFalseIdx   = startFalseIdx + nFalses-1
        end 

        if iCategory == nCategories # if this is the last category hard stop at last trial idx just to make sure that there is no unnecassary bug due to numerical inaccuracies
            trueIdxs  = sort(trueIdxArray[startTrueIdx:end])
            falseIdxs = sort(falseIdxArray[startFalseIdx:end])
        else
            trueIdxs  = sort(trueIdxArray[startTrueIdx:endTrueIdx])
            falseIdxs = sort(falseIdxArray[startFalseIdx:endFalseIdx])
        end

        for i in 1:size(trueIdxs,1)
            iTrueTrials = trueIdxs[i]
            input_sequence[iTrueTrials] = [iCategory,1]

        end
    end

    return input_sequence[2:end]
  #Save input sequence
writedlm( "generated_data/input_sequence.csv",  input_sequence, ',')

dict = Dict(input_sequence, :auto)
