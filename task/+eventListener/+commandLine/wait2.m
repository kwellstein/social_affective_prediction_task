function [elapsed,difference,dataFile] = wait2(timeout,options,dataFile,trial)

% -----------------------------------------------------------------------
% wait2.m waits for a specified duration in milliseconds
%                      multiple keyboards. if you want to wait for a KB response
%                      it can happem that KbCheck is looking at the wrong keyboard. 
%                      This script returns the correct device number for the 
%                      first keyboard detected
%
%   SYNTAX:     [elapsed,difference,dataFile] = wait2(timeout,options,expInfo,...
%                                                     dataFile,trial)
%   IN:         timeout:  integer, the timeout to wait in milliseconds (this
%                                   variable timeout has to be numeric, scalar & real)
%               options:  struct, options the tasks will run with
%               dataFile: struct, data file initiated in initDataFile.m
%               trial:    integer, trial number
%
%   OK:         elapsed:    double, the effective time passed to execute this 
%                                   command. Can differ for some milliseconds
%               difference: double, the difference between timeout and the 
%                                   time used to execute the command
%
%   SUBFUNCTIONS: flushevents: logical, this function blocks the matlab event 
%                 queue. In some cases it's necessary to execute background task. 
%                 But be aware, if this variable is set to true. The task will
%                 at least use 60ms to execute.
%    
%   AUTHOR:      About and Copyright of this function
%                Author: Adrian Etter
%                E-Mail: adrian.etter@econ.uzh.ch
%                ? SNS-Lab,
%                University of Zurich
%                Version 1.0 2012/September/4
%                Last revision: 2012/September/4
%                -finished & released
%
%               Modified: Frederike Petzschner,   April 2017
%                         Katharina V. Wellstein, December 2019 for VAGUS study,
%	                                              XX.2024 for SAPS study
% -------------------------------------------------------------------------
% This file is released under the terms of the GNU General Public Licence
% (GPL), version 3. You can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% This file is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program. If not, see <https://www.gnu.org/licenses/>.
% _______________________________________________________________________________%
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
    
    difference = elapsed - timeout;
    dataFile = eventListener.logEvent('exp','_abort',dataFile,abort,trial);
end

