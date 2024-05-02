/*
    Psychtoolbox-3/PsychSourceGL/Source/Common/Eyelink/EyelinkSendFile.c

    PROJECTS: Eyelink

    AUTHORS:
    brian@sr-research.com   br

    PLATFORMS:

 */

#include "PsychEyelink.h"

 static char useString[] = "[status =] Eyelink('SendFile', src, dest, dest_is_path)";

 static char synopsisString[] =
 "This function sends a file to the Eyelink tracker. Source destination file name\n"
 "should be given. Using this function, an image or video can be uploaded from the\n"
 "display PC to the host Tracker PC.\n\n"
 "<src> Name of local file (including extension).\n"
 "<dest> Name of eye tracker file to write to (including extension).\n"
 "<dest_is_path> If nonzero, appends file name to <dest> as a directory path.\n\n"
 "Returns:\n"
 " size of file if transferred file size is equal to the real file size.\n"
 " -1 if fail to connect tracker ftpd.\n"
 " -2 if fail to open file.\n"
 " -4 if fail to receive reply from tracker ftpd.\n"
 " -5 if transferred file size is unequal to the real file size.";

 static char seeAlsoString[] = "";

 /*
  ROUTINE: EyelinkSendFile
  PURPOSE:
  uses INT32 send_data_file_feedback(char *src, char *dest, INT16 dest_is_path, void(*)(unsigned int size, unsigned int received) progress);
  */

 PsychError EyelinkSendFile(void)
 {
     int iStatus;
     char *src;
     char *dest;
     int dest_is_path;

     // all sub functions should have these two lines
     PsychPushHelp(useString, synopsisString, seeAlsoString);
     if(PsychIsGiveHelp()){
         PsychGiveHelp();
         return(PsychError_none);
     };

     // check to see if the user supplied superfluous arguments
     PsychErrorExit(PsychCapNumInputArgs(3));
     PsychErrorExit(PsychRequireNumInputArgs(3));
     PsychErrorExit(PsychCapNumOutputArgs(1));

     // Verify eyelink is up and running
     EyelinkSystemIsConnected();
     EyelinkSystemIsInitialized();

     PsychAllocInCharArg(1, TRUE, &src);
     PsychAllocInCharArg(2, TRUE, &dest);
     PsychCopyInIntegerArg(3, TRUE, &dest_is_path);

     iStatus = (int) send_data_file_feedback(src, dest, (INT16) dest_is_path, NULL);

     // if there is an output variable available, assign result to it.
     PsychCopyOutDoubleArg(1, FALSE, iStatus);

     return(PsychError_none);
 }
