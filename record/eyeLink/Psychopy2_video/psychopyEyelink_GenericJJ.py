######## Psychopy demo with the custom Psychopy Core Graphics
# If you need to use a screen units other than 'pix', which we do not recommend as the gaze coordinates 
# returned by pylink is in 'pix' units, please make sure to properly set the size of the cursor and the
# position of the gaze. However, the calibration/validation routine should work fine regardless of the 
# screen units.

"""
TASK: There are 2 blocks (repeats), each of which has 2 sub-blocks (screen colour), each of which has 5 trials (dot location)
In each trial, a fixation dot is presented on coloured background, and pt looks at it.
Each trial lasts 2s. Each trial has different dot location.
The 2 sub-blocks are white fixation / black background, and the other vice versa.
Total ntrials = 2*2*5 = 20. Total time = 20*2 = 40s
"""

# import libraries
pc="showy"
dummyMode = False # If in Dummy Mode, press ESCAPE to skip calibration/validataion. Also, will not be full-screen
SCREEN = 1 #1 by default, 0 for testing with left screen
myunits='norm' #norm or pix
DRIFTCHECK=False #Do drift correction in every sub-block or not
TRACKERSETUP=True #before task, do we do tracker setup? If not (have done setup already in a previous task), it will default to DriftCheck
trial_duration=1.5 #default 1.5.

import sys, csv
if pc in ["home","showy"]:
    #sys.path.append("C:\\Users\\hmri\\Documents\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
    sys.path.append("E:\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
elif pc=="laptop":
    sys.path.append("D:\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
import pylink
import numpy, os, random
from EyeLinkCoreGraphicsPsychoPy import EyeLinkCoreGraphicsPsychoPy
from psychopy import visual, core, event, gui, monitors, logging

#### STEP I: get simporubject info with GUI ########################################################
expInfo = {'SubjectNO':'00', 'SubjectInitials':'vid'}
dlg = gui.DlgFromDict(dictionary=expInfo, title="GC Example", order=['SubjectNO', 'SubjectInitials'])
if dlg.OK == False: core.quit()  # user pressed cancel

#### STEP II: established a link to the tracker ###############################################
if not dummyMode:
    tk = pylink.EyeLink('100.1.1.1')
else:
    tk = pylink.EyeLink(None)

#### STEP III: Open an EDF data file EARLY ####################################################
dataFolder = os.getcwd() + '/edfData/'
dataFileName = expInfo['SubjectNO'] + '_' + expInfo['SubjectInitials'] + '.EDF'

# Note that for Eyelink 1000/II, he file name cannot exceeds 8 characters
# we need to open eyelink data files early so as to record as much info as possible
tk.openDataFile(dataFileName) #Only outputs a datafile if dummyMode=False
tk.sendCommand("add_file_preamble_text 'Psychopy GC demo'") # add personalized header (preamble text)

#### STEP IV: Initialize custom graphics for camera setup & drift correction ##################
if dummyMode == True:
    scnWidth,scnHeight=(900,900)
    win = visual.Window((scnWidth, scnHeight), fullscr=False, screen=SCREEN, color=[0,0,0], units=myunits)
elif dummyMode == False:
    if SCREEN==1:
        scnWidth, scnHeight = (1920, 1080)
    elif SCREEN==0:
        scnWidth,scnHeight=(900,900)
    mon = monitors.Monitor('myMac15', width=70.5, distance=151.4) #I set width based on Megan email, and distance as average of 'mirror to top of monitor and mirror to bottom of monitor'
    mon.setSizePix((scnWidth, scnHeight))
    win = visual.Window((scnWidth, scnHeight), screen=SCREEN, fullscr=False, monitor=mon, color=[0,0,0], units=myunits)

globalClock=core.Clock()
logging.setDefaultClock(globalClock)
targetTime=0

# this functional calls our custom calibration routin "EyeLinkCoreGraphicsPsychopy.py"
genv = EyeLinkCoreGraphicsPsychoPy(tk, win)
pylink.openGraphicsEx(genv)
win.units=myunits #reinstate

#### STEP V: Set up the tracker ################################################################
# we need to put the tracker in offline mode before we change its configrations
tk.setOfflineMode()
# sampling rate
tk.sendCommand('sample_rate 1000') 
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
pylink.setCalibrationColors((255,255,255), (122,122,122)) #foreground then background, of calibration images
# allow buttons on the gamepad to accept calibration/dirft check target 
tk.sendCommand("button_function 1 'accept_target_fixation'")

# set link and file contents
eyelinkVer = tk.getTrackerVersion()
if eyelinkVer >=3: # Eyelink 1000/1000 plus
    tk.sendCommand("file_event_filter = LEFT,RIGHT,FIXATION,FIXUPDATE,SACCADE,BLINK,MESSAGE,BUTTON,INPUT")
    tk.sendCommand("link_event_filter = LEFT,RIGHT,FIXATION,FIXUPDATE,SACCADE,BLINK,MESSAGE,BUTTON,INPUT")
    tk.sendCommand("file_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HREF,PUPIL,STATUS,INPUT,HTARGET")
    tk.sendCommand("link_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HREF,PUPIL,STATUS,INPUT,HTARGET,BUTTON,")
else: # Eyelink II
    tk.sendCommand("file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT")
    tk.sendCommand("link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,INPUT")
    tk.sendCommand("file_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HREF,PUPIL,STATUS,INPUT")
    tk.sendCommand("link_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HREF,PUPIL,STATUS,INPUT")

msg = visual.TextStim(win, text = 'Look LEFT', color = 'white', units = myunits)
DOTPOS=0.5 #position of the right dot relative to units='norm'
if myunits=='pix':
    dotlocs=[[0,0],[DOTPOS*scnWidth/2,0],[-DOTPOS*scnWidth/2,0],[0,DOTPOS*scnHeight/2],[0,-DOTPOS*scnHeight/2],[0,0]]
    dot = visual.Circle(win,pos=[0,0],radius=[10,10],lineColor='white',fillColor='white')
elif myunits=='norm':
    dotlocs=[[0,0],[DOTPOS,0],[-DOTPOS,0],[0,DOTPOS],[0,-DOTPOS],[0,0]]
    dot = visual.Circle(win,pos=[0,0],radius=[0.02,0.02],lineColor='white',fillColor='white')
dotcols=['white','black']
NBLOCKS = 2
NSUBBLOCKS=len(dotcols)
NTRIALS=len(dotlocs)
file=open('edfData/'+expInfo['SubjectNO'] + '_' + expInfo['SubjectInitials'] + '.csv','a',newline='')
w=csv.writer(file)
w.writerow(['units','block','subblock','trial','dotloc','dotcol','screencol','timestart','timeend'])

def myDriftCheck():
    # drift check
    print("TRYING doDriftCorrect")
    try:
        err = tk.doDriftCorrect(win.size[0]/2, win.size[1]/2,1,1) #default 1,1
        print("Drift correction successful")
    except:
        print("doTrackerSetup")
        tk.doTrackerSetup()

#### STEP VIII: The real experiment starts here ##########################################
# set up the camera and calibrate the tracker at the beginning of each block
msg.text='Researcher: Press Enter to mirror to BOLD screen, then do Calibration, then press Esc to continue'
msg.draw()
win.flip()

if TRACKERSETUP:
    print("Doing Tracker Setup")
    tk.doTrackerSetup() #in Eyelink.py within the Eyelink library
else:
    myDriftCheck()

msg.text='Researcher: Calibration done. Waiting for scanner pulse (or 5)\n\n\n\
Participant: Keep your eyes fixed on the fixation dot'
msg.draw()
win.flip()
event.waitKeys()
tk.sendMessage('SyncPulseReceived')
globalClock.reset()
event.clearEvents()

#Unclear if most of this is necessary
"""
tk.setOfflineMode() # take the tracker offline
#pylink.pumpDelay(50)
tk.sendCommand('clear_screen 0') # clear the host display
tk.sendCommand('draw_box 860 440 1060 640 7') # draw box on host display
tk.sendCommand("record_status_message 'test'") # record_status_message : show some info on the host PC
tk.setOfflineMode() # take the tracker offline
"""
error = tk.startRecording(1,1,1,1)
#pylink.pumpDelay(100) # wait for 100 ms to make sure data of interest is recorded

dot.setAutoDraw(True)
truetrial=0 #tracks number of trials done so far
for block in range(NBLOCKS):
    for subBlock in range(NSUBBLOCKS):
        if DRIFTCHECK and subBlock>0:
            print("New subBlock: Entering DRIFTCHECK")
            tk.setOfflineMode()
            #pylink.pumpDelay(50)
            # clear the host display
            tk.sendCommand('clear_screen 0') 
            # draw box on host display
            tk.sendCommand('draw_box 860 440 1060 640 7')
            # record_status_message : show some info on the host PC
            tk.sendCommand("record_status_message 'test'")

            myDriftCheck()
            
            # start recording
            tk.setOfflineMode()
            #pylink.pumpDelay(50)
            error = tk.startRecording(1,1,1,1)
            #pylink.pumpDelay(100)
            
        for trial in range(NTRIALS):
            truetrial+=1
            dotcol=dotcols[subBlock]
            screencol={'black':'white','white':'black'}[dotcol]
            dot.color=dotcol
            win.color=screencol
            dot.pos=dotlocs[trial]
            win.flip()
            timestart=globalClock.getTime()
            tk.sendMessage('TRIALID ' + str(truetrial))
            targetTime+=trial_duration
            while globalClock.getTime() < targetTime:
                win.flip()
            timeend=globalClock.getTime()
            tk.sendMessage('TRIAL_RESULTS 0')
            print('block %i, subBlock %i, trial %i from time %.3f - %.3f' % (block,subBlock,trial,timestart,timeend))
            w.writerow([myunits,block,subBlock,trial,dot.pos,dotcol,screencol,timestart,timeend])
            
dot.setAutoDraw(False)
win.flip()
tk.sendMessage('End Study')
#pylink.pumpDelay(100)
tk.stopRecording() # stop recording

# Get the EDF data and say goodbye
tk.setOfflineMode()
tk.receiveDataFile(dataFileName, dataFolder+dataFileName)

#close the link to the tracker
file.close()
pylink.closeGraphics()
win.close()
tk.close()
