clc;
clear all;

portAddress = 16359; % Port address in decimal, in hex it is 03FE8 for Showy in MRI
pinMask = 255; % Value from 0 to 255 expressing which pins will be used when signals are sent, 255 = all 8 pins of the data port of the parallel port
pulseDur = 0.005; % Parallel port pulse duration in seconds
codeVal = 127;

parPulse(portAddress); % Initialise parallel port
parPulse(portAddress, 0, 0,  255, pulseDur); % Set all the pins to zero before you use the parallel port as pins are in an unknown state otherwise

parPulse(portAddress, codeVal, 0,  255, pulseDur); % Set pins to the code value and then afterwards set the pins to zero
