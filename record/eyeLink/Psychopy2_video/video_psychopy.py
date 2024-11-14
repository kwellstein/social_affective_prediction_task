######## Psychopy demo with the custom Psychopy Core Graphics
# If you need to use a screen units other than 'pix', which we do not recommend as the gaze coordinates 
# returned by pylink is in 'pix' units, please make sure to properly set the size of the cursor and the
# position of the gaze. However, the calibration/validation routine should work fine regardless of the 
# screen units.

# import libraries
import pylink, numpy, os, random
from EyeLinkCoreGraphicsPsychoPy import EyeLinkCoreGraphicsPsychoPy
from psychopy import visual, core, event, gui, monitors

#### STEP I: get subject info with GUI ########################################################
expInfo = {'SubjectNO':'00', 'SubjectInitials':'TEST'}
dlg = gui.DlgFromDict(dictionary=expInfo, title="GC Example", order=['SubjectNO', 'SubjectInitials'])
if dlg.OK == False: core.quit()  # user pressed cancel

#### SETP II: established a link to the tracker ###############################################
dummyMode = True # If in Dummy Mode, press ESCAPE to skip calibration/validataion
if not dummyMode:
    tk = pylink.EyeLink('20.100.1.2')
else:
    tk = pylink.EyeLink(None)

#### STEP III: Open an EDF data file EARLY ####################################################
dataFolder = os.getcwd() + '/edfData/'
dataFileName = expInfo['SubjectNO'] + '_' + expInfo['SubjectInitials'] + '.EDF'

# Note that for Eyelink 1000/II, he file name cannot exceeds 8 characters
# we need to open eyelink data files early so as to record as much info as possible
tk.openDataFile(dataFileName)
# add personalized header (preamble text)
tk.sendCommand("add_file_preamble_text 'Psychopy GC demo'") 

#### STEP IV: Initialize custom graphics for camera setup & drift correction ##################
scnWidth, scnHeight = (1920, 1080)
# you MUST specify the physical properties of your monitor first, otherwise you won't be able to properly use
# different screen "units" in psychopy 
mon = monitors.Monitor('myMac15', width=32.0, distance=57.0)
mon.setSizePix((scnWidth, scnHeight))
win = visual.Window((scnWidth, scnHeight), fullscr=True, monitor=mon, color=[0,0,0], units='pix')

# this functional calls our custom calibration routin "EyeLinkCoreGraphicsPsychopy.py"
genv = EyeLinkCoreGraphicsPsychoPy(tk, win)
pylink.openGraphicsEx(genv)

#### STEP V: Set up the tracker ################################################################
# we need to put the tracker in offline mode before we change its configrations
tk.setOfflineMode()
# sampling rate
tk.sendCommand('sample_rate 500') 
# 0-> standard, 1-> sensitive [Manual: section ??]
tk.sendCommand('select_parser_configuration 0') 
# make sure the tracker knows the physical resolution of the subject display
tk.sendCommand("screen_pixel_coords = 0 0 %d %d" % (scnWidth-1, scnHeight-1))
# stamp display resolution in EDF data file for Eyelink Data Viewer integration
tk.sendMessage("DISPLAY_COORDS = 0 0 %d %d" % (scnWidth-1, scnHeight-1))
# Set the tracker to record Event Data in "GAZE" (or "HREF") coordinates
tk.sendCommand("recording_parse_type = GAZE") 
# Here we show how to use the "setXXXX" command to control the tracker, see the "EyeLink" section of the pylink manual.
# specify the calibration type, H3, HV3, HV5, HV13 (HV = horiztonal/vertical)
tk.sendCommand("calibration_type = HV9")
# tk.setCalibrationType('HV9')
# color theme of the calibration display
pylink.setCalibrationColors((255,255,255), (0,0,0))
# allow buttons on the gamepad to accept calibration/dirft check target 
tk.sendCommand("button_function 1 'accept_target_fixation'")


# set link and file contents
eyelinkVer = tk.getTrackerVersion()
if eyelinkVer >=3: # Eyelink 1000/1000 plus
    tk.sendCommand("file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT")
    tk.sendCommand("link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,INPUT")
    tk.sendCommand("file_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HREF,PUPIL,STATUS,INPUT,HTARGET")
    tk.sendCommand("link_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HREF,PUPIL,STATUS,INPUT,HTARGET")
else: # Eyelink II
    tk.sendCommand("file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT")
    tk.sendCommand("link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,INPUT")
    tk.sendCommand("file_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HREF,PUPIL,STATUS,INPUT")
    tk.sendCommand("link_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HREF,PUPIL,STATUS,INPUT")

#### STEP VI: specify all possible experimental cells #################################################
# one may read in s spreadsheet that defines the experimentl cells; usually, a simple list-like the one below
# should also do the job; if we need tweenty trials, simple go with "new_list = trials[:]*10", then 
# random.shuffle(new_list) 
trials = [['CondA', 'baby_laugh.mp4'],
          ['CondB', 'baby_laugh.mp4']]
 
 
  
  
#### SETP VII: a helper to run a single trial #########################################################
def runTrial(pars):
    """ pars corresponds to a row in the trial list"""
    
    # retrieve paramters from the trial list
    cond, movieFile = pars 
    
    # load the image to display
    mov = visual.MovieStim3(win, "videos/" + movieFile, size=(320, 240), flipVert=False, flipHoriz=False, loop=False) 
                            
    # take the tracker offline
    tk.setOfflineMode()
    pylink.pumpDelay(50)

    # send the "TRIALID" message to mark the start of a trial 
    tk.sendMessage('TRIALID')
    
    # record_status_message : show some info on the host PC
    tk.sendCommand("record_status_message 'Cond %s'"% cond)
    
    # drift check
    try:
        err = tk.doDriftCorrect(win.size[0]/2, win.size[1]/2,1,1)
    except:
        tk.doTrackerSetup()    
        
    # start recording
    tk.setOfflineMode()
    pylink.pumpDelay(50)
    error = tk.startRecording(1,1,1,1)
    pylink.pumpDelay(100) # wait for 100 ms to make sure data of interest is recorded
    
    # show the image 
    win.flip()
    tk.sendMessage('DISPLAY_SCREEN') # this message marks the time 0 of a trial, can also send the "DISPLAY_SCREEN" message here

    
    #determine which eye(s) are available
    eyeTracked = tk.eyeAvailable() 
    
    # show the image indefinitely or press a key to terminate a trial
    gazePos =  (scnWidth/2, scnHeight/2)
    terminate = False
    
    frameNum = 0
    movX, movY  = mov.size    
    movClock = core.Clock(); movClock.reset()     
    #movDuration = mov._movie.duration 
    movDuration = 2
    currentFrameTimeStamp = mov.getCurrentFrameTime()
   
    while not terminate:
        # draw movie frame 
        mov.draw()
        win.flip()
        
        # check frame timestamps
        nextFrameTimeStamp = mov.getCurrentFrameTime()
        if nextFrameTimeStamp <> currentFrameTimeStamp:
            frameNum += 1
            
            tk.sendMessage("!V VFRAME %d %d %d %s" % (frameNum, scnWidth/2-movX/2, scnHeight/2-movY/2, "./../videos/" + movieFile))
        if movClock.getTime() >= movDuration: terminate = True
        
    # clear the subject display
    win.color=[0,0,0]
    win.flip()
    
    # clear the host display
    tk.sendCommand('clear_screen 0') 

    # send trial variables for Data Viewer integration
    tk.sendMessage('!V TRIAL_VAR cond %s' %cond)

    # send a message to mark the end of trial
    tk.sendMessage('TRIAL_RESULTS 0')
    pylink.pumpDelay(100)
    tk.stopRecording() # stop recording


#### STEP VIII: The real experiment starts here ##########################################

# show some instructions here.
msg = visual.TextStim(win, text = 'Camera calibration!', color = 'black', units = 'pix')
msg.draw(); win.flip()
event.waitKeys()

# set up the camera and calibrate the tracker at the beginning of each block
tk.doTrackerSetup()

# run a block of trials
testList = trials[:]*1 # construct the trial list
random.shuffle(testList) # randomize the trial list
# Looping through the trial list
for t in testList: 
    runTrial(t)

# Get the EDF data and say goodbye
msg.text='Bye bye'
msg.draw(); win.flip()
tk.setOfflineMode()
tk.receiveDataFile(dataFileName, dataFolder + dataFileName)

#close the link to the tracker
pylink.closeGraphics()
win.close()
tk.close()
