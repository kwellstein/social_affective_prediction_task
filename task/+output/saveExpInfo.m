function expInfo = saveExpInfo(expMode,PPID,visitNo,stairType)

% -----------------------------------------------------------------------
% aveExpInfo.m creates a struct with all the key data and info on the
%              current run of the experimentthe experiment, i.e. the
%              computer it was run on, the date, the time it took, the errors 
%              detected,
%              etc.
%
%   SYNTAX:     expInfo = data.saveExpInfo
%
%   IN:         expMode:   string, 'debug' or 'experiment'
%               PPID:      string, 4-digit project participation ID
%               visitNo:   integer
%               stairType: string, 'simpleUp','simpleDown','interleaved'
%
%   OUT:        expInfo: struct containing general info regarding this
%                        experiment run
%
%   SUBFUNCTIONS: getVisitType.m
%
%   AUTHOR:     Katharina V. Wellstein, December 2019
% -------------------------------------------------------------------------
%

expInfo.date              = datestr(now,'yyyymmdd');
expInfo.startTime         = [];
expInfo.stopTime          = [];
expInfo.startBreak        = [];
expInfo.stopBreak         = [];
expInfo.expMode           = expMode;
expInfo.PPID              = PPID;
expInfo.visit.number      = visitNo;
expInfo.visit.type        = [];
expInfo.stairType         = stairType;
expInfo.OS                = [];
expInfo.KBNumber          = [];
expInfo.NScreens          = [];
expInfo.pStim.COM         = stimulation.getAvailableComPort();
expInfo.pStim.mode        = [];

expInfo.randomisationPath = '/Users/kwellste/git/VAGUS/task/+eventCreator';
expInfo.savePath          = '/Users/kwellste/git/VAGUS/task/+output';
expInfo.visit.type        = eventCreator.getVisitType(expInfo);

end
