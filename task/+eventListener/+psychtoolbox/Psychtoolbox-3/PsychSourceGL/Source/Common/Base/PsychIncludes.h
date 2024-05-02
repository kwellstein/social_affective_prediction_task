/*
  Psychtoolbox3/Source/Common/PsychIncludes.h

  AUTHORS:

  Allen.Ingling@nyu.edu         awi
  mario.kleiner.de@gmail.com    mk

  PLATFORMS: All

  PROJECTS: All

  HISTORY:
  07/16/02  awi         Pulled out of PsychPlatform.h
  11/15/02  awi         Added includes for OSX.

  DESCRIPTION:

  PsychIncludes.h includes all C, system, and language binding
  header files which a Psychtoolbox library would require.

  This file should ONLY be included by PsychConstants.h

*/

#ifndef PSYCH_IS_INCLUDED_PsychIncludes
#define PSYCH_IS_INCLUDED_PsychIncludes

#include "PsychPlatform.h"

// This is needed for compiling with gcc 4.6+ if -std=gnu99
// is set, which we need to set for OML_sync_control support
// and other features. Fixes compile failure on Ubuntu 12.10:
// NOTE: Does not seem to be needed anymore as of Ubuntu 18.04 at least,
// but for the moment we just disable it under C++ builds, where it errros.
#ifndef __cplusplus
#if defined(__STDC_UTF_16__) && !defined(CHAR16_T) && (PSYCH_SYSTEM == PSYCH_LINUX)
typedef __CHAR16_TYPE__ char16_t;
#endif
#endif

// Includes dependent on runtime environment:
#if PSYCH_LANGUAGE == PSYCH_MATLAB
    // Include File with Matlab interface API definitions:
    #include "mex.h"
#endif

#if PSYCH_LANGUAGE == PSYCH_PYTHON
    // Include File with Python API definitions:
    #include <Python.h>
#endif

#if PSYCH_SYSTEM == PSYCH_OSX
// Shut up the OpenGL related deprecation warnings on Apples trainwreck
// before including glew.h:
#define GL_SILENCE_DEPRECATION
#endif

// Platform independent include for glew: This is a catch-all
// for all OpenGL definitions and functions, currently up to
// OpenGL 4.6 + latest extensions beyond that:
#if defined(PTBMODULE_Screen) || defined(PTBMODULE_FontInfo) || defined(PTBMODULE_PsychVulkanCore)
#include "../Screen/GL/glew.h"
#endif

//platform dependent includes stage 1
#if PSYCH_SYSTEM == PSYCH_LINUX
    // We need __USE_UNIX98, so pthread.h defines/supports the mutex policy
    // attribute for mutex priority inheritance for our realtime threads.
    // For some reason this gets undefined in mex.h at least when building
    // on Octave 3.2.4. Scary scary...
    #ifndef __USE_UNIX98
    #define __USE_UNIX98
    // For testing only: #warning __USE_UNIX98 undefined. Redefining it.
    #endif

    // This is the new glew include for GLX extension support:
#if defined(PTBMODULE_Screen)
    #include "../Screen/GL/glxew.h"
#endif

    #include <X11/Xlib.h>
    #include <X11/keysym.h>
    #include <sys/time.h>
    #include <unistd.h>
    #include <stdarg.h>
    #include <pthread.h>
    #include <dlfcn.h>

    #ifndef _POSIX_THREAD_PRIO_INHERIT
    #error This build system does not support pthread_mutexattr_setprotocol(&attr, PTHREAD_PRIO_INHERIT); Fix your build system!
    #endif
#endif

#if PSYCH_SYSTEM == PSYCH_WINDOWS
    // Master include for windows header file:
    #include <windows.h>

    // For building Screen, include wglew.h - Windows specific GLEW header files:
    #if defined(PTBMODULE_Screen)
    #include "../Screen/GL/wglew.h"
    #endif

#elif PSYCH_SYSTEM == PSYCH_OSX
	//includes for Apple OpenGL
    #include <sys/time.h>
	#include <pthread.h>

    // If we are included from PsychScriptingGlue.cc, which
    // is indicated by PTBINSCRIPTINGGLUE, then we must only
    // include MacTypes.h, not the rest of Carbon, ApplicationServices
    // et al. -> Some of the Octave header files conflict with Apple
    // system header files --> do not include the Apple headers when
    // building Scriptingglue - they are not needed but would prevent
    // the build.
    #ifndef PTBINSCRIPTINGGLUE
    // File included during compile of some PTB file other than ScriptingGlue...
    #include <Carbon/Carbon.h>
    #include <CoreServices/CoreServices.h>
    #include <ApplicationServices/ApplicationServices.h>
    #include <CoreAudio/HostTime.h>
    #include <CoreVideo/CoreVideo.h>
    #else
    // File included from ScriptingGlue - only import minimal amount of headers...
    #include <CoreServices/CoreServices.h>
    #endif

    #if defined(PTBMODULE_Screen) || defined(PTBMODULE_FontInfo) || defined(PTBMODULE_PsychVulkanCore)
    #include <OpenGL/OpenGL.h>
    #include <CoreText/CoreText.h>
    #endif
#endif

// C standard library headers:
#include <stdint.h>
#include <math.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <float.h>
#include <stdbool.h>

//end include once
#endif
