function dataFile = showGetPredictionSlide(cue,options,dataFile,task,trial)

% -----------------------------------------------------------------------
% showSlidingBarQuestion.m shows sliding bar question and records the response
%
%   SYNTAX:     [dataFile] = tools.showGetPredictionSlide(cues,options,dataFile,expInfo,taskSaveName,trial)
%
%   IN:         cues:         struct, containing general  options and task specific
%               options:      struct, options the tasks will run with
%               dataFile:     struct, data file initiated in initDataFile.m
%               expInfo:      struct, contains key info on how the experiment is
%                                   run instance, incl. keyboard number
%               task:         string, name of how task output will be
%                                     saved, i.e. task incl task run
%               trial:        integer, trial number, i.e. "question trial"
%
%   OUT:        dataFile: struct, updated dataFile with responses
%
%   SUBFUNCTION(S): logData.m
%
%   AUTHOR(S):  Katharina V. Wellstein, XX.2024
% -------------------------------------------------------------------------
