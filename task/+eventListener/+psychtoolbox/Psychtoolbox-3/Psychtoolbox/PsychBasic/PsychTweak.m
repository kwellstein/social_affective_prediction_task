function varargout = PsychTweak(cmd, varargin)
% PsychTweak() - Apply tweaks to various Psychtoolbox parameters.
%
% This function allows to tweak some low-level operating parameters of
% Psychtoolbox. Such tweaks often affect all mex files, not only specific
% files. You must execute this function before any other Psychtoolbox mex
% file is used, otherwise mex files may not pick up consistent settings
% and weird things may happen! If in doubt, execute "clear mex" before
% executing this function.
%
%
% Available subfunctions:
% =======================
%
%
% PsychTweak('Reset');
%
% -- Reset some, but not all, tweaks to defaults.
%
%
% PsychTweak('PrepareForVirtualMachine');
%
% -- Tweak some settings so Psychtoolbox can sort of run inside a Virtual
% Machine - or at least limp along in a way that is unsuitable for
% production use, but good enough for some basic testing & development of
% the toolbox itself, or maybe for some simple demos.
%
%
% PsychTweak('ScreenVerbosity', verbosity);
%
% -- Set initial level of verbosity for Screen(). This can be overridden via
% Screen('Preference','Verbosity'). The default verbosity is 3 = Errors,
% Warnings and some Info output.
%
%
% PsychTweak('UseGPUIndex', gpuidx);
% -- Use GPU with index 'gpuidx' for low-level access on Linux and OSX,
% instead of the automatically chosen GPU. This only works on multi-gpu
% systems. Hybrid-Graphics MacBookPro laptops are automatically handled,
% so there shouldn't be any need for this manual selection. The manual
% selection is needed in classic multi-gpu systems, e.g., MacPros or
% PC workstations with multiple powerful GPUs installed. On such systems,
% normally the first GPU (index 0) would always be used. This command
% allows to override that choice.
%
%
% Debugging of GStreamer based functions:
% ---------------------------------------
%
%
% PsychTweak('GStreamerDebug', debugconfig);
%
% -- Select level of verbosity for GStreamer low-level debug output.
% See <https://gstreamer.freedesktop.org/documentation/tutorials/basic/debugging-tools.html>
% for explanation of debug options.
%
%
% PsychTweak('GStreamerDumpFilterGraph', targetDirectory);
%
% -- Ask GStreamer to dump a snapshot of its current media processing
% pipeline into a .dot file at each important pipeline state change. These
% .dot files can be read by open-source tools like GraphViz and turned into
% visualizations of the complete structure and state of the media
% processing pipeline. `targetDirectory` must be the full path to an
% existing directory where the .dot files should be written to.
%
%
% PsychTweak('GStreamerPlaybackThreadingMethod', methodId);
% -- Ask GStreamer to use multi-threaded video decoding method 'methodId'
% for video playback if multi-threaded video decoding is requested by
% user-code. Only some codecs support this. Currently available values are:
% 1 = Frame-Threading, 2 = Slice-Threading, 3 = 2+1 = Frame and Slice
% threading. By default, Frame+Slice threading will be used.
%
%
% Debugging of USB based functions:
% ---------------------------------
%
%
% PsychTweak('LibUSBDebug', verbosity);
% -- Select level of verbosity for low-level debug output of USB functions.
% This currently sets the debug level of libusb-1.0 based functions, e.g,
% PsychHID, PsychKinectCore, some videocapture functions and others.
% Possible values: 0 = Silence (default), 1 = Errors, 2 = Errors +
% Warnings, 3 = Errors + Warnings + Info messages.
%
%
% Linux only tweaks:
% ------------------
%
% PsychTweak('GetSecsClock', clockid);
% -- Select type of system clock to use for all timing functions like GetSecs,
% WaitSecs, all timing and timestamps in Screen(), PsychPortAudio() etc.
% clockid can be any of:
%
% 0 = CLOCK_REALTIME (aka gettimeofday() time or wall clock). This is the default.
%     It counts the seconds since 1st January 1970 midnight. This clock can be set
%     by the system administrator, or external time services like NTP network time
%     service. If NTP or the system administrator so desires, time can jump forward
%     or backwards. Leap seconds can do similar things. Allows easy synchronization
%     of clocks across computers if they are all driven by a NTP or PTP time source.
%
% 1 = CLOCK_MONOTONIC. This clock can not jump backwards, but is always monotonically
%     increasing. Its zero point is typically system boot time. It freezes if the
%     system is suspended / sleeping. The clock is still slowly adjusted (slewed) by
%     external time sources like NTP or PTP if available. This can be the most efficient
%     selection if you don't need to have consistent time across computers or equipment.
%
% 4 = CLOCK_MONOTONIC_RAW. Like CLOCK_MONOTONIC, but no time correction wrt. an external
%     reference time source like NTP or PTP is performed.
%
% 7 = CLOCK_BOOTTIME. Like CLOCK_MONOTONIC, but keeps counting while system is sleeping.
%
% Note that only clockid 0 and 1 have been verified for precision and correctness to some
% degree. Other settings may cause to functions to malfunction or be imprecise.
%
%
% MS-Windows only tweaks:
% -----------------------
%
% PsychTweak('DontDisableProcessorIdling', dontDisable);
% -- Don't disable processor idling during certain Screen() operations, e.g.,
% during video refresh calibrations and timing startup tests in 'OpenWindow' if
% 'dontDisable' is set to 1. By default, processor idling is disabled during some
% tests, to keep cpu cores 100% busy and prevent cpu power management actions like
% switching to higher C-states, ie. prevent switching to C1 or higher. This causes
% a temporary increase in system idle power consumption, but reduces timing noise
% caused by C-state switching, and thereby improves the quality and reliability of
% the timing tests, hopefully reducing the frequency of "false positive" test
% failures. However, this could interfere with the operation of other 3rd party
% cpu performance tweaking tools and other low level tuning measures. Therefore
% this PsychTweak() setting allows to skip disable of processor idling during tests.
%
%
% PsychTweak('BackwardTimejumpTolerance', secs);
%
% -- Allow system clock to report a time that is up to `secs` in the past,
% ie., for time to jump backwards, without triggering any clock error
% handling. Some broken or deficient computer hardware shows this
% misbehaviour and MS-Windows can't cope with it. Normally PTB would
% trigger workarounds and error handling, but a small amount of this error
% apparently must be tolerated even on the latest generation of processor
% hardware to make some systems workable at all under MS-Windows.
%
% By default, PTB tolerates up to 100 nanoseconds aka 1e-7 secs of error.
%
% Some Intel Core i5 / i7 cpu's have been reported to exhibit errors of
% multiple microseconds, sometimes up to even over 10 microseconds!
%
%
% PsychTweak('ForwardTimejumpTolerance', secs);
%
% -- Allow system clock to report a time that is up to `secs` in the future,
% ie., for time to jump forward, without triggering any clock error
% handling. Some broken or deficient computer hardware shows this
% misbehaviour and MS-Windows can't cope with it. Normally PTB would
% trigger workarounds and error handling, but a small amount of this error
% apparently must be tolerated even on the latest generation of processor
% hardware to make some systems workable at all under MS-Windows.
%
% By default, PTB tolerates up to 250 msecs aka 0.25 secs of error, not
% because we expect such large errors on a well working system, but because
% the detection logic needs to allow some room for fuzzyness to avoid false
% alerts on heavily loaded systems.
%
%
% PsychTweak('ExecuteOnCPUCores', corelist);
%
% -- Restrict execution of timing sensitive Psychtoolbox processing threads
% to a subset of logical processor cores on a multi-core / multi-processor
% computer. This allows to workaround some bugs in timing hardware, but can
% seriously degrade performance and general timing behaviour of
% Psychtoolbox under more demanding workloads, so this may either help or
% hurt, depending on the system setup and application.
% `corelist` must be a vector with the numbers of cores that PTB threads
% are allowed to execute on, numbering starts with zero, ie., the 1st
% processor core has the number zero.
%
% By default, PTB does not restrict threads on Windows Vista and later, or
% on other operating systems than Windows, but restricts all threads to
% core zero on Windows XP. The most meaningful use of this parameter is to
% either restrict processing to core zero for Windows Vista and later if
% you know that this helps, or to allow threads on WindowsXP to execute on
% all available cores if you know that your system configuration is not
% susceptible to timing bugs in multi-core mode. PTB will normally
% automatically switch to single-core operation on any OS if timing bugs
% are detected -- it tries to fix itself.
%
%
% PsychTweak('ClockWorkarounds' [, warning = 1][, lockCores = 1][, lowres = 0][, abort = 0][, defaultlowres = 0]);
%
% -- Define how PTB should behave if it detects clock problems due to
% broken or misconfigured hardware. All flags are boolean with 1 = enable,
% 0 = disable, and all flags are optional with reasonable default settings.
%
% `warning`: 1 = Print critical warning messages to the command window to
% warn user about potentially broken timing in its scripts.
% This setting is on by default.
%
% `lockCores`: 1 = On first signs of trouble, switch to single processor
% operation, locking all processing threads to cpu core zero, then
% continue. Many multi-processor related clock bugs can be "fixed" this
% way, but performance and execution timing may be seriously impaired if
% all threads have to compete for computation time on one single processor
% core, while all other cores on a multi-core machine are essentially
% unused and idle. See help for `ExecuteOnCPUCores` for more explanation.
% This setting is on by default.
%
% `lowres`: 1 = Switch to a low-resolution backup timer if the `lockCores`
% workaround is disabled or proven ineffective to solve the problem. The
% lowres timer has only +/- 1 msec resolution and this workaround may only
% allow you to continue with very simple experiment scripts. Experiment
% scripts involving sound via PsychPortAudio,
% Videocapture or Videorecording, and other types of hardware input/output
% may fail in weird ways. Even for simple scripts, this may create new
% weird timing related problems.
% This setting is off by default due to the trouble it can cause.
%
% `abort`: 1 = Abort userscript / session if clock problems can't be fixed
% / worked around sufficiently well via the `lockCores` workaround, ie., if
% after enabling the workaround a successive clock error gets detected.
% This setting is off by default.
%
% `defaultlowres`: 1 = Use low-res backup timer by default, ignore the
% high-precision clock. This may help a script on a broken system to limp
% along, but is not recommended for production use, because it has the same
% problems as the `lowres` workaround.
% This setting is off by default.
%
%
% History:
%  9.07.2012  mk  Wrote it.
% 31.08.2014  mk  Remove 'DisableCVDisplayLink' option, CVDisplayLinks
%                 are off by default as of PTB 3.0.12 and must be enabled
%                 by selecting a VBLTimestampingmode > 0 via Screen('Preference'),
%                 as they are way too unreliable and crash prone.
%

if nargin < 1 || isempty(cmd)
    help PsychTweak;
    return;
end

if strcmpi(cmd, 'PrepareForVirtualMachine')
    if IsWin
        % Allow Screen() to execute on the Microsoft GDI software renderer.
        % That's horrible, but it is the best we can get on some VM's with
        % Windows as a guest system. E.g., a Windows-7 64-Bit guest on a MacOSX
        % host with VirtualBox (Win-7 Enterprise 64-Bit on OSX 10.7.4
        % 64-Bit, with VirtualBox from July 2012), has reasonably well
        % working OpenGL WDDM hardware accelerated support via
        % Chromium/Humper from within 32-Bit Matlab, but falls over with
        % 64-Bit Matlab, so we are forced to use the GDI software renderer
        % to be able to test that config at all inside a VM:
        Screen('Preference', 'ConserveVRAM', bitor(Screen('Preference', 'ConserveVRAM'), 64));
    end

    % Disable all sync tests and video refresh calibrations:
    Screen('Preference', 'SkipSyncTests', 2);
    
    % Signal we're inside a VM via environment variable:
    % This is, e.g., used to prevent use of Priority() scheduling,
    % Which can have bad effects on a running Virtual machine.
    setenv('PSYCH_IN_VM', '1');

    return;
end

if strcmpi(cmd, 'ScreenVerbosity')
    if length(varargin) < 1
        error('Must provide an initial Screen() verbosity level.');
    end
    
    val = varargin{1};
    if ~isnumeric(val) || ~isscalar(val)
        error('Must provide a single integer as argument!');
    end
    
    setenv('PSYCH_SCREEN_VERBOSITY', sprintf('%i', round(val)));
    return;
end

if strcmpi(cmd, 'LibUSBDebug')
    if length(varargin) < 1
        error('Must provide an initial LibUSBDebug level.');
    end
    
    val = varargin{1};
    if ~isnumeric(val) || ~isscalar(val)
        error('Must provide a single integer as argument!');
    end
    
    setenv('LIBUSB_DEBUG', sprintf('%i', round(val)));
    return;
end

if strcmpi(cmd, 'GStreamerDebug')
    if length(varargin) < 1
        error('Must provide a GStreamer debug config string.');
    end
    
    val = varargin{1};
    if ~ischar(val)
        error('Must provide a string as argument!');
    end
    
    setenv('GST_DEBUG', val);
    return;
end

if strcmpi(cmd, 'GStreamerDumpFilterGraph')
    if length(varargin) < 1
        error('Must provide a target directory for GStreamers filtergraph dump.');
    end
    
    val = varargin{1};
    if ~ischar(val)
        error('Must provide a string as argument!');
    end
    
    if val(end) == filesep
        val = val(1:end-1);
    end
    
    if ~exist(val, 'dir')
        error('Target directory for GStreamer dumps [%s] does not exist!', val);
    end
    
    setenv('GST_DEBUG_DUMP_DOT_DIR', val);
    return;
end

if strcmpi(cmd, 'GStreamerPlaybackThreadingMethod')
    if length(varargin) < 1
        error('Must provide an integer GStreamer playback threading method setting.');
    end
    
    val = varargin{1};
    if ~isscalar(val) || ~isnumeric(val)
        error('Must provide an integer value as argument!');
    end
    
    setenv('PSYCH_GST_THREAD_TYPES', sprintf('%i', floor(val)));
    return;
end

if strcmpi(cmd, 'UseGPUIndex')
    if length(varargin) < 1
        error('Must provide a gpu index to use..');
    end

    val = varargin{1};
    if ~isnumeric(val) || ~isscalar(val) || min(val) < 0
        error('%s: Parameter must be an integer index greater or equal to zero.', cmd);
    end
    val = round(val);

    setenv('PSYCH_USE_GPUIDX', sprintf('%i', val));
    return;
end

if strcmpi(cmd, 'DontDisableProcessorIdling')
    if length(varargin) < 1
        error('Must provide the dontDisable flag.');
    end

    val = varargin{1};
    if ~ismember(val, [0, 1])
        error('dontDisable flag must be 0 or 1.');
    end

    if val
        % Set marker variable:
        setenv('PSYCH_DONT_DISABLE_CPU_IDLING', '1');
    else
        % Delete marker variable:
        setenv('PSYCH_DONT_DISABLE_CPU_IDLING');
    end

    return;
end

% The following routines must be called before any PTB mex files are loaded,
% otherwise they won't pick up the tweak settings consistently. Check if
% any ptb mex files are loaded:

% inmem not yet implemented as of Octave 8.4, so Matlab only:
if exist('inmem') %#ok<EXIST>
    % Get list of all loaded mex files in cell array mexf:
    [foo, mexf] = inmem('-completenames'); %#ok<ASGLU>
    % We check for files who are stored in a filesystem path that has the
    % string 'psychtoolbox' in its name. We cannot simply check for
    % PsychtoolboxRoot, as users may place mex files in non-standard
    % locations, but one would at least hope they store them in something
    % with 'psychtoolbox' in its name:
    for i=1:length(mexf)
        if ~isempty(strfind(lower(mexf{i}), lower('psychtoolbox')))
            error('At least one Psychtoolbox mex file is already loaded: (%s). PsychTweak(''%s'' must be executed before any other Psychtoolbox mex file!', mexf{i}, cmd);
        end
    end
end

% Reset some signalling environment variables used by mex files:
if strcmpi(cmd, 'Reset')
    setenv('PSYCH_LOWRESCLOCK_FALLBACK');
    setenv('PSYCH_GETSECS_CLOCK');
    return;
else
    % Reset this one even if no 'Reset' command given:
    setenv('PSYCH_LOWRESCLOCK_FALLBACK');    
end

if strcmpi(cmd, 'GetSecsClock')
    if length(varargin) < 1
        error('Must provide a clockid.');
    end

    val = varargin{1};
    if ~isnumeric(val) || ~isscalar(val)
        error('Must provide a single integer as argument!');
    end

    val = round(val);

    if ~ismember(val, [0, 1])
        warning('A clockid other than 0 or 1 may cause some functions not to work correctly, or not with high precision.');
    end

    setenv('PSYCH_GETSECS_CLOCK', sprintf('%i', val));
    return;
end

if strcmpi(cmd, 'BackwardTimejumpTolerance')
    if length(varargin) < 1
        error('Must provide a timing threshold in seconds.');
    end
    
    val = varargin{1} * 1e9;
    if val < 0 || val > intmax
        error('Value must be between 0 and 2 seconds.');
    end

    setenv('PSYCH_BACKWARD_TIMEJUMP_TOLERANCE_NSECS', sprintf('%i', round(val)));
    return;
end

if strcmpi(cmd, 'ForwardTimejumpTolerance')
    if length(varargin) < 1
        error('Must provide a timing threshold in seconds.');
    end
    
    val = varargin{1} * 1e3;
    if val < 0 || val > intmax
        error('Value must be between 0 and 2 million seconds.');
    end
    
    setenv('PSYCH_FORWARD_TIMEJUMP_TOLERANCE_MSECS', sprintf('%i', round(val)));
    return;
end

if strcmpi(cmd, 'ExecuteOnCPUCores')
    if length(varargin) < 1
        error('Must provide a list of cpu cores to run Psychtoolbox threads on.');
    end
    
    val = varargin{1};
    if ~isnumeric(val) || ~isvector(val) || min(val) < 0 || max(val) > 31
        error('%s: Parameter must be an integer vector of cpu core ids between 0 and 31.', cmd);
    end
    val = round(val);
    
    % Convert core id's in parameter to cpu bitmask:
    cpumask = 0;
    for i=1:length(val)
       cpumask = cpumask + 2^(val(i));
    end
    
    setenv('PSYCH_CPU_MASK', sprintf('%i', round(cpumask)));
    return;
end

if strcmpi(cmd, 'ClockWorkarounds')
    if length(varargin) < 1
        error('Must provide a parameter list.');
    end
    
    if length(varargin) >= 1 && ~isempty(varargin{1})
        warningout = round(varargin{1});
    else
        warningout = 1;
    end
    
    if length(varargin) >= 2 && ~isempty(varargin{2})
        corelockwa = round(varargin{2});
    else
        corelockwa = 1;
    end
    
    if length(varargin) >= 3 && ~isempty(varargin{3})
        lowreswa = round(varargin{3});
    else
        lowreswa = 0;
    end
    
    if length(varargin) >= 4 && ~isempty(varargin{4})
        errabort = round(varargin{4});
    else
        errabort = 0;
    end
    
    if length(varargin) >= 5 && ~isempty(varargin{5})
        lowresdef = round(varargin{5});
    else
        lowresdef = 0;
    end
    
    val = 0;
    
    if warningout
        val = val + 1;
    end
    
    if corelockwa
        val = val + 2;
    end
    
    if lowreswa
        val = val + 4;
    end

    if errabort
        val = val + 8;
    end

    if lowresdef
        val = val + 16;
    end

    setenv('PSYCH_CLOCKERROR_MODE', sprintf('%i', round(val)));
    return;
end

% Nothing dispatched? Give help to the helpless:
help PsychTweak;
error('Invalid or unknown command specified.');

end
