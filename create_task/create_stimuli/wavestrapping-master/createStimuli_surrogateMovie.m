% createStimuli_surrogateMovie.m 
%  This script demonstrates how to apply wavestrapping to color videos.
%  The procedure outlined here is described in section 2.4 of the following paper:
%  Puckett AM, Schira MM, Isherwood ZJ, Victor JD, Roberts JA, and 
%  Breakspear M. (2020) "Manipulating the structure of natural scenes using
%  wavelets to study the functional architecture of perceptual hierarchies 
%  in the brain" NeuroImage. 
%  https://www.sciencedirect.com/science/article/pii/S1053811920306595

%  Written by J.A.R. 2020

infilename=fullfile(matlabroot,'toolbox','matlab','audiovideo','xylophone.mpg');
outfilename='stimuli_surrogateMovie/xylophone_wavesurr_db4_N5.mp4';

% wavelet parameters
wv='db4';  % which wavelet
wN=5; % maximum level
wn=1:wN;  % range of levels to use
wc=1;  % choice of resampling scheme: 1=permtx, 2=rotmtx, 3=blkmtx=MISSING
st=1; % fixed random seed

% check inputs
if exist(outfilename,'file')
    overwrite=input([strrep(outfilename,'\','\\') ' exists, overwrite? y/[n]: '],'s');
    if ~strcmp(overwrite,'y')
        return
    end
end
[pathstr,name,ext] = fileparts(outfilename);
if ~strcmp(ext,'.mp4')
    outfilename=[pathstr name '.mp4'];
end

readerObj = VideoReader(infilename);
fps=readerObj.FrameRate;

fprintf('input has ~%d frames\n',floor(readerObj.Duration*readerObj.FrameRate))

% set up output video
% %%% MPEG-4
writerObj = VideoWriter(outfilename,'MPEG-4');
writerObj.FrameRate=fps;
writerObj.Quality=100; % may want to adjust; matlab default is 75

open(writerObj);

tic
jj=0; % counter for which frame we're up to
fprintf('frame: ')
while hasFrame(readerObj)
    inim=readFrame(readerObj);
    
    jj=jj+1;  
    
    if ~mod(jj,fps*10)
        fprintf(1,'%d ',jj);
        if ~mod(jj,30*fps*10)
            fprintf(1,'\n');
        end
    end
    
    surrim=uint8(wavesurr2_rgb(inim,wn,wv,wc,st));  % wavelet resample the gazecentered frame

    % write frame to output video
    writeVideo(writerObj,surrim);
end
close(writerObj);
fprintf('%d \n',jj);
toc

% optionally can add the original audio tracks back in (requires ffmpeg)
addaudio=0;
if addaudio
    if ispc
        ffmpegpath='C:\Program Files\ffmpeg\bin\ffmpeg'; % fix if needed
    else
        ffmpegpath='ffmpeg'; % fix if needed
    end
    outfile=[outfilename(1:end-4) '_muxed' outfilename(end-3:end)]; % assuming mp4 extension...
    % ffmpeg checks whether the file already exists
    cmd=['"' ffmpegpath '"' ' -i "' outfilename '" -i "' infilename '" -map 0:v -map 1:a -codec copy -shortest "' outfile '"'];
    system(cmd);
end
