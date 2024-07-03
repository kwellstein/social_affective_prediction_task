function stimulus = selectStimulus(taskPhase,trial,inputs)

switch taskPhase
    case 'first'
        avatar = inputs(trial,1);
    case 'outcome'
        [avatar,outcome] = inputs(trail,:)
end

end

end
