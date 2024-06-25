function dataFile = cleanDataFields(dataFile,task,trial)

% -----------------------------------------------------------------------
% cleanDataFields.m eliminates excess zeros from data vectors
%
%   SYNTAX:       dataFile = cleanDataFields(dataFile,task,trial)
%
%   IN:           dataFile: struct, contains all variables, for which data
%                                   will be saved
%                 task:     string, task name
%                 trial:    integer, trial number
%
%   OUT:          dataFile: struct, updated data file
%
%
%   AUTHOR:     Coded by: Katharina V. Wellstein, December 2019
%                         wellstein@biomed.ee.ethz.ch
%               Amended by xxx, xx.xxxx
% -------------------------------------------------------------------------
%

switch task
    case 'calib'
        dataFile.calib.amplitude         = dataFile.calib.amplitude(1:trial,1:2);
        dataFile.calib.response          = dataFile.calib.response(1:trial,1:2);
    
    case 'painDetect'
        dataFile.painDetect.amplitude    = dataFile.painDetect.amplitude(1:trial,1:2);
        dataFile.painDetect.response     = dataFile.painDetect.response(1:trial,1:2);
    
    case 'stair'
        dataFile.stair.amplitude         = dataFile.stair.amplitude(1:trial,1:2);
        dataFile.stair.targetedAmplitude = dataFile.stair.targetedAmplitude(1:trial,1:2);
        dataFile.stair.response          = dataFile.stair.response(1:trial,1:2);
        
    case 'stim'
        dataFile.stim.response1stRun     = dataFile.stim.response1stRun(1:trial,1:2);
        dataFile.stim.response2ndRun     = dataFile.stim.response2ndRun(1:trial,1:2);
end
