function keyCode = detectKey(KBNumber,doKeyboard)

% -----------------------------------------------------------------------
% detectKey.m checks if there is an input either from the keyboard or from the
%              response box 
%
%   SYNTAX:     keyCode = eventListener.commandLine.detectKey(KBNumber,doKeyboard)
%
%   IN:         KBNumber:   integer, number of the first found keyboard device
%               doKeyboard: logical, set to 1 if task is done on computer (as
%                                    opposed to response box)
%
%   OUT:        keyCode: vector of numbers corresponding to the pressed keys
%
%   AUTHOR:     coded by:  Frederike Petzschner, April 2017
%               amended:   Katharina V. Wellstein, June 2020
% -------------------------------------------------------------------------
%
 
if doKeyboard == 0
    % EEG Responsebox
    [~, keyCode, ~] = PsychRTBox('GetSecs', store.rtbox.rthandle);
    
    % also check keyboard in case of an escape
    [ ~, ~, keyCode2,  ~] = KbCheck(KBNumber);
    keyCode2 = find(keyCode2);
    keyCode = [keyCode, keyCode2];
else
    [ ~, ~, keyCode,  ~] = KbCheck;
    keyCode = find(keyCode);
end

