pc="laptop"
dummyMode = True 

import sys, csv
if pc in ["home","showy"]:
    #sys.path.append("C:\\Users\\hmri\\Documents\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
    sys.path.append("E:\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
elif pc=="laptop":
    sys.path.append("D:\\EyeLink_Training\\pylink_forPython3.4-3.6_win\\pylink_forPython3.6_x64\\")
import pylink
import numpy, os, random
from EyeLinkCoreGraphicsPsychoPy import EyeLinkCoreGraphicsPsychoPy

if not dummyMode:
    tk = pylink.EyeLink('100.1.1.1')
else:
    tk = pylink.EyeLink(None)

tk.openDataFile('testfile.EDF')
tk.sendCommand("add_file_preamble_text 'Psychopy GC demo'") # add personalized header (preamble text)
tk.closeDataFile()
tk.receiveDataFile('testfile.EDF', 'testfile.EDF')
