function plotAmplitudes(task,type,expMode,dataFile)
% -----------------------------------------------------------------------
% plotAmplitudes.m plots amplitudes and responses of the adaptive
%                  stimulation tasks
%
%   SYNTAX:       plotAmplitudes(task,stairType,dataFile)
%
%   IN:           task:      string, task which should be plotted
%                 type:      string, if the task type {pain, detect,
%                                    simpleUp, simpleDown,interleaved}
%                 dataFile:  struct, contains all data, which can be plotted
%
%   OUT:          plot
%
%   AUTHOR:       Coded by: Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%
if strcmp(task,'stair')
        if strcmp(type,'interleaved')
            % prepare data dataFile.calib.amplitude(1:idx,1)
            reversals                    = dataFile.stair.reversals;   
            simpleUpReversals            = dataFile.stair.reversals(1:2:end);
            simpleUpResponses            = dataFile.stair.response(1:2:end,1);
            simpleUpAmplitudes           = dataFile.stair.amplitude(1:2:end,1);
            simpleUptargetedAmplitudes   = dataFile.stair.targetedAmplitude(1:2:end,1);
            simpleDownReversals          = dataFile.stair.reversals(2:2:end);
            simpleDownResponses          = dataFile.stair.response(2:2:end,1);
            simpleDownAmplitudes         = dataFile.stair.amplitude(2:2:end,1);
            simpleDowntargetedAmplitudes = dataFile.stair.targetedAmplitude(2:2:end,1);

            % full interleaved staircase - amplitudes
            figure('Color',[1 1 1]);
            subplot(4,1,1), plot(dataFile.stair.amplitude(1:end,1), '.-')
            xlabel('trial');
            ylabel('amplitude');
            hold on; plot(ones(size(dataFile.stair.amplitude(1:end,1)))...
                                              .*dataFile.stair.threshold(1),'r-.')
            hold on;
            plot(find(reversals==1), ones(numel(find(reversals==1)))....
                 .*dataFile.stair.threshold(1),'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k')
            legend('amplitudes','detection threshold','reversals','location','northeastoutside')
            title('full interleaved staircase - amplitudes & reversals')

            % full interleaved staircase - responses
            subplot(4,1,2), stem(dataFile.stair.response(1:end,1))
            xlabel('trial');
            ylabel('response');
            hold on; plot(ones(size(dataFile.stair.response(1:end,1))).*0.5,'g-.')
            hold on;
            plot(find(reversals==1), ones(numel(find(reversals==1))).*0.5, ...
                'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k')
            legend('responses','response threshold','reversals','location','northeastoutside')
            title('full interleaved staircase - responses & reversals')

            % Up staircase - amplitudes
            subplot(4,1,3), plot(simpleUptargetedAmplitudes, '.-')
            xlabel('trial')
            ylabel('amplitude')
            hold on; plot(ones(size(simpleUptargetedAmplitudes)).*dataFile.stair.threshold(2),'r-.')
            hold on;
            plot(find(simpleUpReversals==1), ones(numel(find(simpleUpReversals==1)))...
                .*dataFile.stair.threshold(2),'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k') 
            hold on;plot(find(simpleUpResponses==1), ones(numel(find(simpleUpResponses==1)))...
                .*dataFile.stair.threshold(2),'og', 'MarkerSize', 8) 
            legend('amplitudes','detection threshold','reversals','responses','location','northeastoutside')
            title('up staircase')

            % Down staircase - amplitudes
            subplot(4,1,4), plot(simpleDowntargetedAmplitudes, '.-')
            xlabel('trial')
            ylabel('amplitude')
            hold on; plot(ones(size(simpleDowntargetedAmplitudes)).*dataFile.stair.threshold(3),'r-.')
            hold on; plot(find(simpleDownReversals==1), ones(numel(find(simpleDownReversals==1)))...
                .*dataFile.stair.threshold(3),'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k')
            hold on;plot(find(simpleDownResponses==1), ones(numel(find(simpleDownResponses==1)))...
                .*dataFile.stair.threshold(3),'og', 'MarkerSize', 8);
            legend('amplitudes','detection threshold','reversals','location','northeastoutside')
            title('down staircase')
            figName = [task,type,' - amplitudes'];

        else
             figure('Color',[1 1 1]);
             subplot(2,1,1), plot(dataFile.(task).amplitude(1:end,1), '.-')
             xlabel('trial');
             ylabel('Amplitude');
             hold on; plot(ones(size(dataFile.(task).amplitude(1:end,1))).*dataFile.stair.threshold, 'r-.')
             legend('amplitudes','detection threshold')
             title([task type])
             subplot(2,1,2), stem(dataFile.(task).response(1:end,1),'g')
             xlabel('trial');
             ylabel('response');
             figName = [task,type,' - amplitudes'];
        end
        
elseif strcmp(task,'calib') || strcmp(task,'painDetect')
       figure('Color',[1 1 1]);
       subplot(2,1,1), plot(dataFile.(task).amplitude(1:end,1), '.-')
       xlabel('trial');
       ylabel('amplitude');
       title(task)
       subplot(2,1,2), stem(dataFile.(task).response(1:end,1),'g')
       xlabel('trial');
       ylabel('response');
       figName = [task,' - amplitudes']; 
end


savefig(['+output/+figures/',figName]);

if strcmp(expMode,'experiment')
    close all;
end

end