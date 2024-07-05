function stimulus = selectStimulus(options, taskPhase,trial,inputs)

switch taskPhase
    case 'first'
        avatar = inputs(trial,1);
    case 'outcome'
        [avatar,outcome] = inputs(trail,:)
end

% select randomised face

end

