function dataFile = cleanDataFields(dataFile,trial,predictField,questField,smileTimeField)

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

dataFile.(predictField).congruent = dataFile.(predictField).congruent(1:trial,:);
dataFile.(predictField).response  = dataFile.(predictField).response(1:trial,:);
dataFile.(predictField).rt        = dataFile.(predictField).rt(1:trial,:);
dataFile.(questField).response    = dataFile.(questField).response(1:trial,:);
dataFile.(questField).rt          = dataFile.(questField).rt(1:trial,:);
dataFile.(smileTimeField).rt      = dataFile.(smileTimeField).rt(1:trial,:);

dataFile.events.exp_abort            = dataFile.events.exp_abort(1:trial,:);
dataFile.events.exp_missedTrial      = dataFile.events.exp_missedTrial(1:trial,:);
dataFile.events.exp_questWrongButton = dataFile.events.exp_questWrongButton(1:trial,:);
dataFile.events.exp_timeOut          = dataFile.events.exp_timeOut(1:trial,:);

end
