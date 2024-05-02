function [X, dataFile] = logData(X,task,event,dataFile,trial)
% -----------------------------------------------------------------------
% logData.m logs data point X and a time stamp on each trial for each task
%
%   SYNTAX:       [X, dataFile] = logData(X,task,event,dataFile,trial)
%
%   IN:           X:        any value, data to be stored
%                 task:     string, name of task for which event should be saved 
%                 event:    string, name of event which should be saved 
%                 dataFile: struct, data file initiated in initDataFile.m
%                 trial:    integer, trial number
%
%   OUT:          X:        any value, data point
%                 dataFile: struct, updated data file 
%
%   SUBFUNCTIONS: GetSecs.m
%
%   AUTHOR:     Coded by:    Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------

fieldName = dataFile.(task).(event);

switch event
    case'rt'
    fieldName(trial,:) = X;
    otherwise 
    eventTime          = GetSecs() - dataFile.events.exp_startTime;
    fieldName(trial,:) = [X, eventTime];
end

dataFile.(task).(event) = fieldName;
end