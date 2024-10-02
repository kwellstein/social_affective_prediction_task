function dataFile = cleanDataFields(dataFile,trial)

% -----------------------------------------------------------------------
% cleanDataFields.m eliminates excess zeros from data vectors
%
%   SYNTAX:       dataFile = cleanDataFields(dataFile,task,trial)
%
%   IN:           dataFile: struct, contains all variables, for which data
%                                   will be saved
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

dataFile.SAPPrediction.congruent = dataFile.SAPPrediction.congruent(1:trial,:);
dataFile.SAPPrediction.response  = dataFile.SAPPrediction.response(1:trial,:);
dataFile.SAPPrediction.rt        = dataFile.SAPPrediction.rt(1:trial,:);
dataFile.SAPQuestion.response    = dataFile.SAPQuestion.response(1:trial,:);
dataFile.SAPQuestion.rt          = dataFile.SAPQuestion.rt(1:trial,:);
dataFile.SAPSmileTime.rt         = dataFile.SAPSmileTime.rt(1:trial,:);

end
