function [key,tkey]=CheckKeyPress(whichkeys)

if nargin<1 || isempty(whichkeys)
    whichkeys = 1:256;
end
key =0;

[keyIsDown, tkey, keys, deltaSecs] = KbCheck(1);
if any(keys(whichkeys),1)
    key = find(keys(whichkeys),1)
end
end