%% createStimuli_thermoMovie.m 
%  This script demonstrates how one can incrementally add disorder (heat)
%  or order (cool) to an image through manipulation in the wavelet domain. 
%  The procedure outlined here is described in section 2.5 of the following paper:
%  Puckett AM, Schira MM, Isherwood ZJ, Victor JD, Roberts JA, and 
%  Breakspear M. (2020) "Manipulating the structure of natural scenes using
%  wavelets to study the functional architecture of perceptual hierarchies 
%  in the brain" NeuroImage. 
%  https://www.sciencedirect.com/science/article/pii/S1053811920306595

%  Written by M.B. 
%  Some modification by A.M.P. 

%% Input
inImage = imread(strcat('stimuli_color/wombat.JPG'));

% Prepare image
N = 1536; 
inImage = inImage(1:N, :,:);
X=mean(inImage,3); %get rid of colour
X=X./mean(mean(X));  %normalize across images

% Set wavelet params
nLevels = 10; %Images that are 1536x1536 are affected up to level 10 by wavestrapping.
wv = 'db4'; % wavelet type

%% Movie bit
thermoType = 1; % 1 = freeze, 2 = thaw, 3 = heat, 4 = cool
v=VideoWriter('stimuli_thermoMovie/freeze_wombat_test'); %Movie output filename
v.FrameRate=10;
clims = [min(min(X)) max(max(X))];
loops=0:1:100;

%F(length(loops)) = struct('cdata',[],'colormap',[]);
open(v)
for i=1:length(loops) 
    if thermoType == 1
        Y=waveorder2(X,1:nLevels,wv,loops(i),1); % Freeze
    elseif thermoType == 2
            Y=waveorder2(X,1:nLevels,wv,loops(end)-loops(i),1); %Thaw
        elseif thermoType == 3
                Y=waveswap2(X,1:nLevels,wv,loops(i)); %Heat
            elseif thermoType == 4
                    Y=waveswap2(X,1:nLevels,wv,loops(end)-loops(i)); %Cool
    else
        disp("Error: thermoType doesn't exist")
        return
    end
    %figure(11), image(uint8(Y),clims), xticks([]), yticks([]), drawnow,
    figure(11), imagesc(Y,clims), colormap(gray), xticks([]), yticks([]), drawnow,
    frame=getframe(gcf);
    writeVideo(v,frame);
end
close(v)