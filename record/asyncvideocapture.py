"""
Scripted by Jayson Jeganathan
Adapted from https://github.com/gilbertfrancois/video-capture-async
Saves webcam video using threading
Gets around problem of cv2.VideoCapture.read being a blocking read
Saves as .avi with predefined 30fps regardless of actual webcam framerate
So if webcam outputs 16fps, resulting video will look sped up
However, OpenFace output on that video will be same as using actual fps,
    except that timestamps will need to be modified using cam.tstart, cam.tend and cam.nframes
Choice of codec causes lossy compression. Saved video seems to have one less frame than nframes or allframes
Pls check whether webcam resolution matches width=1280 and height=720
"""

import threading
import cv2
from psychopy import core

class VideoCaptureThreading:
    def __init__(self, mydir,src=0, clock=core, fps=30, width=1280, height=720):
        self.src = src
        self.cap = cv2.VideoCapture(self.src,cv2.CAP_DSHOW) #cv2.CAP_DSHOW for Logitech c720, cv2.CAP_ANY for Hypercam
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
        self.cap.set(cv2.CAP_PROP_FPS,fps)
        self.grabbed, self.frame = self.cap.read()
        self.started = False
        self.read_lock = threading.Lock()
        self.mydir=mydir #directory to save .avi
        self.clock=clock
        self.targetfps=fps #save at targetfps of 30fps
        self.fourcc = cv2.VideoWriter_fourcc(*'XVID')
        
        #other options are MJPG(motion jpeg) DIVX H264 XVID RGBA(for uncompressed)
        self.out = cv2.VideoWriter(mydir+'_%ifps.avi' % fps,self.fourcc, fps, (width, height))
        self.allframes=[]
        

    def set(self, var1, var2):
        self.cap.set(var1, var2)

    def start(self):
        if self.started:
            print('[!] Threaded video capturing has already been started.')
            return None
        self.started = True
        self.thread = threading.Thread(target=self.update, args=()) #continually run self.update
        self.thread.start()
        self.nframes=0
        self.tstart=self.clock.getTime()
        return self

    def update(self):
        while self.started:
            grabbed, frame = self.cap.read() #get webcam frame
            with self.read_lock:
                self.grabbed = grabbed
                self.frame = frame
            self.out.write(frame) #write to .avi
            self.nframes+=1
            #self.allframes.append(frame) #this could take too long if video > 5mins. Only needed for recode

    def read(self):
        with self.read_lock:
            frame = self.frame.copy()
            grabbed = self.grabbed
        return grabbed, frame

    def stop(self):
        self.started = False
        self.out.release()
        self.thread.join()
        self.tend=self.clock.getTime()
        self.duration=self.tend-self.tstart
        self.actualfps=self.nframes/self.duration
        print("%i frames in %.4f sec\nTarget fps: %.3f, Actual fps: %.3f" % \
              (self.nframes,self.duration,self.targetfps,self.actualfps))

    def recode(self):
        #after getting all video frames, calculate actual fps as nframes/duration, and save video (takes time)
        #if you're going to use this, uncomment "self.allframes.append(frame)" in function self.update
        print("Recoding video")
        t0=self.clock.getTime()
        fourcc = cv2.VideoWriter_fourcc(*'XVID')
        out = cv2.VideoWriter(self.mydir+'actualfps.avi',fourcc, self.actualfps, (1280, 720))
        for i in self.allframes:
            out.write(i)
        out.release()
        print("Recoding took %.4f sec" % (self.clock.getTime()-t0))
    
    def __exit__(self, exec_type, exc_value, traceback):
        self.cap.release()

if __name__=="__main__":
    mydir="C:\\Users\\Jayson\\Google Drive\\PhD\\MyCode\\Psychopy\\pics\\"
    pc="laptop"
    if pc=="home":
        prefix="C:\\Users\\Jayson\\Google Drive\\PhD\\MyCode\\Psychopy\\"
    elif pc=="laptop":
        prefix="C:/Users/c3343721/Google Drive/PhD/MyCode/Psychopy/"
    mydir=prefix+"pics/test"
    cam=VideoCaptureThreading(mydir,0,core,30,1280,720)

    cam.start()
    t0=core.getTime()
    while core.getTime()-t0 <2:
        continue
    cam.stop()
    print(cam.targetfps,cam.tstart,cam.tend,cam.nframes)
    del(cam)
