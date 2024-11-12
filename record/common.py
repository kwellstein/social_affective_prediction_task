"""
Common functions and variables for all tasks
"""

#Imports
import os, PIL, numpy as np
from psychopy import core, logging, visual,data, monitors, event, gui

#Variables
dict_screensize={"Scanner_Computer":(1920,1080),"EEGLab_Computer":(1920,1080),"laptop":(1000,600),"home":(1400,900)} #Showy's has to be actual size (1920,1080) for Eyelink
dict_gamma={"Scanner_Computer":1.8260829,"EEGLab_Computer":1,"laptop":1,"home":1} #Showy calculated in LuminanceTest.py to be 1.8260829
dict_fixationbufferseconds={'Task':10,'Test':2,'Practice':2}
SCREEN=1
SCREEN_STIMMY_DEFAULT=1 #if pc is Stimmy, defaults to 0
WEBCAM=0
WEBCAM_DIM= [800,600] #  #default [1280,720], [640,480] [1920,1080], [800,600] [960,720]
fps=20 #default 30



FULL_SCREEN=False #For Eyelink, need this to be False
heart_device="Nonin" #options "MAX" for MAX30100, or "Nonin"
heart_port='COM3' #COM4 when plugging directly into laptop, COM3 otherwise
MYHEIGHT=0.08 #text size
FIX_SMALL=[0.01,0.015] #fixation dot size
FIX_BIG=[0.03,0.03]

GAMMA=1
INVGAMMA=1
GREY=0

""" MAY NOT BE NEEDED
Current setup:
    EEG booth: 'L' hand means buttons 'a' and 'b'. 'R' hand means buttons 'f' and 'g'
    fMRI: 'L' hand means buttons 1 and 2. 'R' hand also uses buttons 1 and 2.
If left hand is being used for buttonbox 'L', then 'left' or 'middle finger' button is 'a' or '1'
KEY_spacebar is used by common.awaitPulse and many tasks
KEYS_MAPPING is used by FF1, cface1, and myHRD
"""
KEY_spacebar='d' #default 'space'
KEYS_MAPPING={'L':{'left':['a','1'],'right':['b','2'],
                   'middle':['a','1'],'index':['b','2']
                   },
              'R':{'left':['f','1'],'right':['g','2'],
                   'index':['f','1'],'middle':['g','2']
                   }}
KEYS_allowed={'left':'left','right':'right','index':'left','middle':'right'} 

#Functions
def mygamma(value, minValue=-1):
    """
    Convert value to new value according to gamma function
    minValue=-1 if value is taken from [-1,1]
    minValue=0 if value is taken from [0,1]
    """
    global INVGAMMA
    if minValue==-1:
        value=(value+1)/2    
    result = (value**INVGAMMA)
    if minValue==-1:
        result=(result*2)-1
    return result

def renormalize(n, range1, range2):
    delta1 = range1[1] - range1[0]
    delta2 = range2[1] - range2[0]
    return (delta2 * (n - range1[0]) / delta1) + range2[0]

def set_FIXATION_BUFFER_SECONDS(expInfo):
    #If Face is 'Y' then we are outside scanner. Don't need long fixation
    if 'Face' in expInfo.keys() and expInfo['Face']=='Y':
        return 2
    else:
        return dict_fixationbufferseconds[expInfo['Configuration']]

## USED IN record.py!
def make_expInfo(expName,otherSettings): 
    #add following default settings to expInfo
    expInfo={}
    expInfo['Participant ID']=''
    expInfo['Configuration']=['Test','Task','Practice']
    expInfo['pc']=['EEGLab_Computer','Scanner_Computer','home','laptop']
    expInfo.update(otherSettings)

    items={'fMRI':'M','Heart':'H','Face':'F','Eye':'E','Button':'B'} #contains recording modalities, and their code (for save file name)
    #set up order that settings are displayed in GUI
    order=['Participant ID','pc','Configuration']
    for item in items.keys():
        if item in expInfo.keys():
            order.append(item)
    
    dlg = gui.DlgFromDict(dictionary=expInfo,order=order) #get settings from User
    expInfo['Name']= expName
    expInfo['date'] = data.getDateStr()  # add a simple timestamp

    global KEYS_MAPPING
    global KEYS_allowed
    if 'Button' in expInfo.keys():
        KEYS_allowed=KEYS_MAPPING[expInfo['Button']]
    
    if expInfo['pc']=='EEGLab_Computer':
        global SCREEN
        global SCREEN_STIMMY_DEFAULT
        SCREEN=SCREEN_STIMMY_DEFAULT
    
    #make filename
    name='%s_%s_%s_' % (expName,expInfo['Participant ID'],expInfo['Configuration'][0:2])
    for item in items.keys(): #add recording modalities to filename
        if item in expInfo.keys() and expInfo[item]=='Y':
            name+=items[item]
    if 'Button' in expInfo.keys():
        name+='b'+expInfo['Button']

    name+='_'
    return [expInfo,name]


## USED IN record.py!
def make_savefolder(savedir_name):
    """
    savedir_name is for eg 'FaceGNGV3_s_Test_HYMNBLfgf_2021_Jun_15_2034'
    Makes file path for save directory 'savedir'
    Makes prefix which is this filepath + savedir_name
    """
    savedir = 'data' + os.path.sep + savedir_name +os.path.sep
    prefix=savedir+savedir_name
    if os.path.exists(savedir):
        from shutil import rmtree
        rmtree(savedir) #remove folder savedir if it already exists
    os.mkdir(savedir)
    return [savedir,prefix]

def getStimulusFolder(expInfo):
    """Stimuli contained in specific folder depending on which PC is being used"""
    pc=expInfo['pc']
    if pc=="home":
        folder="D:\\FORSTORAGE\\MY_STIMULI\\"
    elif pc=="laptop":
        folder="C:\\Users\\c3343721\\Desktop\\FaceThings\\MY_STIMULI\\"
    elif pc in ['Scanner_Computer','EEGLab_Computer']:
        topdirs=["E","D"] #prefix will be E or D depending on which computer
        for topdir in topdirs:
            thisfolder=topdir+":\\ShowyTest\\PythonTasks\\MY_STIMULI\\"
            if os.path.exists(thisfolder): folder=thisfolder 
    return folder

def initialSetup(prefix,expInfo):
    pc=expInfo['pc']
    logFile = logging.LogFile(prefix+'.log', level=logging.INFO)
    logging.console.setLevel(logging.WARNING)
    globalClock=core.Clock()
    targetTime=0
    logging.setDefaultClock(globalClock) #syncs logging and win.flips to globalClock
    
    exp = data.ExperimentHandler(name=expInfo['Name'], version='',
        extraInfo=expInfo, runtimeInfo=None,
        savePickle=True, saveWideText=True,
        dataFileName=prefix)

    global GAMMA
    global INVGAMMA
    global GREY
    GAMMA=dict_gamma[pc]
    INVGAMMA=1/GAMMA
    GREY=mygamma(0)

    SCREEN_SIZE=dict_screensize[pc]
    mon = monitors.Monitor('myMac15', width=70.5, distance=151.4)
    #I set width based on Megan email, and distance as average of 'mirror to top of monitor and mirror to bottom of monitor'
    mon.setSizePix(SCREEN_SIZE)      
    
    win = visual.Window(size=SCREEN_SIZE, screen=SCREEN, fullscr=FULL_SCREEN, monitor=mon, units='norm',color=GREY)
 
    return win,exp,globalClock,targetTime

def getImage(win,filepath,size):
    """
    filepath: complete file path of image file
    size of imagefile e.g. array([.8,1.2])
    Outputs gamma-corrected ImageStim of the image
    """
    image2 = PIL.Image.open(filepath)
    image3 = np.array(image2,dtype=float)
    image4=renormalize(image3,[0,256],[-1,1]) #change to range [-1,1]
    global INVGAMMA
    image5=np.array([mygamma(value) for value in image4])        
    return visual.ImageStim(win=win,image=image5,flipVert=True,size=size)        

def awaitPulse(text,win,expInfo,globalClock):
    text.draw() #draw instructions
    win.flip()
    print("TASK: AWAITING PULSE")
    if 'fMRI' in expInfo.keys() and expInfo['fMRI']=='Y':
        event.waitKeys(keyList='5')
    else:
        event.waitKeys(keyList='space')
    globalClock.reset()
    print("TASK STARTED")

def setupFace(prefix,globalClock):
    #save entire facial video
    global fps
    from asyncvideocapture import VideoCaptureThreading
    cam=VideoCaptureThreading(prefix+'_cam',WEBCAM,globalClock,fps,WEBCAM_DIM[0],WEBCAM_DIM[1])
    return cam

def setupHeart(prefix,globalClock):
    from asyncHeartRate import asyncHeartRate
    #Consider doing setup() after 5 mins of recording (will lose 1 datapoint for every setup()
    if heart_device=="MAX": baudrate=115200
    elif heart_device=="Nonin": baudrate=False #baudrate empty
    X=asyncHeartRate(baudrate,heart_port,globalClock,prefix,FB=False)
    return X

def drawnow(win,image,image2=0,duration=0):
    #function to draw text or image
    if isinstance(duration,int) or isinstance(duration,float):
        if duration==0: #if duration is 0, show image without flipping back to blank screen
            image.draw()
            if image2: image2.draw()
            win.flip()
        else:      #show image for duration seconds
            timer=core.Clock()
            while timer.getTime()<duration:
                image.draw()
                if image2: image2.draw()
                win.flip()
    elif isinstance(duration,list): #if duration is a list of valid keypresses, show image until keypress
        event.clearEvents()
        image.draw()
        if image2: image2.draw()
        win.flip()
        return getkeypress(duration) #return the key that was pressed

#function to print some text:
def drawtext(win,string,image2=0,duration=0,height=0.05,pos=(0,0),pos2=(0,0)):
    """Also draws Imagestim 'image2'"""
    textobj = visual.TextStim(win,text=string,pos=pos,height=height)
    return drawnow(win,textobj,image2=image2,duration=duration)

def MYdrawtill(globalClock,stim,TIME_SECONDS,stim2=0,stim3=0):
    """
    draw stim until globalClock reaches targetTime+TIME_SECONDS
    """
    global targetTime
    targetTime+=TIME_SECONDS
    onsetTime=0
    if stim2: stim2.setAutoDraw(True)
    if stim3: stim3.setAutoDraw(True)
    stim.setAutoDraw(True)
    while globalClock.getTime() < targetTime:
        if not(onsetTime):
            onsetTime=win.flip()
        else:
            win.flip()
    stim.setAutoDraw(False)
    if stim2: stim2.setAutoDraw(False)
    if stim3: stim3.setAutoDraw(False)
    return onsetTime

def getkeypress(validkeys):
    #waits for keypress in list of valid keys, and returns the pressed key
    event.clearEvents()
    thisResp=None
    while thisResp==None:
        allKeys=event.waitKeys()
        for thisKey in allKeys:
            if thisKey in validkeys:
                return thisKey
                thisResp=1
        event.clearEvents()

"""
The following functions written by Jayson Jeganathan, adapted from psychopyEyelink_GenericJJ, which itself was adapted from video_psychopy_New3
"""
def initialiseEyeLink(win,filename,expInfo):
    # If in Dummy Mode, press ESCAPE to skip calibration/validataion. Also, will not be full-screen
    dummyMode=False
    
    instructions='Researcher: Press enter to start calibration'
    text = visual.TextStim(win=win, text=instructions,
        height=0.08, color='white')
    text.draw()
    win.flip()

## AMEND PATHS!
    pc=expInfo['pc']
    import sys
    if pc in "Scanner_Computer":
        #sys.path.append("C:\\Users\\hmri\\Documents\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
        sys.path.append("D:\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
        sys.path.append("D:\\EyeLink_Training\\Psychopy2_video\\")
    elif pc in "EEGLab_Computer":
        sys.path.append("D:\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
        sys.path.append("D:\\EyeLink_Training\\Psychopy2_video\\")
    import pylink
    from EyeLinkCoreGraphicsPsychoPy import EyeLinkCoreGraphicsPsychoPy
    if not dummyMode:
        tk = pylink.EyeLink('100.1.1.1')
    else:
        tk = pylink.EyeLink(None)

    dataFolder=os.getcwd()+os.path.sep+filename+os.path.sep
    dataFileName=expInfo['Participant ID']+'.EDF'
    print(filename)
    print(expInfo)
    print(pc)
    print(dataFolder)
    print(dataFileName)
    tk.openDataFile(dataFileName) #must be < 8 chars
    genv = EyeLinkCoreGraphicsPsychoPy(tk, win)
    pylink.openGraphicsEx(genv)
    win.units='norm' #reinstate

    tk.setOfflineMode()
    # sampling rate
    tk.sendCommand('sample_rate 1000') 
    # 0-> standard, 1-> sensitive [Manual: section ??]
    tk.sendCommand('select_parser_configuration 0') 
    # make sure the tracker knows the physical resolution of the subject display
    tk.sendCommand("screen_pixel_coords = 0 0 %d %d" % (win.size[0]-1, win.size[1]-1))
    # stamp display resolution in EDF data file for Eyelink Data Viewer integration
    tk.sendMessage("DISPLAY_COORDS = 0 0 %d %d" % (win.size[0]-1, win.size[1]-1))
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
    tk.doTrackerSetup() #in Eyelink.py within the Eyelink library. Press Escape to exit this
    return [tk,dataFolder,dataFileName]

def startRecordingEyeLink(tk):
    tk.sendMessage('SyncPulseReceived')
    #could remove, start
    tk.setOfflineMode()
    tk.sendCommand('clear_screen 0') # clear the host display
    tk.sendCommand('draw_box 860 440 1060 640 7') # draw box on host display
    tk.setOfflineMode() # take the tracker offline
    #could remove, end
    error = tk.startRecording(1,1,1,1)
    return tk

def endRecordingEyeLink(tk,dataFolder,dataFileName):
    tk.sendMessage('End Study')
    tk.stopRecording()
    tk.setOfflineMode()
    tk.receiveDataFile(dataFileName, dataFolder+dataFileName)
    import pylink
    pylink.closeGraphics()
    tk.close()


    
    

