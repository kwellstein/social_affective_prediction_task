/*
    PsychToolbox3/Source/OSX/Screen/PsychCocoaGlue.c

    PLATFORMS:

    OSX

    TARGETS:

    Screen

    AUTHORS:

    Mario Kleiner       mk      mario.kleiner.de@gmail.com

    DESCRIPTION:

    Glue code for window management using Objective-C wrappers to use Cocoa.
    These functions are called by PsychWindowGlue.c.

    NOTES:

    The setup code for CAMetalLayer makes use of functions only supported on
    OSX 10.11 "El Capitan" and later, so 10.11 is the minimum required version.
*/

#include "Screen.h"
#include "PsychCocoaGlue.h"

#include <ApplicationServices/ApplicationServices.h>
#include <Cocoa/Cocoa.h>
#include <objc/message.h>
#include <QuartzCore/CAMetalLayer.h>

// Suppress deprecation warnings:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

PsychError PsychCocoaCreateWindow(PsychWindowRecordType *windowRecord, int windowLevel, void** outWindow)
{
    char windowTitle[100];
    __block NSWindow *cocoaWindow = NULL;
    __block NSRect clientRect;
    PsychRectType screenRect;
    int screenHeight;

    // Query height of primary screen for y-coord remapping:
    PsychGetGlobalScreenRect(0, screenRect);
    screenHeight = (int) PsychGetHeightFromRect(screenRect);

    // Zero-Init NSOpenGLContext-Pointers for our private Cocoa OpenGL contexts:
    windowRecord->targetSpecific.nsmasterContext = NULL;
    windowRecord->targetSpecific.nsswapContext = NULL;
    windowRecord->targetSpecific.nsuserContext = NULL;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Initialize the Cocoa application object, connect to CoreGraphics-Server:
    // Can be called many times, as redundant calls are ignored.
    DISPATCH_SYNC_ON_MAIN({
        NSApplicationLoad();
    });

    // Include onscreen window index in title:
    sprintf(windowTitle, "PTB Onscreen Window [%i]:", windowRecord->windowIndex);
    NSString *winTitle = [NSString stringWithUTF8String:windowTitle];

    // Define size of client area - the actual stimulus display area:
    // The window itself will resize and reposition itself so that the size of
    // the content area is preserved/honored, adjusting for the thickness of window decorations.
    NSRect windowRect = NSMakeRect(0, 0, (int) PsychGetWidthFromRect(windowRecord->rect), (int) PsychGetHeightFromRect(windowRecord->rect));

    NSUInteger windowStyle = 0;
    if (windowRecord->specialflags & kPsychGUIWindow) {
        // GUI window:
        windowStyle = NSWindowStyleMaskTitled|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskTexturedBackground;
    }
    else {
        // Pure non-GUI visual stimulus window:
        windowStyle = NSWindowStyleMaskBorderless;
    }

    // Some diagnostics wrt. main-thread or not:
    if (PsychPrefStateGet_Verbosity() > 4)
        printf("PTB-DEBUG: PsychCocoaCreateWindow(): On %s thread.\n", ([NSThread isMainThread]) ? "MAIN APPLICATION" : "other");

    DISPATCH_SYNC_ON_MAIN({
        cocoaWindow = [[NSWindow alloc] initWithContentRect:windowRect styleMask:windowStyle    backing:NSBackingStoreBuffered defer:YES];
    });

    if (cocoaWindow == nil) {
        printf("PTB-ERROR: PsychCocoaCreateWindow(): Could not create Cocoa-Window!\n");
        // Return failure:
        return(PsychError_system);
    }

    // External display method in use? Atm. this is only Vulkan via MoltenVK ICD
    // on top of Metal. We need to back our Cocoa NSWindow with a CAMetalLayer for
    // this to work:
    if (windowRecord->specialflags & kPsychExternalDisplayMethod) {
        CAMetalLayer* hostedLayer = [CAMetalLayer layer];
        windowRecord->targetSpecific.deviceContext = hostedLayer;
        [hostedLayer setOpaque:true];

        if (PsychPrefStateGet_Verbosity() > 3)
            printf("PTB-INFO: External display method is in use for this NSWindow. Creating a backing layer as CAMetalLayer %p.\n",
                   hostedLayer);
    }

    DISPATCH_SYNC_ON_MAIN({
        [cocoaWindow setTitle:winTitle];

        if ((windowLevel >= 1000) && (windowLevel < 2000)) {
            // Set window as non-opaque, with a transparent window background color:
            // This together with the OpenGL context setup for transparency allows the OpenGL
            // colorbuffer alpha-channel to determine window opacity at a per-pixel level, so
            // experimental code has full control over transpareny if it wishes so. By default,
            // Screen() clears the backbuffer to an opaque white with alpha 1.0, so by default
            // windows do appear solid, unless usercode explicitely does something else:
            [cocoaWindow setOpaque:false];
            [cocoaWindow setBackgroundColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.0]];
        }
        else {
            [cocoaWindow setOpaque:true];
            [cocoaWindow setBackgroundColor:[NSColor colorWithDeviceWhite:0.0 alpha:1.0]];
        }

        // Make window "transparent" for mouse events like clicks and drags, if requested:
        // For levels 1000 to 1499, where the window is a partially transparent
        // overlay window with global alpha 0.0 - 1.0, we disable reception of mouse
        // events. --> Can move and click to windows behind the window!
        // A range 1500 to 1999 would also allow transparency, but block mouse events:
        psych_bool ignoreMouse = ((windowLevel >= 1000) && (windowLevel < 1500)) ? TRUE : FALSE;
        if (ignoreMouse) [cocoaWindow setIgnoresMouseEvents:true];

        // In non-GUI mode we want the window to be above all other regular windows, so the
        // stimulus doesn't get occluded. If we make ourselves transparent to mouse clicks, we
        // must be above all other windows, as otherwise any mouse-click that "goes through"
        // to an underlying window will raise that window above ours and we get occluded, ie.,
        // any actual passed-through mouse-click would defeat the purpose of pass-through mode:
        if (!(windowRecord->specialflags & kPsychGUIWindow) || ignoreMouse) {
            // Set level of window to be in front of every regular window:
            [cocoaWindow setLevel:NSScreenSaverWindowLevel];
        }

        // Disable auto-flushing of drawed content to frontbuffer:
        [cocoaWindow disableFlushWindow];

        // Position the window unless its position is left to the window manager:
        if (!(windowRecord->specialflags & kPsychGUIWindowWMPositioned)) {
            // Position the window. Origin is bottom-left of screen, as opposed to Carbon / PTB origin
            // of top-left. Therefore need to invert the vertical position. Cocoa only takes our request
            // as a hint. It tries to position as requested, but places the window differently if required
            // to make sure the full windowRect content area is displayed. It doesn't allow the window to
            // overlap the menu bar or dock area by default.
            NSPoint winPosition = NSMakePoint(windowRecord->rect[kPsychLeft], screenHeight - windowRecord->rect[kPsychTop]);
            [cocoaWindow setFrameTopLeftPoint:winPosition];
        }

        // Query and translate content rect of final window to a PTB rect for use as the windows globalRect
        // in global screen space coordinates (unit is points, not pixels - important for Retina/HiDPI):
        clientRect = [cocoaWindow contentRectForFrameRect:[cocoaWindow frame]];

        // Tell Cocoa/NSOpenGL to render to Retina displays at native resolution:
        [[cocoaWindow contentView] setWantsBestResolutionOpenGLSurface:YES];

        // Initial CAMetalLayer attach: Needed here, before window is shown 1st time,
        // or it won't work at all later on -- it would turn into a no-op:
        if (windowRecord->specialflags & kPsychExternalDisplayMethod) {
            if (PsychPrefStateGet_Verbosity() > 4)
                printf("PTB-INFO: External display method is in use for this window. Attaching CAMetalLayer...\n");

            [[cocoaWindow contentView] setWantsLayer:YES];
            [[cocoaWindow contentView] setLayer:windowRecord->targetSpecific.deviceContext];
        }

        //[cocoaWindow setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    });

    PsychMakeRect(windowRecord->globalrect, clientRect.origin.x, screenRect[kPsychBottom] - (clientRect.origin.y + clientRect.size.height), clientRect.origin.x + clientRect.size.width, screenRect[kPsychBottom] - clientRect.origin.y);

    // Drain the pool:
    [pool drain];

    // Return window pointer, packed into an old-school Carbon window ref:
    *outWindow = (void*) cocoaWindow;

    // Return success:
    return(PsychError_none);
}

psych_bool PsychCocoaMetalWorkaround(PsychWindowRecordType *windowRecord)
{
    __block NSWindow *cocoaWindow;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Define size of client area - the actual stimulus display area:
    NSRect windowRect = NSMakeRect(0, 0, (int) PsychGetWidthFromRect(windowRecord->rect), (int) PsychGetHeightFromRect(windowRecord->rect));

    DISPATCH_SYNC_ON_MAIN({
        cocoaWindow = [[NSWindow alloc] initWithContentRect:windowRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
    });

    if (cocoaWindow == nil) {
        printf("PTB-ERROR: PsychCocoaMetalWorkaround(): Could not create Metal workaround temporary Cocoa-Window!\n");
        return(FALSE);
    }

    DISPATCH_SYNC_ON_MAIN({
        // Initial CAMetalLayer attach: Needed before window is shown 1st time:
        [[cocoaWindow contentView] setWantsLayer:YES];
        [[cocoaWindow contentView] setLayer:windowRecord->targetSpecific.deviceContext];

        // Show window:
        [cocoaWindow orderFrontRegardless];
        [cocoaWindow display];

        // Then immediately close it:
        [[cocoaWindow contentView] setWantsLayer:NO];
        [[cocoaWindow contentView] setLayer:NULL];
        [cocoaWindow close];
    });

    // Drain the pool:
    [pool drain];

    return(TRUE);
}

void PsychCocoaGetWindowBounds(void* window, PsychRectType globalBounds, PsychRectType windowpixelRect)
{
    PsychRectType screenRect;
    double screenHeight;

    // Query height of primary screen for y-coord remapping:
    PsychGetGlobalScreenRect(0, screenRect);
    screenHeight = PsychGetHeightFromRect(screenRect);

    NSWindow* cocoaWindow = (NSWindow*) window;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    DISPATCH_SYNC_ON_MAIN({
        // Query and translate content rect of final window to a PTB rect:
        NSRect clientRect = [cocoaWindow contentRectForFrameRect:[cocoaWindow frame]];

        globalBounds[kPsychLeft]   = clientRect.origin.x;
        globalBounds[kPsychRight]  = clientRect.origin.x + clientRect.size.width;
        globalBounds[kPsychTop]    = screenHeight - (clientRect.origin.y + clientRect.size.height);
        globalBounds[kPsychBottom] = globalBounds[kPsychTop] + clientRect.size.height;

        // Compute true size - now in pixels, not points - of window backbuffer as windows rect:
        NSSize backSize = [[cocoaWindow contentView] convertSizeToBacking: clientRect.size];
        PsychMakeRect(windowpixelRect, 0, 0, backSize.width, backSize.height);
    });

    // Drain the pool:
    [pool drain];
}

pid_t GetHostingWindowsPID(void)
{
    pid_t pid = (pid_t) 0;
    CFIndex i;
    CFNumberRef numRef;
    char winName[256];
    psych_bool found = FALSE;
    psych_bool verbose = (PsychPrefStateGet_Verbosity() > 5) ? TRUE : FALSE;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    if (!windowList) goto hwinpidout;	

    const CFIndex kSize = CFArrayGetCount(windowList);

    for (i = 0; i < kSize; ++i) {
        CFDictionaryRef d = (CFDictionaryRef) CFArrayGetValueAtIndex(windowList, i);

        // Get process id pid of window owner:
        numRef = (CFNumberRef) CFDictionaryGetValue(d, kCGWindowOwnerPID);
        if (numRef) {
            int val;
            CFNumberGetValue(numRef, kCFNumberIntType, &val);
            pid = (pid_t) val;
            if (verbose) printf("OwnerPID: %i\n", val);
        }

        numRef = (CFNumberRef) CFDictionaryGetValue(d, kCGWindowLayer);
        if (numRef) {
            int val;
            CFNumberGetValue(numRef, kCFNumberIntType, &val);
            if (verbose) printf("WindowLevel: %i  (ShieldingWindow %i)\n", val, CGShieldingWindowLevel());
        }

        // Get window name of specific window. Rarely set by apps:
        winName[0] = 0;
        CFStringRef nameRef = (CFStringRef) CFDictionaryGetValue(d, kCGWindowName);
        if (nameRef) {
            const char* name = CFStringGetCStringPtr(nameRef, kCFStringEncodingMacRoman);
            if (name && verbose) printf("WindowName: %s\n", name);
            if (name) snprintf(winName, sizeof(winName), "%s", name);
        }

        // Get name of owner process/app:
        CFStringRef nameOwnerRef = (CFStringRef) CFDictionaryGetValue(d, kCGWindowOwnerName);
        if (nameOwnerRef) {
            const char* name = CFStringGetCStringPtr(nameOwnerRef, kCFStringEncodingMacRoman);
            if (name && verbose) printf("WindowOwnerName: %s\n", name);
            if (name &&
                #ifdef PTBOCTAVE3MEX
                strstr(name, "ctave")
                #else
                strstr(name, "MATLAB")
                #endif
                ) {
                // Matched either MATLAB GUI or Octave GUI. As windows are returned
                // in front-to-back order, the first match here is a candidate window that is on top of
                // the visible window stack. This is our best candidate for the command window, assuming
                // it is frontmost as the user just interacted with it. Therefore, aborting the search
                // on the first match is the most robust heuristic i can think of, given that the name
                // strings do not contain any info if a specific window hosts our session.
                found = TRUE;

                // pid contains the pid of the owning process.
                break;
            }
        }
    }

    CFRelease(windowList);

hwinpidout:

    // Drain the pool:
    [pool drain];

    if (found) {
        if (verbose) printf("TARGETWINDOWNAME: '%s' with pid %i.\n", winName, pid);
    }
    else pid = 0;

    return(pid);
}

// PsychCocoaSetUserFocusWindow is a replacement for Carbon's SetUserFocusWindow().
void PsychCocoaSetUserFocusWindow(void* window)
{
    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    DISPATCH_SYNC_ON_MAIN({
        NSWindow* focusWindow = (NSWindow*) window;

        // Special flag: Try to restore main apps focus:
        if (focusWindow == (NSWindow*) 0x1) {
            focusWindow = [[NSApplication sharedApplication] mainWindow];
        }

        // Direct keyboard input focus to window 'inWindow':
        if (focusWindow) [focusWindow makeKeyAndOrderFront: nil];

        // Special handle NULL provided? Try to regain keyboard focus rambo-style for
        // our hosting window for octave / matlab -nojvm in terminal window:
        if (focusWindow == NULL) {
            // This works to give keyboard focus to a process other than our (Matlab/Octave) runtime, if
            // the process id (pid_t) of the process is known and valid for a GUI app. E.g., passing in
            // the pid of the XServer process X11.app or the Konsole.app will restore the xterm'inal windows
            // or Terminal windows keyboard focus after a CGDisplayRelease() call, and thereby to the
            // octave / matlab -nojvm process which is hosted by those windows.
            //
            // Problem: Finding the pid requires iterating and filtering over all windows and name matching for
            // all possible candidates, and a shielding window from CGDisplayCapture() will still prevent keyboard
            // input, even if the window has input focus...
            pid_t pid = GetHostingWindowsPID();

            // Also, the required NSRunningApplication class is unsupported on 64-Bit OSX 10.5, so we need to
            // dynamically bind it and no-op if it is unsupported:
            Class nsRunningAppClass = NSClassFromString(@"NSRunningApplication");

            if (pid && (nsRunningAppClass != NULL)) {
                NSRunningApplication* motherapp = [nsRunningAppClass runningApplicationWithProcessIdentifier: pid];
                [motherapp activateWithOptions: NSApplicationActivateIgnoringOtherApps];
            }
        }
    });

    // Drain the pool:
    [pool drain];
}

// PsychCocoaGetUserFocusWindow is a replacement for Carbon's GetUserFocusWindow() function.
void* PsychCocoaGetUserFocusWindow(void)
{
    __block NSWindow* focusWindow = NULL;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Retrieve pointer to current keyWindow - the window that receives
    // key events aka the window with keyboard input focus. Or 'nil' if
    // no such window exists:
    DISPATCH_SYNC_ON_MAIN({focusWindow = [[NSApplication sharedApplication] keyWindow];});

    // Drain the pool:
    [pool drain];

    return((void*) focusWindow);
}

void PsychCocoaDisposeWindow(PsychWindowRecordType *windowRecord)
{
    NSWindow *cocoaWindow = (NSWindow*) windowRecord->targetSpecific.windowHandle;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    DISPATCH_SYNC_ON_MAIN({
        if (windowRecord->specialflags & kPsychExternalDisplayMethod) {
            if (PsychPrefStateGet_Verbosity() > 4)
                printf("PTB-INFO: External display method was in use for this window. Detaching CAMetalLayer...\n");

            [[cocoaWindow contentView] setWantsLayer:NO];
            [[cocoaWindow contentView] setLayer:NULL];
        }

        // Manually detach NSOpenGLContext from drawable. This seems to help to reduce
        // the frequency of those joyful "frozen screen hangs until mouse click" events
        // that OSX 10.9 brought to our happy little world:
        if (windowRecord->targetSpecific.nsmasterContext) [((NSOpenGLContext*) windowRecord->targetSpecific.nsmasterContext) clearDrawable];
        if (windowRecord->targetSpecific.nsswapContext) [((NSOpenGLContext*) windowRecord->targetSpecific.nsswapContext) clearDrawable];
        if (windowRecord->targetSpecific.nsuserContext) [((NSOpenGLContext*) windowRecord->targetSpecific.nsuserContext) clearDrawable];

        // Release NSOpenGLContext's - this will also release the wrapped
        // CGLContext's and finally really destroy them:
        if (windowRecord->targetSpecific.nsmasterContext) [((NSOpenGLContext*) windowRecord->targetSpecific.nsmasterContext) release];
        if (windowRecord->targetSpecific.nsswapContext) [((NSOpenGLContext*) windowRecord->targetSpecific.nsswapContext) release];
        if (windowRecord->targetSpecific.nsuserContext) [((NSOpenGLContext*) windowRecord->targetSpecific.nsuserContext) release];

        // Zero-Out the contexts after release:
        windowRecord->targetSpecific.nsmasterContext = NULL;
        windowRecord->targetSpecific.nsswapContext = NULL;
        windowRecord->targetSpecific.nsuserContext = NULL;

        // Close window. This will also release the associated contentView:
        [cocoaWindow close];
    });

    // Drain the pool:
    [pool drain];
}

void PsychCocoaShowWindow(void* window)
{
    NSWindow* cocoaWindow = (NSWindow*) window;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Bring to front:
    DISPATCH_SYNC_ON_MAIN({[cocoaWindow orderFrontRegardless];});

    // Show window:
    DISPATCH_SYNC_ON_MAIN({[cocoaWindow display];});

    // Drain the pool:
    [pool drain];
}

psych_bool PsychCocoaSetupAndAssignOpenGLContextsFromCGLContexts(void* window, PsychWindowRecordType *windowRecord)
{
    NSWindow* cocoaWindow = (NSWindow*) window;

    GLint opaque = 0;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Enable opacity for OpenGL contexts if underlying window is opaque:
    if ([cocoaWindow isOpaque] == true) opaque = 1;

    DISPATCH_SYNC_ON_MAIN({
        NSOpenGLContext *masterContext = NULL;
        NSOpenGLContext *gluserContext = NULL;
        NSOpenGLContext *glswapContext = NULL;

        // Build NSOpenGLContexts as wrappers around existing CGLContexts already
        // created in calling routine:
        masterContext = [[NSOpenGLContext alloc] initWithCGLContextObj: windowRecord->targetSpecific.contextObject];
        [masterContext setValues:&opaque forParameter:NSOpenGLContextParameterSurfaceOpacity];
        [masterContext setView:[cocoaWindow contentView]];
        // Doesn't work on the trainwreck - hang: [masterContext setFullScreen];
        [masterContext makeCurrentContext];
        [masterContext update];

        // Ditto for potential gl userspace rendering context:
        if (windowRecord->targetSpecific.glusercontextObject) {
            gluserContext = [[NSOpenGLContext alloc] initWithCGLContextObj: windowRecord->targetSpecific.glusercontextObject];
            [gluserContext setValues:&opaque forParameter:NSOpenGLContextParameterSurfaceOpacity];
            [gluserContext setView:[cocoaWindow contentView]];
            // Doesn't work on the trainwreck - hang: [gluserContext setFullScreen];
            [gluserContext update];
        }

        // Ditto for potential glswapcontext for async flips and frame sequential stereo:
        if (windowRecord->targetSpecific.glswapcontextObject) {
            glswapContext = [[NSOpenGLContext alloc] initWithCGLContextObj: windowRecord->targetSpecific.glswapcontextObject];
            [glswapContext setValues:&opaque forParameter:NSOpenGLContextParameterSurfaceOpacity];
            [glswapContext setView:[cocoaWindow contentView]];
            // Doesn't work on the trainwreck - hang: [glswapContext setFullScreen];
            [glswapContext update];
        }

        // Assign contexts for use in window close sequence later on:
        windowRecord->targetSpecific.nsmasterContext = (void*) masterContext;
        windowRecord->targetSpecific.nsswapContext = (void*) glswapContext;
        windowRecord->targetSpecific.nsuserContext = (void*) gluserContext;
    });

    // Drain the pool:
    [pool drain];

    // Assign final window globalRect (in units of points in gobal display space)
    // and final true backbuffer size 'rect' (in units of pixels):
    PsychCocoaGetWindowBounds(window, windowRecord->globalrect, windowRecord->rect);

    // Return success:
    return(false);
}

void PsychCocoaSendBehind(void* window)
{
    NSWindow* cocoaWindow = (NSWindow*) window;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Move window behind all others:
    DISPATCH_SYNC_ON_MAIN({[cocoaWindow orderBack:nil];});

    // Drain the pool:
    [pool drain];
}

void PsychCocoaSetWindowLevel(void* window, int inLevel)
{
    NSWindow* cocoaWindow = (NSWindow*) window;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Set level of window:
    DISPATCH_SYNC_ON_MAIN({[cocoaWindow setLevel:inLevel];});

    // Drain the pool:
    [pool drain];
}

void PsychCocoaSetWindowAlpha(void* window, float inAlpha)
{
    NSWindow* cocoaWindow = (NSWindow*) window;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Set Window transparency:
    DISPATCH_SYNC_ON_MAIN({[cocoaWindow setAlphaValue: inAlpha];});

    // Drain the pool:
    [pool drain];
}

void PsychCocoaSetThemeCursor(int inCursor)
{
    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    DISPATCH_SYNC_ON_MAIN({
        switch(inCursor) {
            case 0:
                [[NSCursor arrowCursor] set];
            break;

            case 4:
                [[NSCursor IBeamCursor] set];
            break;

            case 5:
                [[NSCursor crosshairCursor] set];
            break;

            case 10:
                [[NSCursor pointingHandCursor] set];
            break;
        }
    });

    // Drain the pool:
    [pool drain];
}

// Variable to hold current reference for App-Nap activities:
static NSObject *activity = NULL;

void PsychCocoaPreventAppNap(psych_bool preventAppNap)
{
    if (PsychPrefStateGet_Verbosity() > 3) printf("PTB-INFO: Activity state of AppNap is: %s.\n", (activity == nil) ? "No activities" : "Activities selected by PTB");

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Initialize the Cocoa application object, connect to CoreGraphics-Server:
    // Can be called many times, as redundant calls are ignored.
    DISPATCH_SYNC_ON_MAIN({
        NSApplicationLoad();
    });

    // Check if AppNap stuff is supported on this OS, ie., 10.9+. No-Op if unsupported:
    if (!([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)])) {
        goto outappnapstuff;
    }

    if ((activity == NULL) && preventAppNap) {
        // Prevent display from sleeping/powering down, prevent system from sleeping, prevent sudden termination for any reason:
        NSActivityOptions options = NSActivityIdleDisplaySleepDisabled | NSActivityIdleSystemSleepDisabled | NSActivitySuddenTerminationDisabled | NSActivityAutomaticTerminationDisabled;
        // Mark as user initiated state and request highest i/o and timing precision:
        options |= NSActivityUserInitiated | NSActivityLatencyCritical;

        activity = [[NSProcessInfo processInfo] beginActivityWithOptions:options reason:@"Psychtoolbox does not want to nap, it has need for speed!"];
        [activity retain];
        if (PsychPrefStateGet_Verbosity() > 3) printf("PTB-INFO: Running on OSX 10.9+ - Enabling protection against AppNap and other evils.\n");
        goto outappnapstuff;
    }

    if (!preventAppNap) {
        if (PsychPrefStateGet_Verbosity() > 3) printf("PTB-INFO: Reenabling AppNap et al. ... ");
        if (activity != NULL) {
            if (PsychPrefStateGet_Verbosity() > 3) printf("Make it so! %p - Retain %i\n", activity, (int) [activity retainCount]);
            [[NSProcessInfo processInfo] endActivity:activity];
            [activity release];
            activity = NULL;
        }
        else {
            if (PsychPrefStateGet_Verbosity() > 3) printf("but already enabled! Noop.\n");
        }
    }

outappnapstuff:
    // Drain the pool:
    [pool drain];

    return;
}

void PsychCocoaGetOSXVersion(int* major, int* minor, int* patchlevel)
{
    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Initialize the Cocoa application object, connect to CoreGraphics-Server:
    // Can be called many times, as redundant calls are ignored.
    DISPATCH_SYNC_ON_MAIN({
        NSApplicationLoad();
    });

    // Version query: Since macOS 10.10, would fail on older versions.
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    if (major) *major = version.majorVersion;
    if (minor) *minor = version.minorVersion;
    if (patchlevel) *patchlevel = version.patchVersion;

    // Drain the pool:
    [pool drain];
}

/* Return a pointer to a static string containing the full name of the logged in user */
char* PsychCocoaGetFullUsername(void)
{
    static char fullUserName[256] = { 0 };
    
    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString* nsname = NSFullUserName();
    const char *srcname = [nsname UTF8String];
    strncpy(fullUserName, srcname, sizeof(fullUserName) - 1);

    // Drain the pool:
    [pool drain];
    
    return(fullUserName);
}

/* Return backing store scale factor of window. Not equal one == Retina stuff */
double PsychCocoaGetBackingStoreScaleFactor(void* window)
{
    double sf;

    NSWindow* cocoaWindow = (NSWindow*) window;

    // Allocate auto release pool:
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Set Window transparency:
    sf = (double) [cocoaWindow backingScaleFactor];

    // Drain the pool:
    [pool drain];

    return (sf);
}

void PsychCocoaAssignCAMetalLayer(PsychWindowRecordType *windowRecord)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Second time CAMetalLayer reattach: Called from SCREENOpenWindow() after initial
    // OpenGL setup, display of the welcome splash screen, startup tests and timing
    // calibrations etc. are finished. We need OpenGL for all that, and attaching an
    // OpenGL context to the drawable detached "our" CAMetalLayer and attached some
    // OpenGL suitable layer instead. Now that we are done with OpenGL display, we can
    // reattach the CAMetalLayer for rendering/display via Metal, as needed for MoltenVK's
    // Vulkan-on-top-of-Metal ICD implementation:
    if (windowRecord->specialflags & kPsychExternalDisplayMethod) {
        NSWindow* cocoaWindow = (NSWindow*) windowRecord->targetSpecific.windowHandle;

        if (PsychPrefStateGet_Verbosity() > 3)
            printf("PTB-INFO: External display method is in use for this window. Reattaching CAMetalLayer at scaling factor %f.\n",
                   [cocoaWindow backingScaleFactor]);

        DISPATCH_SYNC_ON_MAIN({
            [((CAMetalLayer*) windowRecord->targetSpecific.deviceContext) setContentsScale:[cocoaWindow backingScaleFactor]];
            [[cocoaWindow contentView] setLayer:windowRecord->targetSpecific.deviceContext];
            [[[cocoaWindow contentView] layer] setDelegate:[cocoaWindow contentView]];
        });
    }

    // Drain the pool:
    [pool drain];
}

#pragma clang diagnostic pop
