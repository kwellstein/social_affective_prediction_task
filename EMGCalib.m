function EMGCalib

options = prepEnvironment;
options = specifyOptions(options);
options = initScreen(options);

fNames = fieldnames(options.message);
for iMessage = 1:numel(fNames)
    DrawFormattedText(options.screen.windowPtr,options.message.(fNames{iMessage}),'center',[], options.screen.grey);
    Screen('Flip', options.screen.windowPtr);
    
    % SEND TRIGGER


    % detect response
    [ ~, ~, keyCode,  ~] = KbCheck;
    keyCode = find(keyCode);

    if any(keyCode == options.keys.space)
        continue

    else any(keyCode == options.keys.escape)
        sca;

    end

end
Screen('CloseAll');

end