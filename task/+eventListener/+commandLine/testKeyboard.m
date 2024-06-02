function keyCode = testKeyboard

% -----------------------------------------------------------------------
% testKeyboard checks if there is an input either from the keyboard or from the
%              response box 
%
%   SYNTAX:      keyCode = testKeyboard
%
%   OUT:         keyCode: vector of numbers corresponding to the pressed keys
%
%   SUBFUNCTION(S): detectkey.m
%
%   AUTHOR(S):   coded by:  Frederike Petzschner, April 2017
%                amended:  Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%

%% INITIALIZE

waiting = 1;
ticID = tic();
rt = 0;
keyCode = [];
KbName('UnifyKeyNames');

while waiting
    keyCode = detectkey(1, 1); % deviceNumber, doKeyboard
    rt = toc(ticID);
    if any(keyCode==45)
        resp       = 1;
        waiting    = 0;
    elseif any(keyCode==58)
        resp       = 0;
        waiting    = 0;
    elseif KbName == 'tab'
        resp       = 0;
        waiting    = 0;
    elseif KbName == ',<' 
        resp       = -1;
        waiting    = 0;
    elseif KbName == '.>'
        resp       = 1;
        waiting    = 0;
    elseif rt> 5
        waiting    = 0;
        resp       = NaN;    
    end
end
end

%% DETECT KEY
function keyCode = detectkey(deviceNumber,doKeyboard)

if doKeyboard == 0
    % EEG
    [~, keyCode, ~] = PsychRTBox('GetSecs', store.rtbox.rthandle);
    % also check keyboard in case of an escape
    [ ~, ~, keyCode2,  ~] = KbCheck(deviceNumber);
    keyCode2 = find(keyCode2);
    keyCode = [keyCode, keyCode2];
else
    [ ~, ~, keyCode,  ~] = KbCheck(deviceNumber);
    keyCode = find(keyCode);
end 

end