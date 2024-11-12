"""
Gets Eyelink eye tracker screen onto the BOLDscreen so that you can manually adjust the eye tracker easily
When you're done, just close the program
"""

from psychopy import visual
import common

win = visual.Window(size=(1200,800), screen=1, fullscr=False, units='norm',color=(0,0,0))
win.flip()
expInfo={'pc':'showy','Participant ID': 'eyetest'}
[tk,dataFolder,dataFileName]=common.initialiseEyeLink(win,'eyetest',expInfo)
tk=common.startRecordingEyeLink(tk)
