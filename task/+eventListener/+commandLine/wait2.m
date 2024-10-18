function [elapsed,difference,dataFile] = wait2(timeout,options,dataFile,trial)

% -----------------------------------------------------------------------
% wait2.m waits for a specified duration in milliseconds
%
%   SYNTAX:     [elapsed,difference,dataFile] = eventListener.commandLine.wait2(timeout,options,expInfo,dataFile)
%                                                     
%   IN:         timeout:  integer, the timeout to wait in milliseconds (this
%                                   variable timeout has to be numeric, scalar & real)
%               options:  struct, options the tasks will run with
%               expInfo:  struct, contains key info on how the experiment is run
%               dataFile: struct, data file initiated in initDataFile.m
%               trial:    integer, trial number
%
%   OUT:        elapsed:    double, the effective time passed to execute this 
%                                   command. Can differ for some milliseconds
%               difference: double, the difference between timeout and the 
%                                   time used to execute the command 
%               dataFile:   struct, updated dataFile
%
%   SUBFUNCTIONS: flushevents: logical, this function blocks the matlab event 
%                 queue. In some cases it's necessary to execute background task. 
%                 But be aware, if this variable is set to true. The task will
%                 at least use 60ms to execute.
%    
%   AUTHOR(S):   About and Copyright of this function
%                Author: Adrian Etter
%                E-Mail: adrian.etter@econ.uzh.ch
%                SNS-Lab,
%                University of Zurich
%                Version 1.0 2012/September/4
%                Last revision: 2012/September/4
%                -finished & released
%
%               modified by: Frederike Petzschner, April 2017
%                            Katharina V. Wellstein, December 2019
%               last change: Katharina V. Wellstein, May 2021
% -------------------------------------------------------------------------
%
    ticID = tic();
    
    % Input error check
    if exist('timeout', 'var')
        if ~(isnumeric(timeout) && isscalar(timeout) && isreal(timeout))
            throw(MException('wait:timeout', 'The value timeout must be numeric, scalar and real'));
        end
    else
        throw(MException('wait:timeout', 'The input argument "timeout" is missing! Usage: wait(timeout);'));
    end
    
    if ~exist('flushevents', 'var')
        FlushEvents = false;        
    else
        if ~islogical(FlushEvents)
            try 
                FlushEvents = logical(FlushEvents);
            catch e
                e.addCause(MException('wait:flushevents', 'Keys must be numeric, real and a 1 dimensional vector'));
                rethrow(e)
            end
        end
    end
    
    timeout = timeout / 1000; % tic toc count in seconds
    elapsed = 0;
    
      while elapsed <= timeout
            elapsed = toc(ticID);
            [options,abort] = eventListener.commandLine.checkEscape(options,dataFile,trial);
            if FlushEvents == true
                drawnow();
            end  
      end
     difference   = elapsed - timeout;
     
      if abort 
           dataFile = eventListener.logEvent('exp_','abort',dataFile,1,trial);  
      end
end

