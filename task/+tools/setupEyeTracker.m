function [el, exit_flag] = setupEyeTracker( tracker, window, constants )
% SET UP TRACKER CONFIGURATION. Main goal is to modify defaults set in EyelinkInitDefaults.

%{
  REQUIRED INPUT:
    tracker: string, either 'none' or 'T60'
  window: struct containing at least the fields
  window.background: background color (whatever was set during call to e.g., PsychImaging('OpenWindow', window.screenNumber, window.background))
  window.white: numeric defining the color white for the open window (e.g., window.white = WhiteIndex(window.screenNumber);)
  window.windowPtr: scalar pointing to main screen (e.g., [window.windowPtr, window.winRect] = PsychImaging('OpenWindow', ...
                                                                                                        window.screenNumber,window.background);)
  window.winRect; PsychRect defining size of main window (e.g., [window.windowPtr, window.winRect] = PsychImaging('OpenWindow', ...
                                                                                                                window.screenNumber,window.background);)
  constants: struct containing at least
  constants.eyelink_data_fname: string defining eyetracking data to be saved. Cannot be longer than 8 characters (before file extention). File extension must be '.edf'. (e.g., constants.eyelink_data_fname = ['scan', num2str(input.runnum, '%02d'), '.edf'];)
  
  OUTPUT:
    if tracker == 'T60'
  el: struct defining parameters that have been set up about the eyetracker (see EyelinkInitDefaults)
  if tracker == 'none'
  el == []
  exit_flag: string that can be used to check whether this function exited successfully
  
  SIDE EFFECTS:
    When tracker == 'T60', calibration is started

author: Patrick Sadil; 05-06-2018, "Eyetracking with eyelink in
psychtoolbox"
  %}

%%
  exit_flag = 'OK';

switch tracker

case 'T60'
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el = EyelinkInitDefaults(window.windowPtr);

% overrride default gray background of eyelink, otherwise runs end
% up gray! also, probably best to calibrate with same colors of
% background / stimuli as participant will encounter
el.backgroundcolour = window.task;
el.foregroundcolour = window.white;
el.msgfontcolour    = window.white;
el.imgtitlecolour   = window.white;
el.calibrationtargetcolour=[window.white window.white window.white];
EyelinkUpdateDefaults(el);

if ~EyelinkInit(0, 1)
fprintf('\n Eyelink Init aborted \n');
exit_flag = 'ESC';
return;
end

%Reduce FOV
Eyelink('command','calibration_area_proportion = 0.5 0.5');
Eyelink('command','validation_area_proportion = 0.48 0.48');

% open file to record data to
i = Eyelink('Openfile', constants.eyelink_data_fname);
if i ~= 0
fprintf('\n Cannot create EDF file \n');
exit_flag = 'ESC';
return;
end

Eyelink('command', 'add_file_preamble_text ''Recorded by NAME OF EXPERIMENT''');

% Setting the proper recording resolution, proper calibration type,
% as well as the data file content;
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, window.rect(3)-1, window.rect(4)-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, window.rect(3)-1, window.rect(4)-1);
% set calibration type.
Eyelink('command', 'calibration_type = HV5');

% set EDF file contents using the file_sample_data and
% file-event_filter commands
% set link data thtough link_sample_data and link_event_filter
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');

% check the software version
% add "HTARGET" to record possible target data for EyeLink Remote
Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,GAZERES,AREA,HTARGET,STATUS,INPUT');
Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,HREF,GAZERES,AREA,HTARGET,STATUS,INPUT');

% make sure we're still connected.
        if Eyelink('IsConnected')~=1 && input.dummymode == 0
            exit_flag = 'ESC';
            return;
        end

        % possible changes from EyelinkPictureCustomCalibration

        % set sample rate in camera setup screen
        Eyelink('command', 'sample_rate = %d', 1000);

        % Will call the calibration routine
        EyelinkDoTrackerSetup(el);

    case 'none'
        el = [];
end

end