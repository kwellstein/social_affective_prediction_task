# wavestrapping

This repo contains code for the wavelet resampling (or "wavestrapping") of images.
Details can be found in the following publication:
Puckett AM, Schira MM, Isherwood ZJ, Victor JD, Roberts JA, and Breakspear M. (2020) "Manipulating the structure of natural scenes using wavelets to study the functional architecture of perceptual hierarchies in the brain" NeuroImage.
https://www.sciencedirect.com/science/article/pii/S1053811920306595

See createStimuli_fMRI.m for demonstration on how the wavestrapped images were made for the fMRI experiment.

See createStimuli_color.m for example on how to apply to color images.

See createStimuli_thermoMovies.m for example on how to iteratively apply wavestrapping to heat / cool an image. 

See createStimuli_surrogateMovies.m for example on how to apply across dynamic (i.e., film) stimuli. 
