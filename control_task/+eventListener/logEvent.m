function dataFile = logEvent(task,event,dataFile,X,trial)

% -----------------------------------------------------------------------
% logEvent.m logs timing of events specified in eventName and saves the data
%
%   SYNTAX:       dataFile = logEvent(task,event,dataFile,X,trial)
%
%   IN:           task:     string, name of task for which event should be saved 
%                 event:    string, name of event which should be saved 
%                 dataFile: struct, data file initiated in initDataFile.m
%                 X:        logical, data to be stored in logical arrays

%
%   OUT:          dataFile: struct, updated data file 
%
%   SUBFUNCTIONS: GetSecs.m
%
%   AUTHOR:     Based on: Frederike Petzschner & Sandra Iglesias, 2017
%               Amended:  Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%
if strcmp(task,'debug')
   task = 'practice'; 
   eventName   = [task event];
else
    eventName   = [task event]; 
end


if   islogical(dataFile.events.(eventName))
     dataFile.events.(eventName(trial,:)) = [task, X];
     
    else  
    eventTime = GetSecs() - dataFile.events.exp_startTime;
    dataFile.events.(eventName)           = eventTime;

end

end