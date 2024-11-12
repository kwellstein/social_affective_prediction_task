"""
Class for getting heartrate data with threading
Calls on adaptation of Micah's Systole on Github (https://github.com/embodied-computation-group/systole)
Nonin8600FO outputs analog PPG, which Bryan's box downsamples to 100Hz
Continuously writes outputs to output _ppg.csv
    Prints the following:
    1) timestamp in globalClock
    2) PPG data point
    3) number of PPG data points corresponding to one loop (and one timestamp). Ensure <3..
    4) time taken for readInWaiting. Ensure small.
Optionally provides true or false audio heartrate feedback,for FF1 task
If FB=True, whenever self.recentBPM is called, takes recent PPG_SECONDS=5s of PPG recording, upsamples to 1000hz,
finds peaks, calculates HR, and changes the audio tone feedback rate depending on FBmultiplier (as gradually MAXCHANGERR) allows. Also writes feedback tone onset times in _FB.csv.
self.recentBPM is automatically called when there are enough recording samples, so that feedback will automatically start
"""

import threading, serial, sys, random, time, os, csv, numpy as np

pc="home"
if pc=="laptop":
    sys.path.append('C:\\Users\\c3343721\\Google Drive\\PhD\\Project_Heartrate\\Code')
elif pc=="home":
    sys.path.append('C:\\Users\\Jayson\\Google Drive\\PhD\\Project_Heartrate\\Code')
from mysystole.recording import Oximeter #Adaptation of Micah's Systole on Github
from mysystole.detection import oxi_peaks
import psychtoolbox as ptb
from psychopy import prefs
prefs.hardware['audiolib']=['PTB']


from psychopy import core, visual, gui, data, event, logging, sound

class asyncHeartRate:
    def __init__(self,baudrate,port,clock,filename, FB=True,PPG_SECONDS=5,
                 MAX_SIZE=5*60*100,FBmultiplier=1.0,text=False,
                 HRcutoff=[40,110],MAXCHANGERR=999,volume=1.0):
        #baudrate: integer (for MAX) or False (for Nonin)
        #port: COM4 when plugging directly into laptop, COM3 otherwise
        #clock: a core.Clock
        #filename: a file prefix to save PPG data
        #FB: True by default for audio feedback. False for no feedback
        #PPG_SECONDS is how many seconds of PPG signal to average to find heartrate
        #After MAX_SIZE datapoints, do setup() and save to .csv. Will lose 1 datapoint for every setup
        #FBmultiplier is ratio between feedback heartrate and actual heartrate (default 1)
        #text is Psychopy TextStim when HR not in HRcutoff range
        #HRcutoff: min/max heart-rates allowed
        #MAXCHANGERR: even if targetRR changes by large amount, allow RR to change by only this fraction at each heartbeat
        self.SFREQ=100
        self.NEW_SFREQ=1000 #resampling freq of oxi_peaks
        
        if FB:
            self.tick=sound.Sound(550,secs=0.25,volume=volume) #heartbeat sound

        self.clock=clock
        self.filename=filename
        self.FB=FB
        self.PPG_SECONDS=PPG_SECONDS
        self.MAX_SIZE=MAX_SIZE #currently inactive
        self.FBmultiplier=FBmultiplier
        self.text=text
        self.HRcutoff=HRcutoff
        self.MAXCHANGERR=MAXCHANGERR #maximum RR change after single beat, as a ratio
        
        if baudrate: self.ser=serial.Serial(port,baudrate)
        else: self.ser=serial.Serial(port)
        self.oxi=Oximeter(serial=self.ser,sfreq=self.SFREQ)
        
        self.ppgfile=open(filename+'_ppg.csv','a',newline='') #save PPG here
        self.ppgwriter=csv.writer(self.ppgfile)
        self.ppgwriter.writerow(['time','PPG','nread','tReadInWaiting'])

        if self.FB:
            self.FBfile=open(filename+'_FB.csv','a',newline='') #save feedback times here
            self.FBwriter=csv.writer(self.FBfile)
            self.FBwriter.writerow(['time'])
        
        self.nwritten=0 #index of PPG signal written to writer so far
        self.n=0 #index of PPG signal recorded so far
        self.read_lock=threading.Lock()
        self.started=False
        self.firstBPM=False #whether we have estimated participant BPM at least once since starting
        self.haveBPM=0 #1 if we have a recent BPM (inside HRcutoff)
        
        self.FBtimes=[] #stores times that feedback sound was played
        self.lastFB=0 #time of last feedback
        self.currRR=0 #current RR presented back to pt
        self.targetRR=0 #in seconds


    def start(self,read_duration=0):
        self.started=True
        self.tstart=self.clock.getTime()
        self.oxi.setup(read_duration=read_duration)
        self.thread=threading.Thread(target=self.update,args=())
        self.thread.start()
        return self

    def update(self):
        while self.started:
            if self.FB and not(self.firstBPM) and self.n > self.SFREQ*(self.PPG_SECONDS+1):
                #the first time we get enough datapoints, calculate BPM and start ticks
                self.recentBPM()
                
            self.t0=self.clock.getTime() #XXX
            self.oxi.readInWaiting() #read oximeter
            timenow=self.clock.getTime()
            self.n=len(self.oxi.recording) #no. of datapoints recorded
            for j in range(self.nwritten,self.n): #write to .csv file
                self.ppgwriter.writerow([timenow,self.oxi.recording[j],self.n-self.nwritten,timenow-self.t0])
                #each recording occured BEFORE the 'timenow' that is saved
            self.nwritten=self.n #no. of datapoints written to .csv file
            self.t1=self.clock.getTime() #XXX
                
            if self.FB and self.haveBPM and timenow-self.lastFB > self.currRR:
                print(f"time {timenow:.1f}s. {timenow-self.t0:.3f}s to read. {self.t1-timenow:.3f}s to write")
                #if it's been too long since self.lastFB, play audio feedback
                #print('currbpm %.3f, targetbpm %.3f' % (60/self.currRR,60/self.targetRR))
                self.tick.stop()
                self.tick.play()
                self.FBtimes.append(timenow)
                self.FBwriter.writerow([timenow])
                self.lastFB=timenow
                if self.targetRR > self.currRR: #move currRR towards targetRR
                    self.currRR=min(self.targetRR,self.currRR*self.MAXCHANGERR)
                elif self.targetRR < self.currRR:
                    self.currRR=max(self.targetRR,self.currRR/self.MAXCHANGERR)
                
    def stop(self):
        self.started=False
        self.thread.join()
        self.tend=self.clock.getTime()
        self.ppgfile.close()
        if self.FB:
            self.FBfile.close()

    def recentBPM(self):
        #Takes prev 5 seconds of oxi.recording, finds peaks in prev 4 sec, then returns mean BPM
        ##consider clipping=True, and ensuring not outside HR_cutoff
        with self.read_lock:
            assert(self.n > self.SFREQ*(self.PPG_SECONDS+1))
            self.signal=self.oxi.recording[-self.SFREQ*(self.PPG_SECONDS+1):]
            self.signal2,self.peaks=oxi_peaks(self.signal,sfreq=self.SFREQ,new_sfreq=self.NEW_SFREQ,clipping=False)
            self.bpms=self.NEW_SFREQ*60/np.diff(np.where(self.peaks[-self.NEW_SFREQ*self.PPG_SECONDS:])[0])
            if not(np.any(self.bpms < self.HRcutoff[0]) or np.any(self.bpms > self.HRcutoff[1])) and len(self.bpms)>=1:
                #if all the RR intervals are in acceptable heart-rate range and there is at least 1 bpm value
                if self.haveBPM==0:
                    self.haveBPM=1
                    print('HR detection restored')
                if len(self.bpms)>1:
                    self.bpm=self.bpms.mean() #mean of each BPM (one for each RR interval)
                elif len(self.bpms)==1:
                    self.bpm=self.bpms[0]
                self.targetbpm=self.bpm*self.FBmultiplier
                self.targetRR=60/self.targetbpm #target duration between notes (s)
                if not(self.firstBPM):
                    self.currRR=self.targetRR
                    self.firstBPM=True
            else: #if calculated RR outside accepted range (usually due to movement)
                if self.haveBPM==1:
                    self.haveBPM=0
                    print('HR not detected due to movement')
                if len(self.bpms)==0:
                    print("0 bpms, %i peaks" % sum(self.peaks))
                    
            if self.haveBPM:
                if self.text:
                    self.text.setAutoDraw(False)
            else:
                if self.text==False:
                    print('Please keep your fingers still')
                else:
                    self.text.setAutoDraw(True)

    

if __name__=="__main__":
    filename='thisdata'
    device="MAX" #device: options "MAX" for MAX30100, or "Nonin"
    if device=="MAX": baudrate=115200
    elif device=="Nonin": baudrate=False #baudrate empty
    globalClock=core.Clock()

    
    x=asyncHeartRate(baudrate,'COM3',globalClock,filename,FB=True,
                     PPG_SECONDS=5,FBmultiplier=1.0)
    x.start(read_duration=0)
    core.wait(1200)
    """
    for i in range(5):
        x.FBmultiplier={1.3:1.0,1.0:1.3}[x.FBmultiplier]
        print(x.FBmultiplier)
        x.recentBPM()
        core.wait(5)
    """
    x.stop()
    

    
        
