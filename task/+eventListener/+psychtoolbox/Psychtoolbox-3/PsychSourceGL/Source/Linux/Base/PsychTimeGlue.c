/*
 *    PsychToolbox3/Source/Linux/Base/PsychTimeGlue.c
 *
 *    AUTHORS:
 *
 *    mario.kleiner.de@gmail.com              mk
 *
 *    PLATFORMS: GNU/Linux Only
 *
 *    PROJECTS: All
 *
 *    HISTORY:
 *
 *    2/20/06       mk        Wrote it. Derived from Windows version.
 *    1/03/09       mk        Add generic Mutex locking support as service to ptb modules. Add PsychYieldIntervalSeconds().
 *
 *    DESCRIPTION:
 *
 *    Functions for querying system time and for waiting for either a
 *    specified amount of time or until a specified point in time.
 *    Also returns timer ticks and resolution of timers.
 */

#include "Psych.h"
#include <time.h>
#include <errno.h>
#include <sched.h>

// utsname for uname() so we can find out on which kernel we're running:
#include <sys/utsname.h>

// Include header-file client library for controlling Feral's game-mode daemon:
#include "gamemode_client.h"

/*
 *        file local state variables
 */

static double       precisionTimerAdjustmentFactor = 1;
static double       estimatedGetSecsValueAtTickCountZero;
static psych_bool   isKernelTimebaseFrequencyHzInitialized = FALSE;
static double       kernelTimebaseFrequencyHz;
static double       sleepwait_threshold = 0.001;
static double       clockinc = 0;
static clockid_t    main_clock = CLOCK_REALTIME;

double PsychWaitUntilSeconds(double whenSecs)
{
    struct timespec rqtp;
    double targettime;
    static unsigned int missed_count=0;
    double now=0.0;
    int rc;

    // Get current time:
    PsychGetPrecisionTimerSeconds(&now);

    // If the deadline has already passed, we do nothing and return immediately:
    if (now >= whenSecs) return(now);

    // Waiting stage 1: If we have more than sleepwait_threshold seconds left
    // until the deadline, we call the OS usleep() function, so the
    // CPU gets released for (difference - sleepwait_threshold) seconds to other processes and threads.
    // -> Good for general system behaviour and for lowered power-consumption (longer battery runtime for
    // Laptops) as the CPU can go idle if nothing else to do...

    // Set an absolute deadline of whenSecs - sleepwait_threshold. We busy-wait the last few microseconds
    // to take scheduling jitter/delays gracefully into account:
    targettime    = whenSecs - sleepwait_threshold;

    // Convert targettime to timespec for the Posix clock functions:
    rqtp.tv_sec   = (unsigned long long) targettime;
    rqtp.tv_nsec  = ((targettime - (double) rqtp.tv_sec) * (double) 1e9);

    // Use clock_nanosleep() to high-res sleep until targettime, repeat if that gets
    // prematurely interrupted for whatever reason...
    while (now < targettime) {
        // MK: Oldstyle - obsolete: usleep((unsigned long)((whenSecs - now - sleepwait_threshold) * 1000000.0f));

        // Starting in 2008, we use high-precision/high-resolution POSIX realtime timers for precise waiting:
        // Call clock_nanosleep, use the realtime wall clock instead of the monotonic clock -- monotonic would
        // by theoretically a bit better as NTP time adjustments couldn't mess with our sleep, but that would
        // cause inconsistencies to other times reported by different useful system services which all measure
        // against wall clock, and in practice, the effect of NTP adjustments is minimal or negligible, as these
        // never create backwards running time or large timewarps, only 1 ppm level adjustments per second, ie,
        // the effect is way below the sleepwait_threshold for any reasonable sleep time -- easily compensated by
        // our hybrid approach...
        // We use TIMER_ABSTIME, so we are totally drift-free and restartable in case our sleep gets interrupted by
        // signals. If clock_nanosleep gets EINTR - Interrupted by a posix signal, we simply loop and restart the
        // sleep. If it returns a different error condition, we abort sleep iteration -- something would be seriously
        // wrong...
        if ((rc = clock_nanosleep(main_clock, TIMER_ABSTIME, &rqtp, NULL)) && (rc != EINTR)) break;

        // Update our 'now' time for reiterating or continuing with busy-sleep...
        PsychGetPrecisionTimerSeconds(&now);
    }

    // Waiting stage 2: We are less than sleepwait_threshold seconds away from deadline.
    // Perform busy-waiting until deadline reached:
    while (now < whenSecs) PsychGetPrecisionTimerSeconds(&now);

    // Check for deadline-miss of more than 0.1 ms:
    if (now - whenSecs > 0.0001) {
        // Deadline missed by over 0.1 ms.
        missed_count++;
        // As long as the threshold is below a msec, immediately increase by 100 microsecs...
        if (sleepwait_threshold < 0.001) sleepwait_threshold+=0.0001;

        // If threshold has reached 1 msec, we require multiple consecutive misses before increasing any further:
        if (missed_count>5) {
            // Too many consecutive misses. Increase our threshold for sleep-waiting
            // by 0.1 ms until it reaches max. 10 ms.
            if (sleepwait_threshold < 0.01) sleepwait_threshold+=0.0001;

            printf("PTB-WARNING: Wait-Deadline missed for %i consecutive times (Last miss %lf ms). New sleepwait_threshold is %lf ms.\n",
                   missed_count, (now - whenSecs)*1000.0f, sleepwait_threshold*1000.0f);
        }
    }
    else {
        // No miss detected. Reset counter...
        missed_count=0;
    }

    // Ready.
    return(now);
}

double PsychWaitIntervalSeconds(double delaySecs)
{
    double deadline = PsychGetAdjustedPrecisionTimerSeconds(NULL);

    if (delaySecs <= 0)
        return(deadline);

    // Compute deadline in absolute system time:
    deadline += delaySecs;

    // Wait until deadline reached:
    return(PsychWaitUntilSeconds(deadline));
}

/* PsychYieldIntervalSeconds() - Yield the cpu for given 'delaySecs'
 *
 * PsychYieldIntervalSeconds() differs from PsychWaitIntervalSeconds() in that
 * it is supposed to release the cpu to other threads or processes for *at least*
 * the given amount of time 'delaySecs', instead of *exactly* 'delaySecs'.
 *
 * If one wants to wait an exact amount of time, one uses PsychWaitIntervalSeconds().
 * If one just "has nothing to do" for some minimum amount of time, and wants to
 * play nice to other threads/processes and exact timing is not crucial, then
 * this is the routine of choice. Typical use is within polling loops, where one
 * wants to pause between polling cycles and it doesn't matter if the pause takes
 * a bit longer.
 *
 * A 'delaySecs' of <= zero will just release the cpu for the remainder of
 * the current scheduling timeslice. If you don't know what to do, choose a
 * zero setting.
 *
 */
double PsychYieldIntervalSeconds(double delaySecs)
{
    if (delaySecs <= 0) {
        // Yield cpu for remainder of this timeslice:
        sched_yield();
    }
    else {
        // On Linux we use standard wait ops - they're good enough for us.
        // However, we make sure that the wait lasts at least 2x the sleepwait_threshold,
        // so the cpu gets certainly released to other threads, instead of getting hogged
        // by busy-waiting for too short delaySecs intervals - which would be detrimental
        // to the goals of PsychYieldIntervalSeconds():
        delaySecs = (delaySecs > 2.0 * sleepwait_threshold) ? delaySecs : (2.0 * sleepwait_threshold);
        PsychWaitIntervalSeconds(delaySecs);
    }

    return(PsychGetAdjustedPrecisionTimerSeconds(NULL));
}

double PsychGetKernelTimebaseFrequencyHz(void)
{
    if(!isKernelTimebaseFrequencyHzInitialized){
        isKernelTimebaseFrequencyHzInitialized=TRUE;
        PsychGetPrecisionTimerTicksPerSecond(&kernelTimebaseFrequencyHz);
    }

    return((double)kernelTimebaseFrequencyHz);
}

void PsychInitTimeGlue(void)
{
    // Selection of main clock, aka GetSecs() clock, which is used pretty much
    // everywhere. Default to CLOCK_REALTIME aka gettimeofday() clock aka
    // wall clock, which is what was used on Linux since day one:
    main_clock = CLOCK_REALTIME;

    // Allow user override via environment variable, to be set via PsychTweak():
    if (getenv("PSYCH_GETSECS_CLOCK")) {
        main_clock = atoi(getenv("PSYCH_GETSECS_CLOCK"));
        switch (main_clock) {
            case CLOCK_REALTIME:        // 0
            case CLOCK_MONOTONIC:       // 1
            case CLOCK_MONOTONIC_RAW:   // 4
            case CLOCK_BOOTTIME:        // 7
            case CLOCK_TAI:             // 11
                errno = 0;
                if (clock_getres(main_clock, NULL) && (errno == EINVAL)) {
                    printf("PTB-ERROR: Selected clock_id %i for GetSecs and timekeeping unsupported by operating system! Reverting to 0 == CLOCK_REALTIME.\n", main_clock);
                    main_clock = CLOCK_REALTIME;
                }
                break;

            default:
                printf("PTB-ERROR: Tried to select an unsupported clock_id %i for GetSecs and timekeeping! Reverting to default 0 == CLOCK_REALTIME.\n", main_clock);
                main_clock = CLOCK_REALTIME;
        }
    }

    // Set this, although its totally pointless on our implementation...
    PsychEstimateGetSecsValueAtTickCountZero();
}

/* Called at module shutdown/jettison time: */
void PsychExitTimeGlue(void)
{
    // Disable game-mode optimizations if any are active:
    PsychOSSetGameMode(FALSE, 3);

    return;
}

void PsychGetPrecisionTimerTicks(psych_uint64 *ticks)
{
    double secs;

    // Simply map current systemtime to microseconds...
    PsychGetPrecisionTimerSeconds(&secs);
    *ticks = (psych_uint64) (secs * 1000000.0 + 0.5);
    return;
}

void PsychGetPrecisionTimerTicksPerSecond(double *frequency)
{
    // Our timesource resolves time at microsecond resolution or better,
    // so one can think of it as a virtual timer with a tickrate of 1 Mhz:
    *frequency=1000000.0f;
    return;
}

void PsychGetPrecisionTimerTicksMinimumDelta(psych_uint32 *delta)
{
    struct timespec res;

    // We return the real clock tick resolution in microseconds:
    clock_getres(main_clock, &res);
    *delta = (psych_uint32) ((((double) res.tv_sec) + ((double) res.tv_nsec / 1e9)) * 1e6);
}

/* CLOCK_REALTIME / gettimeofday() time to Linux GetSecs time. */
double PsychOSRealtimeToRefTime(double t)
{
    // TODO FIXME: This only works for CLOCK_MONOTONIC GetSecs main_clock timebase,
    // and can be inaccurate! Should use same approach as in PsychOSMonotonicToRefTime()!

    // CLOCK_MONOTONIC GetSecs timebase?
    if (main_clock == CLOCK_MONOTONIC) {
        // Yes. Need to convert from CLOCK_REALTIME / gettimeofday() to CLOCK_MONOTONIC:
        t -= PsychGetWallClockSeconds() - PsychOSGetLinuxMonotonicTime();
    }

    return(t);
}

/* PsychOSGetLinuxMonotonicTime() -- Linux only.
 *
 * Return CLOCK_MONOTONIC time (usually system uptime) in seconds.
 * Return zero on failure.
 *
 * Some subsystems return time not in main_clock time, but in CLOCK_MONOTONIC
 * time. In such cases we need to query this time to compute proper offsets for
 * remapping into the main_clock timebase which is used everywhere in PTB.
 *
 * An example is ALSA audio support in PsychPortAudio: ALSA drivers are free to
 * return their audio timestamps in CLOCK_REALTIME time or CLOCK_MONOTONIC time,
 * so we need to dynamically check, adapt and remap if neccessary.
 *
 */
double PsychOSGetLinuxMonotonicTime(void)
{
    struct timespec ts;
    if (0!= clock_gettime(CLOCK_MONOTONIC, &ts)) return(0.0);
    return((double) ts.tv_sec + ((double) ts.tv_nsec / (double) 1e9));
}

/* PsychOSMonotonicToRefTime(t)
 *
 * Map given input time value monotonicTime to PTB reference time if
 * neccessary, pass-through otherwise.
 *
 */
double PsychOSMonotonicToRefTime(double monotonicTime)
{
    double now, now2, tMonotonic;

    // Short-cut this if main "reference" clock is already CLOCK_MONOTONIC:
    if (main_clock == CLOCK_MONOTONIC)
        return(monotonicTime);

    // Get current reftime:
    PsychGetAdjustedPrecisionTimerSeconds(&now);
    // Get current CLOCK_MONOTONIC time:
    tMonotonic = PsychOSGetLinuxMonotonicTime();

    // Given input monotonicTime time value closer to tMonotonic than to GetSecs time?
    if (fabs(monotonicTime - tMonotonic) < fabs(monotonicTime - now)) {
        // Timestamps are in monotonic time! Need to remap.
        // Requery reference and monotonic time in a retry-loop
        // to make sure remapping error is tighlty bounded to max. 20 usecs:
        do {
            // Get current reftime:
            PsychGetAdjustedPrecisionTimerSeconds(&now);
            // Get current CLOCK_MONOTONIC time:
            tMonotonic = PsychOSGetLinuxMonotonicTime();
            // Requery to make sure mapping is tight:
            PsychGetAdjustedPrecisionTimerSeconds(&now2);
        } while (now2 - now > 0.000020);

        // Computer average of both timestamps to get best estimate of "now":
        now = (now + now2) / 2;

        // tMonotonic shall be the offset between GetSecs and monotonic time,
        // i.e., the offset that needs to be added to monotonic timestamps to
        // remap them to GetSecs time:
        tMonotonic = now - tMonotonic;

        // Correct timestamp by adding corrective offset:
        monotonicTime += tMonotonic;
    }

    return(monotonicTime);
}

/* PsychOSRefTimeToMonotonicTime(t)
 *
 * Map given input PTB reference time to CLOCK_MONOTONIC time.
 *
 * Iow main_clock to CLOCK_MONOTONIC time.
 *
 */
double PsychOSRefTimeToMonotonicTime(double refInputTime)
{
    // Short-cut this if main "reference" clock is already CLOCK_MONOTONIC:
    if (main_clock == CLOCK_MONOTONIC)
        return(refInputTime);

    double monotonicNowTime = PsychOSGetLinuxMonotonicTime();
    double referenceNowTime = PsychOSMonotonicToRefTime(monotonicNowTime);
    return(monotonicNowTime + (refInputTime - referenceNowTime));
}

void PsychGetPrecisionTimerSeconds(double *secs)
{
    static psych_bool firstTime = TRUE;
    struct timespec res;

    // First time invocation?
    if (firstTime) {
        // We query the real clock tick resolution in secs and store in global clockinc.
        // This is useful as a constraint on sleepwait_threshold etc. for our sleep routines...
        clock_getres(main_clock, &res);
        clockinc = ((double) res.tv_sec) + ((double) res.tv_nsec / 1.e9);

        // sleepwait_threshold should be significantly higher than the granularity of
        // the underlying system clock, say 100x the resolution, but no higher than 10 msecs,
        // and no lower than 100 microseconds. We start with optimistic 250 microseconds...
        sleepwait_threshold = 0.00025;
        if (sleepwait_threshold < 100 * clockinc) sleepwait_threshold = 100 * clockinc;
        if (sleepwait_threshold > 0.010) sleepwait_threshold = 0.010;
        // Only output info about sleepwait threshold and clock resolution if we consider the
        // clock rather low res, ie. increments bigger 20 microseconds:
        if (clockinc > 0.00002) printf("PTB-INFO: Real resolution of (rather low resolution!) system clock is %1.4f microseconds, dynamic sleepwait_threshold starts with %lf msecs...\n", clockinc * 1e6, sleepwait_threshold * 1e3);

        firstTime = FALSE;
    }

    // We use clock_gettime() - It returns time with nanosecond resolution and
    // is implemented via the highest precision time source on each Linux
    // system, e.g., the processors performance counters (TSC) on Intel
    // architecture processors. The resolution of the underlying hardware clock
    // source is often much better than 1 microsecond, e.g., indeed nanoseconds,
    // but Linux chooses always the highest precision reliable source, so in
    // case TSC's are broken, and HPET's are not available, and ACPI PM-Timers
    // aren't available, it could be a worse than 1 usec source, although this
    // is extremely unlikely...
    static double oldss = -1;
    double ss;
    struct timespec ts;
    if (0 != clock_gettime(main_clock, &ts)) {
        // This error is basically impossible, but for beauty points we check for it anyway:
        ss = 0;
        printf("PTB-CRITICAL_ERROR: clock_gettime(%i) failed!!\n", main_clock);
    }
    else {
        ss = ((double) ts.tv_sec) + ((double) ts.tv_nsec / (double) 1e9);
    }

    // Some correctness checks against last queried value, if initialized:
    if (oldss > -1) {
        // Old reference available. We check for monotonicity, ie. if time
        // is not going backwards. That's all we can do, as we don't have access
        // to a reference clock. We can't check for clock halts either, because
        // given a fast machine, or concurrent calls from multiple threads and a
        // low granularity clocksource, it could happen that multiple queries report
        // the same time. However, i (MK) checked the source code of current Linux2.6.22
        // kernels and found that Linux itself contains plenty of checks and measures to
        // make sure the clock is working correctly and to compensate for any conceivable
        // failure. We couldn't do a better job than the kernel in any case. This check
        // is just to spot idiots in front of the keyboard that manually override Linux
        // clocksource selection and basically try to shoot themselves into the leg.
        // It may also be useful is somebody is running a very old Linux kernel without
        // sophisticated checking and for testing/debugging PTB and its error-handling itself by
        // fault-injection...
        // MK: DISABLED FOR THIS RELEASE: Gives false alarms due to some race-condition when
        // function is called from multiple concurrent threads. Proper fix is known, but i
        // want to get a beta out now and not in a week...
        // if (ss < oldss) {
        if (FALSE) {
            // Time warp detected! Time going backwards!!! Nothing we can do, only report
            // it:
            printf("\n\nPTB-CRITICAL-ERROR: Your systems clock is reporting time to run backwards!!!\n");
            printf("PTB-CRITICAL-ERROR: (Delta %lf secs). This is impossible and indicates some\n", ss - oldss);
            printf("PTB-CRITICAL-ERROR: broken clock hardware or Linux setup!! Stop using this machine\n");
            printf("PTB-CRITICAL-ERROR: for psychophysics immmediately and resolve the problem!!!\n\n");
            fflush(NULL);
        }
    }

    // Init reference timestamp for checking in next call:
    oldss = ss;

    // Assign final time value:
    *secs= ss;
}

double PsychGetAdjustedPrecisionTimerSeconds(double *secs)
{
    double rawSecs;

    PsychGetPrecisionTimerSeconds(&rawSecs);
    rawSecs = rawSecs * precisionTimerAdjustmentFactor;

    if (secs) *secs = rawSecs;
    return(rawSecs);
}

void PsychGetPrecisionTimerAdjustmentFactor(double *factor)
{
    *factor = precisionTimerAdjustmentFactor;
}

void PsychSetPrecisionTimerAdjustmentFactor(double *factor)
{
    precisionTimerAdjustmentFactor =* factor;
}

/*
 *    PsychEstimateGetSecsValueAtTickCountZero()
 *
 */
void PsychEstimateGetSecsValueAtTickCountZero(void)
{
    // This is zero by definition of our counters...
    estimatedGetSecsValueAtTickCountZero = 0;
}

double PsychGetEstimatedSecsValueAtTickCountZero(void)
{
    return(estimatedGetSecsValueAtTickCountZero);
}

/* PsychGetWallClockSeconds - Always return CLOCK_REALTIME (aka gettimeofday()) wall clock time. */
double PsychGetWallClockSeconds(void)
{
    struct timespec ts;

    if (0 != clock_gettime(CLOCK_REALTIME, &ts))
        return(0.0);

    return((double) ts.tv_sec + ((double) ts.tv_nsec / (double) 1e9));
}

/* Init a Mutex: */
int PsychInitMutex(psych_mutex* mutex)
{
    int rc;

    // Use mutex attributes:
    pthread_mutexattr_t attr;

    // Set them to default settings, except for...
    pthread_mutexattr_init(&attr);

    // ... priority inheritance: We absolutely want it for extra
    // good realtime behaviour - Avoidance of priority inversion
    // at lock contention points:
    pthread_mutexattr_setprotocol(&attr, PTHREAD_PRIO_INHERIT);

    // Create mutex with attributes in attr:
    rc = pthread_mutex_init(mutex, &attr);
    if (rc != 0) {
        printf("\n\nPTB-CRITICAL: PsychInitMutex(): Mutex initialization failed [%s]! Expect huge trouble and serious malfunctions!!!\n", strerror(rc));
        printf("PTB-CRITICAL: PsychInitMutex(): Set a breakpoint on your debugger on pthread_mutexattr_destroy() to debug this.\n\n");
    }

    // Done with it:
    pthread_mutexattr_destroy(&attr);

    return(rc);
}

/* Deinit and destroy a Mutex: */
int PsychDestroyMutex(psych_mutex* mutex)
{
    return(pthread_mutex_destroy(mutex));
}

/* Lock a Mutex, blocking until mutex is available if it isn't available: */
int PsychLockMutex(psych_mutex* mutex)
{
    return(pthread_mutex_lock(mutex));
}

/* Try to lock a Mutex, returning immediately, with a return code that tells if mutex could be locked or not: */
int PsychTryLockMutex(psych_mutex* mutex)
{
    return(pthread_mutex_trylock(mutex));
}

/* Unlock a Mutex: */
int PsychUnlockMutex(psych_mutex* mutex)
{
    return(pthread_mutex_unlock(mutex));
}

/* Create a parallel thread of execution, invoke its main routine: */
int PsychCreateThread(psych_thread* threadhandle, void* threadparams, void *(*start_routine)(void *), void *arg)
{
    // threadparams not yet used, this line just to make compiler happy:
    (void) threadparams;

    // Return result code of pthread_create - We're a really thin wrapper around this Posix call:
    return( pthread_create(threadhandle, NULL, start_routine, arg) );
}

/* Join a parallel thread - Wait for its termination, then return its result code: */
int PsychDeleteThread(psych_thread* threadhandle)
{
    // Join on the thread, wait for termination:
    int rc = pthread_join(*threadhandle, NULL);

    // Null out now invalid thread handle of dead thread:
    *threadhandle = 0;

    // Return return code of joined thread:
    return(rc);
}

/* Send abort request to thread: */
int PsychAbortThread(psych_thread* threadhandle)
{
    return( pthread_cancel(*threadhandle) );
}

/* Check for abort request to thread: Exit thread gracefully if abort requested: */
void PsychTestCancelThread(psych_thread* threadhandle)
{
    // threadhandle unused on POSIX: This line just to make compiler happy:
    (void) threadhandle;

    // Test for cancellation, cancel if so:
    pthread_testcancel();
}

/* Return handle of calling thread: */
psych_threadid PsychGetThreadId(void)
{
    return( pthread_self() );
}

/* Check if two given thread handles do refer to the same thread: */
int PsychIsThreadEqual(psych_thread threadOne, psych_thread threadTwo)
{
    return( pthread_equal(threadOne, threadTwo) );
}

/* Check if current (invoking) thread has an id equal to given threadid: */
int PsychIsCurrentThreadEqualToId(psych_threadid threadId)
{
    return( pthread_equal(PsychGetThreadId(), threadId) );
}

/* Check if current (invoking) thread is equal to given threadhandle: */
int PsychIsCurrentThreadEqualToPsychThread(psych_thread threadhandle)
{
    return( pthread_equal(PsychGetThreadId(), threadhandle) );
}

/* Change priority for thread 'threadhandle', or for the calling thread if 'threadhandle' == NULL.
 * threadhandle == 0x1 means "Main Psychtoolbox thread" and may incur special treatment.
 * 'basePriority' can be 0 for normal scheduling, 1 for higher priority and 2 for highest priority.
 * 'tweakPriority' modulates more fine-grained within the category given by 'basepriority'. It
 * can be anywhere between 0 and some big value where bigger means more priority.
 *
 * Returns zero on success, non-zero on failure to set new priority.
 */
int PsychSetThreadPriority(psych_thread* threadhandle, int basePriority, int tweakPriority)
{
    int rc = 0;
    int policy;
    struct sched_param sp;
    pthread_t thread;

    if ((NULL != threadhandle) && ((psych_thread*) 0x1 != threadhandle)) {
        // Retrieve thread handle of thread to change:
        thread = *threadhandle;
    }
    else {
        // Retrieve handle of calling thread:
        thread = pthread_self();
    }

    // Retrieve current scheduling policy and parameters:
    pthread_getschedparam(thread, &policy, &sp);

    switch (basePriority) {
        case 0:    // Normal priority. No change to scheduling priority:
            policy = SCHED_OTHER;
            sp.sched_priority = 0;
            break;

        case 1: // High priority / Round robin realtime.
            policy = SCHED_RR;
            sp.sched_priority = sp.sched_priority + tweakPriority;
            break;

        case 2:      // Highest priority: FIFO scheduling
        case 10:  // Multimedia class scheduling emulation for non-Windows:
            policy = SCHED_FIFO;
            sp.sched_priority = sp.sched_priority + tweakPriority;
            break;

        default:
            printf("PTB-CRITICAL: In call to PsychSetThreadPriority(): Invalid/Unknown basePriority %i provided!\n", basePriority);
            rc = 2;
    }

    // Try to apply new priority and scheduling method:
    if (rc == 0) {
        // Make sure we have at least prio level 1 for RT scheduling policies:
        if ((policy != SCHED_OTHER) && (sp.sched_priority < 1)) sp.sched_priority = 1;

        rc = pthread_setschedparam(thread, policy, &sp);
        if (rc != 0) printf("PTB-CRITICAL: In call to PsychSetThreadPriority(): Failed to set new basePriority %i, tweakPriority %i, effective %i [%s] for thread %p provided!\n",
            basePriority, tweakPriority, sp.sched_priority, (policy != SCHED_OTHER) ? "REALTIME" : "NORMAL", (void*) threadhandle);
    }

    // rc is either zero for success, or 2 for invalid arg, or some other non-zero failure code:
    return(rc);
}

/* Assign a name to a thread, for debugging: */
void PsychSetThreadName(const char *name)
{
    #  if defined(__GNU_LIBRARY__) && defined(__GLIBC__) && defined(__GLIBC_MINOR__) && \
    (__GLIBC__ >= 3 || (__GLIBC__ == 2 && __GLIBC_MINOR__ >= 12))
    pthread_setname_np(pthread_self(), name);
    #  endif

    (void) name;
}

/* Initialize condition variable:
 * CAUTION: Use of condition_attribute is non-portable! Code using it will not work properly
 * on MS-Windows as this attribute is unsupported there! Pass NULL for this argument for
 * portable operation!
 */
int PsychInitCondition(psych_condition* condition, const pthread_condattr_t* condition_attribute)
{
    return(pthread_cond_init(condition, condition_attribute));
}

/* Destroy condition variable: */
int PsychDestroyCondition(psych_condition* condition)
{
    return(pthread_cond_destroy(condition));
}

/* Signal/wakeup exactly one thread waiting on the given condition variable: */
int PsychSignalCondition(psych_condition* condition)
{
    return(pthread_cond_signal(condition));
}

/* Signal/Wakeup all threads waiting on the given condition variable:
 * CAUTION: Use of this function is non-portable to MS-Windows for now! Code
 * using it will malfunction if used on MS-Windows!
 */
int PsychBroadcastCondition(psych_condition* condition)
{
    return(pthread_cond_broadcast(condition));
}

/* Atomically release the 'mutex' lock and go to sleep, waiting for the 'condition' variable
 * being signalled, then waking up and trying to re-lock the 'mutex'. Will return with
 * mutex locked.
 */
int PsychWaitCondition(psych_condition* condition, psych_mutex* mutex)
{
    return(pthread_cond_wait(condition, mutex));
}

/* Atomically release the 'mutex' lock and go to sleep, waiting for the 'condition' variable
 * being signalled, then waking up and trying to re-lock the 'mutex'. Will return with
 * mutex locked.
 *
 * Like PsychWaitCondition, but function will timeout if it fails being signalled before
 * timeout interval 'maxwaittimesecs' expires. In any case, it will only return after
 * reacquiring the mutex. It will retun zero on successfull wait, non-zero (ETIMEDOUT) if
 * timeout was triggered without the condition being signalled.
 */
int PsychTimedWaitCondition(psych_condition* condition, psych_mutex* mutex, double maxwaittimesecs)
{
    struct timespec abstime;

    // Convert relative wait time to absolute CLOCK_REALTIME system time:
    // Note: Would go wrong if condition was initialized to use CLOCK_MONOTONIC instead, by
    // passing a corresponding non-standard-clockid condition_attribute to PsychInitCondition().
    maxwaittimesecs += PsychGetWallClockSeconds();

    // Split maxwaittimesecs in...

    // ... full integral seconds (floor() it)...
    abstime.tv_sec  = (time_t) maxwaittimesecs;

    // ... and fractional seconds, expressed as nanoseconds in (long) format:
    abstime.tv_nsec = (long) (((double) maxwaittimesecs - (double) abstime.tv_sec) * (double) (1e9));

    // Perform wait with timeout:
    return(pthread_cond_timedwait(condition, mutex, &abstime));
}

/* Set thread affinity mask of calling thread to the modules global cpuMask:
 *
 * 'curCpuMask' is an in/out pointer. If NULL, it is completely ignored. If non-NULL,
 * the target variable of the pointer will contain the new cpu mask after a change
 * of mask. If the target variable already contains a valid (non-zero) current cpu mask
 * and it matches the new target cpu mask, then the actual mask change is omitted, assuming it
 * is redundant, thereby saving some system call overhead.
 *
 * Threads can avoid redundant switches if they keep track of their current cpu mask
 * by caching it in the *curCpuMask pointer target. They can pass in a zero value if
 * unsure, or a NULL pointer if they are neither interested in caching, nor in the old
 * or new value.
 *
 * Returns the old pre-switch affinity mask as a 64-Bit bitfield.
 * Comparing the return value (previous mask) with the *curCpuMask value (new mask)
 * allows the caller to check if the affinity mask was actually changed, resulting
 * in a possible thread migration.
 *
 * If this function is called without the time lock held, ie., from outside
 * of other timeglue functions, a small race condition exists which may cause
 * deferred updated to the real new affinity mask due to
 *
 */
psych_uint64 PsychAutoLockThreadToCores(psych_uint64* curCpuMask)
{
    (void) curCpuMask;

    // No op on Linux.
    return(INT64_MAX);
}

/* Report official support status for this operating system release.
 * The string "Supported" means supported.
 * Other strings describe lack of support.
 */
const char* PsychSupportStatus(void)
{
    static char statusString[256];
    struct utsname unameresult;

    uname(&unameresult);
    sprintf(statusString, "Linux %s Supported.", unameresult.release);

    return(statusString);
}

/* Test if module needs to call XInitThreads() itself during startup:
 *
 * verbose: 0 = Shut up, 1/2 = Important messages only, 3 = Info messages, 4 = Debug output.
 *
 * Returns:
 *
 * 0 if XInitThreads() call is not needed, or not safe to perform.
 * 1 if call is needed and safe, or is enforced by user-code in any case.
 *
 */
int PsychOSNeedXInitThreads(int verbose)
{
    const char* name = PsychGetModuleName();
    psych_bool needed, safe;
    void** x_lock = NULL;
    void** errfun1 = NULL;
    void** errfun2 = NULL;

    // Detect if the libX11 XLib master lock named _Xglobal_lock exists, and
    // if it has a non-NULL value. If so, that means the hosting application has
    // called XInitThreads() during startup, as required for safe multi-threading.
    // If not, then that important call was omitted and our use of multi-threading
    // or possibly of libX11 concurrently with a GUI based hosting app at all is
    // potentially unsafe and deserves a workaround or a warning to the user:
    x_lock = dlsym(RTLD_DEFAULT, "_Xglobal_lock");
    needed = x_lock == NULL || *x_lock == NULL;

    // Try to figure out if the host process already called XLib functions. Calls to
    // XSetErrorHandler() early during use of XLib, or to XOpenDisplay() to establish
    // a connection to the X-Server, would init the XLib global _XErrorFunction to a
    // non-NULL value - either the app specific error handler or the XLib default error
    // handler. Iow. _XErrorFunction would be non-NULL. The same is true wrt. to the
    // fatal error handler function XSetIOErrorHandler() for _XIOErrorFunction.
    // In these cases, we are too late as it would be dangerous to call XInitThreads()
    // ourselves after the host process did anything with XLib before us without
    // calling XInitThreads() itself as first step.
    errfun1 = dlsym(RTLD_DEFAULT, "_XErrorFunction");
    errfun2 = dlsym(RTLD_DEFAULT, "_XIOErrorFunction");
    safe = !((errfun1 == NULL || *errfun1 != NULL) || (errfun2 == NULL || *errfun2 != NULL));

    if (verbose >= 4) {
        printf("%s-DEBUG: libX11 global threading lock _Xglobal_lock[%p] = %p\n", name, x_lock, x_lock ? *x_lock : NULL);
        printf("%s-DEBUG: _XErrorFunction[%p] = %p\n", name, errfun1, errfun1 ? *errfun1 : NULL);
        printf("%s-DEBUG: _XIOErrorFunction[%p] = %p\n", name, errfun2, errfun2 ? *errfun2 : NULL);
        printf("%s-DEBUG: XInitThreads() is considered: needed = %i, safe = %i\n", name, (int) needed, (int) safe);
    }

    // Call XInitThreads() due to usercode's request / override?
    if (getenv("PSYCH_XINITTHREADS")) {
        if (verbose >= 3)
            printf("%s-INFO: Calling XInitThreads() on usercode's request, as environment variable PSYCH_XINITTHREADS is set.\n", name);

        return(1);
    }

    if (needed) {
        // Safe multi-threading not initialized by host process :( - Safe to work around this?
        if (!safe) {
            // Game over: Host process did XLib stuff already, e.g., to startup its GUI. Nothing
            // we can do but warn the user and ask him to fix the host application.

            // Awful but neccessary hack: If we are running under Octave then suppress all warnings :/
            // Turns out Octave 4.0 doesn't call XInitThreads - or more accurately, QT-4 which is used to
            // implement Octave's GUI, doesn't. Only QT-5 based Octave 4.2 and later does the right thing.
            // Unfortunately Ubuntu 16.04-LTS ships with Octave 4.0 and we probably shouldn't drop support
            // for 16.04-LTS just yet -- its end of life is only in April 2021. Screen() does implement its
            // own locking around X-Lib and PsychHID never made trouble, so technically we should and have
            // been fine all the years. No need to scare the user of Ubuntu 16.04 LTS without these warnings.
            #if (PSYCH_LANGUAGE == PSYCH_MATLAB) && defined(PTBOCTAVE3MEX)
                verbose = 0;
            #endif

            if (verbose > 0) {
                printf("%s-WARNING: Seems like the libX11 library was *not* initialized for thread-safe mode,\n", name);
                printf("%s-WARNING: because the application host process omitted a required call to\n", name);
                printf("%s-WARNING: XInitThreads() during its startup, as required for safe operation!\n", name);
                printf("%s-WARNING: Unfortunately the application host process already used XLib for\n", name);
                printf("%s-WARNING: something, e.g., for starting up its GUI, so i can not safely work\n", name);
                printf("%s-WARNING: around this problem! Use of multi-threading in %s() might cause\n", name, name);
                printf("%s-WARNING: malfunctions or even a hard application crash!\n", name);
                printf("%s-WARNING: Please fix the application to call XInitThreads() *before* calling\n", name);
                printf("%s-WARNING: any other libX11 X-Lib functions, or not to call X-Lib at all before using this module.\n", name);
                printf("%s-WARNING: You could force me to call XInitThreads() by setting the environment\n", name);
                printf("%s-WARNING: variable PSYCH_XINITTHREADS to any non-empty value as a workaround, if\n", name);
                printf("%s-WARNING: you like living on the edge, at your own risk though!\n", name);
                printf("%s-WARNING: I will continue, but may malfunction or crash at some point!\n", name);

                #if (PSYCH_LANGUAGE == PSYCH_MATLAB) && defined(PTBOCTAVE3MEX)
                    printf("%s-INFO: If you are running this under the application \"octave-cli\", then relaunch\n", name);
                    printf("%s-INFO: octave-cli with the --no-window-system switch: octave-cli --no-window-system\n", name);
                    printf("%s-INFO: or simply launch octave in the common way as: octave\n", name);
                    printf("%s-INFO: Calling octave instead of octave-cli should always work.\n", name);
                #else
                    #if (PSYCH_LANGUAGE == PSYCH_MATLAB) && !defined(PTBOCTAVE3MEX)
                        printf("%s-INFO: Upgrading to Matlab R2013b should fix this problem.\n", name);
                        printf("%s-INFO: Starting as matlab -nodisplay in command line mode should also work.\n", name);
                    #else
                        #if (PSYCH_LANGUAGE == PSYCH_PYTHON)
                            printf("%s-INFO: If you are using PsychoPy, simply upgrade to version 3.1.3 or later.\n", name);
                            printf("%s-INFO: Otherwise, you can generally fix Python scripts/apps by adding the following\n", name);
                            printf("%s-INFO: snippet early enough at the beginning of script execution under X11:\n", name);
                            printf("%s-INFO: import ctypes\n", name);
                            printf("%s-INFO: xlib = ctypes.cdll.LoadLibrary(\"libX11.so\")\n", name);
                            printf("%s-INFO: xlib.XInitThreads()\n", name);
                            printf("\n");
                        #else
                            printf("%s-INFO: It is probably best to ask the Psychtoolbox user forum for guidance.\n", name);
                        #endif
                    #endif
                #endif
            }
        }
        else {
            if (verbose >= 3) {
                // Seems the host process didn't use XLib at all yet. So we are its first user and
                // therefore should be able to call XInitThreads() safely -- knock on wood...
                printf("%s-INFO: libX11 library not yet set up for thread-safe operation by host application, as required.\n", name);
                printf("%s-INFO: Now calling XInitThreads() myself, to fix this problem in a likely safe way.\n", name);
            }
        }

        // Request call to XInitThreads() if it is considered a safe workaround:
        return((int) safe);
    }
    else {
        // All seems to be good, no need for us to do anything:
        if (verbose >= 4)
            printf("%s-DEBUG: No need for me to call XInitThreads().\n", name);

        return(0);
    }
}

void PsychOSSetGameMode(psych_bool enable, int verbosity)
{
    int rc;
    static psych_bool gameModeOn = FALSE;
    static psych_bool oneTimeWarningDone = FALSE;
    int status = gamemode_query_status();

    if (verbosity > 3) {
        printf("PTB-INFO: Gamemode optimizations %s requested. Current/Old status: %s\n",
               enable ? "enable" : "disable", (status > 0) ? "Active" : (status == -1) ? "Query failure" : "Disabled");
    }

    // Enable requested and we don't yet hold a enable reference (2)?
    if (enable && (status != 2)) {
        // Request to optimize the OS for enhanced realtime and high-performance by use of
        // Ferals game-mode daemon. This will do nothing if the game-mode package is not
        // installed and configured on the host machine. Otherwise the game mode daemon
        // will change cpu governor settings to push cpu's into high performance mode,
        // request io priority for us, switch supported gpu's into high performance mode,
        // disable screen savers etc.:
        rc = gamemode_request_start();
        if (rc != 0) {
            // Request failed:

            // dlopen() failure for libgamemode.so? That's most likely because the Feral gamemode package
            // is not installed on the host os.
            if (strstr(gamemode_error_string(), "dlopen")) {
                // Assume package not installed. Give a one-time info about this and how to install it:
                if (!oneTimeWarningDone && verbosity > 2) {
                    oneTimeWarningDone = TRUE;

                    printf("PTB-INFO: Failed to request additional performance tuning from operating system.\n");
                    printf("PTB-INFO: This is because the optional \"FeralInteractive gamemode\" package is not installed\n");
                    printf("PTB-INFO: and set up yet. If you want to have these extra optimizations, then read\n");
                    printf("PTB-INFO: the setup instructions in \"help LinuxGameMode\".\n");
                    if (verbosity > 3)
                        printf("PTB-INFO: Reason given: %s.", gamemode_error_string());
                    printf("\n");
                }
            }
            else {
                // Some other error. Report it:
                if (verbosity > 1) {
                    printf("PTB-WARNING: Failed to start gamemode optimizations: %s.\n", gamemode_error_string());
                    printf("PTB-WARNING: Maybe you need to reinstall the gamemode package? See \"help LinuxGameMode\"\n");
                }
            }
        }
        else {
            gameModeOn = TRUE;
        }
    }   // If disable requested and we hold a reference (2), or query failed (-1) but local tracking says we hold a reference:
    else if (!enable && (status == 2 || (status == -1 && gameModeOn))) {
        // Request shutdown of game mode: Drop our enable reference.
        rc = gamemode_request_end();
        if ((rc != 0) && (verbosity > 2)) {
            printf("PTB-INFO: Failed to shutdown gamemode optimizations [%s].\n", gamemode_error_string());
        }

        if (rc == 0)
            gameModeOn = FALSE;
    }

    if (verbosity > 3) {
        status = gamemode_query_status();
        printf("PTB-INFO: New status: %s\n", (status > 0) ? "Active" : (status == -1) ? "Query failure" : "Disabled");
    }
}

void PsychOSGetLinuxVersion(int* major, int* minor, int* patchlevel)
{
    struct utsname unameresult;
    int lmajor, lminor, lpatchlevel;

    uname(&unameresult);
    sscanf(unameresult.release, "%i.%i.%i", &lmajor, &lminor, &lpatchlevel);

    if (major) *major = lmajor;
    if (minor) *minor = lminor;
    if (patchlevel) *patchlevel = lpatchlevel;
}
