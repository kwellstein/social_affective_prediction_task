function showScreenVisuals(options,cues,cueType,durScreenWait, durKeypressWait)

Screen('DrawTexture', options.screen.windowPtr, cues.stimulationStart, [], options.screen.rect, 0);
Screen('Flip', options.screen.windowPtr);

eventListener.commandLine.wait2(options.dur.deltawin2stim, options);


end