"""
DESCRIPTION:
Scripted by Jayson Jeganathan
Save heart rate, face expression in background
"""

#SETTABLE PARAMETERS
TOTAL_SECONDS = 1200
SECONDS_PER_TRIAL = 0.25 #does not save heart if less than 0.25 for some reason
NUM_TRIALS = int(TOTAL_SECONDS / SECONDS_PER_TRIAL)

from psychopy import visual, core, data, event, monitors, logging, gui, constants
import random, time, numpy as np, cv2, pandas as pd, os, common, csv
from datetime import datetime
random.seed(a=1)

task_instructions="To record"

otherSettings={'Heart': ['N','Y'],\
         'Face': ['N','Y'],\
         'Eye': ['N','Y'],\
         'fMRI': ['N','Y'],\
               }
               
[expInfo,savedir_name]=common.make_expInfo('record',otherSettings)
savedir_name+=expInfo['date'] #add video name to savedir

[savedir,prefix]=common.make_savefolder(savedir_name)

globalClock=core.Clock()
globalClock.reset()
starttime = datetime.now()

if expInfo['Face']=='Y': cam=common.setupFace(prefix,globalClock)
if expInfo['Heart']=='Y': X=common.setupHeart(prefix,globalClock)
if expInfo['Eye']=='Y': [tk,dataFolder,dataFileName]=common.initialiseEyeLink(win,savedir,expInfo)

#Make .csv for summary and detailed data
summaryfile=open(prefix+'_summary.csv','a',newline='')
summary=csv.writer(summaryfile)
detailfile=open(prefix+'_detailed.csv','a',newline='')
detail=csv.writer(detailfile)
if expInfo['Face']=='N' and expInfo['Heart']=='Y':
    detail.writerow(['fliptimes','PPGns'])
elif expInfo['Face']=='Y' and expInfo['Heart']=='N':
    detail.writerow(['fliptimes','ptframenums'])
elif expInfo['Face']=='Y' and expInfo['Heart']=='Y':
    detail.writerow(['fliptimes','ptframenums','PPGns'])
elif expInfo['Face']=='N' and expInfo['Heart']=='N':
    detail.writerow(['fliptimes'])

if expInfo['Heart']=='Y':
    X.start()
    print("Recording heart")
if expInfo['Face']=='Y':
    cam.start()
    print("Recording face")
if expInfo['Eye']=='Y':
    tk=common.startRecordingEyeLink(tk)
    print("Recording eye")

"""
#X.start()
for j in range(NUM_TRIALS):
    core.wait(0.25)
    print(f"{j}, {X.n}")
X.stop()
assert(0)
"""

#Show the movie
for i in range(NUM_TRIALS):
    core.wait(SECONDS_PER_TRIAL)
    time_elapsed = globalClock.getTime()
    print(f"{i}/{NUM_TRIALS}, {time_elapsed:.3f}s, {X.n}")
    if i==0:
        time_firstsave = time_elapsed
    if expInfo['Face']=='N' and expInfo['Heart']=='Y':
        detail.writerow([time_elapsed,X.n])
    elif expInfo['Face']=='Y' and expInfo['Heart']=='N':
        detail.writerow([time_elapsed,cam.nframes])
    elif expInfo['Face']=='Y' and expInfo['Heart']=='Y':
        detail.writerow([time_elapsed,cam.nframes,X.n])
    elif expInfo['Face']=='N' and expInfo['Heart']=='N':
        detail.writerow([time_elapsed])
time_lastsave=globalClock.getTime()

print(f'Recorded for {time_lastsave-time_firstsave:.3f} sec')    
detailfile.close() 
summary.writerow(['globalClock_start',str(starttime.time())])
summary.writerow(['time_firstsave',time_firstsave])
summary.writerow(['time_lastsave',time_lastsave])
summary.writerow(['duration_saved',time_lastsave-time_firstsave])
summary.writerow(['TOTAL_SECONDS',TOTAL_SECONDS])
summary.writerow(['NUM_TRIALS',NUM_TRIALS])
summary.writerow(['SECONDS_PER_TRIAL',SECONDS_PER_TRIAL])

if expInfo['Face']=='Y':
    cam.stop()
if expInfo['Face']=='Y':  
    summary.writerow(['camtargetfps',cam.targetfps])
    summary.writerow(['camtstart',cam.tstart])
    summary.writerow(['camtend', cam.tend])
    summary.writerow(['camnframes', cam.nframes])
    summary.writerow(['camactualfps', cam.actualfps]) 
    del(cam)
summaryfile.close()  
if expInfo['Heart']=='Y':
    X.stop()
if expInfo['Eye']=='Y':
    common.endRecordingEyeLink(tk,dataFolder,dataFileName)

print("TASK FINISHED")
core.quit()
