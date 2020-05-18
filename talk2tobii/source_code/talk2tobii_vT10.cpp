
#include <stdio.h>
#include <time.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <pthread.h>
#include <unistd.h>

#if defined(__ppc__) || defined(__linux__)
#include <pthread.h>
#include <tobii/tls_emulation.h>
#endif

//#include <mach/mach.h>
//#include <mach/mach_time.h>
//#include <sys/sysctl.h>
#include <CoreServices/CoreServices.h>

#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>

#include "tobii/tetext.h"
#include "tobii/ip_comm.h"	/* ip communication			*/
#include "tobii/tet_protocol.h"
#include "tobii/ttime.h"
#include "tobii/toberror.h"
#include "tobii/tet.h"
#include "tobii/byteorder.h"



#include "mex.h"
#include "matrix.h"


using std::vector;
using std::ostringstream;
using namespace std;


typedef vector<STet_GazeData> VectorGaze;
typedef vector<double> VectorTimeStamp;

typedef struct _history
{
    int TETcode;
    double timestamp;
}History;

typedef vector<History> Vector_history;

typedef struct _EventData
{
    char *code;
    double time;
    double duration;
    char *details;
} EVENTData;
typedef vector<EVENTData> EventDataVector;

/************************************************************************************************/
/* Static variables that report the eyeTracker status and whether threads have been initialised */
static unsigned long mex_call_counter = 0;
static char TOBII_HOST[20+1];
static short unsigned int TOBII_PORT = 4455;

// Some global variables: Input-Output of matlab funcion
int        gret_args=0;         /* Global variable that holds number of matlab return argumens returned */
int            gnlhs;           /* number of expected outputs */
mxArray       **gplhs;          /* array of pointers to output arguments */
int            gnrhs;           /* number of inputs */
const mxArray  **gprhs;         /* array of pointers to input arguments */

//treads and signaling
static pthread_t thread;
static pthread_mutex_t mutex;
//Server
static bool synchronous = false;
static bool done_flag = false;
static bool request_flag = false;
static pthread_cond_t request;
static pthread_cond_t done;

//calibration
static float *ci = NULL;
static float *cj = NULL;
static int cn = 9;          //number of calibration points
static int calpoint = 0;    //calibration point at this moment

//eye tracking
static float xl=-1.0f;		// left eye pos
static float yl=-1.0f;		// left eye pos
static float xr=-1.0f;		// right eye pos
static float yr=-1.0f;		// right eye pos
static float cxl=-1.0f;	// left camera eye pos
static float cyl=-1.0f;	// left camera eye pos
static float cxr=-1.0f;	// right camera eye pos
static float cyr=-1.0f;	// right camera eye pos
static unsigned long tim_Sec=0.0f;  // time in sec
static unsigned long tim_mSec=0.0f; // time in msec
static float diamL =0.0f;
static float diamR =0.0f;
static float distL =0.0f;
static float distR =0.0f;
static unsigned long valL =0.0f;
static unsigned long valR =0.0f;

//record flag
static bool recordFlag = false;
static VectorGaze gazeArray;
static char *filePathTobii = NULL;
static char *filePathEvents = NULL;
static EventDataVector EventVector;
static VectorTimeStamp vectorTimeStamp;
static bool firstTime = false;
//calibration data
static char *calibFile = NULL;
static STet_CalibAnalyzeData *quality = NULL;
static long qualityLen=1000;
static bool LoadCalib = false;
//history
static Vector_history TET_History;

//eye tracker status
#define	TET_API_CONNECT         0x0001 // 001 bits: 0000 0000 0000 0001
#define	TET_API_CONNECTED       0x0002 // 002 bits: 0000 0000 0000 0010
#define	TET_API_DISCONNECT      0x0004 // 004 bits: 0000 0000 0000 0100
#define	TET_API_CALIBRATING     0x0008 // 008 bits: 0000 0000 0000 1000
#define	TET_API_CALIBSTARTED	0x0010 // 016 bits: 0000 0000 0001 0000
#define	TET_API_RUNNING         0x0020 // 032 bits: 0000 0000 0010 0000
#define	TET_API_RUNSTARTED      0x0040 // 064 bits: 0000 0000 0100 0000
#define	TET_API_STOP            0x0080 // 128 bits: 0000 0000 1000 0000
#define	TET_API_FINISHED        0x0100 // 256 bits: 0000 0001 0000 0000
#define TET_API_SYNCHRONISE     0x0200 // 512 bits: 0000 0010 0000 0000
#define TET_API_CALIBEND        0x0400 //1024 bits: 0000 0100 0000 0000
#define TET_API_SYNCHRONISED    0x0800 //2048 bits: 0000 1000 0000 0000
static unsigned long status = 0x0000;

/*////////////////////////////////// Function Definitions /////////////////////////////////////////*/
//void *tobii_threadDEMO(void *ap);
extern "C" void gazeDataReceiver(ETet_CallbackReason reason, void *pData, void *pApplicationData);
void PrintGazeData(STet_GazeData *pGazeData);
void StopTobii();
void DisconnectTobii();
const mxArray *my_mexInputArg(const int argno);
/////////////////////////////////////////////////////////////////////////////////////////////////

void PrintError(void)
{
    char	pError[255];
    
    // Get latest error.
    // The error codes are allocated here and the description in called module.
    Tet_GetLastErrorAsText(pError);
    
    // Print on stderr
    mexPrintf("Error description: %s\n", pError);
}

/*////////////////////////////////// Implement Server ////////////////////////////////////////////*/
void signal_server()
{
    
    if(pthread_mutex_lock(&mutex))
        mexPrintf("SIGNAL_SERVER:lock server mutex error\n");
    
    request_flag = true;
    
    // tell server a request is available
    if(pthread_cond_signal(&request))
        mexPrintf("SIGNAL_SERVER:wake server error \n");
    
    if(pthread_mutex_unlock(&mutex))
        mexPrintf("SIGNAL_SERVER:unlocking server mutex error\n");
    
}

bool block_server()
{
    if(pthread_mutex_lock(&mutex))
        mexPrintf("BLOCK_SERVER:lock server mutex error\n");
    
    // wait for data
    if(synchronous) {
        while(!request_flag) {
            if(pthread_cond_wait(&request, &mutex))
                mexPrintf("BLOCK_SERVER:wait for request error\n");
        }
    }
    request_flag = false;
    
    if(pthread_mutex_unlock(&mutex))
        mexPrintf("SIGNAL_SERVER:unlocking server mutex error\n");
    
    return(true);
}

void block_draw()
{
    if(pthread_mutex_lock(&mutex))
        mexPrintf("BLOCK_DRAW:lock server mutex error\n");
    
    
    // wait
    if( synchronous )
    {
        while(!done_flag) {
            if(pthread_cond_wait(&done, &mutex))
                mexPrintf("BLOCK_DRAW:wait for request error\n");
        }
    }
    done_flag = false;
    
    if(pthread_mutex_unlock(&mutex))
        mexPrintf("BLOCK_DRAW:unlocking server mutex error\n");
    
}

void signal_draw(bool sync)
{
    if(pthread_mutex_lock(&mutex))
        mexPrintf("SIGNAL_DRAW:lock server mutex error\n");
    
    synchronous = sync;
    
    done_flag = true;
    
    // tell server a request is available
    if(pthread_cond_signal(&done))
        mexPrintf("SIGNAL_DRAW:wake server error \n");
    
    if(pthread_mutex_unlock(&mutex))
        mexPrintf("SIGNAL_DRAW:unlocking server mutex error\n");
    
}

/*////////////////////////////////// Main Thread ////////////////////////////////////////////////*/

void *tobii_thread(void *ap)
{
    unsigned long	Sec,MicroSec;
    
    long            qualityLenOrg=1000;
    static bool		sync=true;
    int             samples=20;	// if too few (e.g., 6)
    // calibration goes too fast!
    
    mxArray *plhs;
    double timestamp;
    History tmp_hist;

    // for retrieving time in secs
    double				timeDouble, secs;
    AbsoluteTime		timeAbsTime;
    Nanoseconds			timeNanoseconds;
    UInt64				timeUInt64;
    
    // allow thread to be cancelled (asynchronously, e.g., immediately)
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE,NULL);
    pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS,NULL);
    
    // initialize Tobii (this is critical - sets up thread-specific data)
    if(Tet_Init() != 0) {
        //store history and timestamp
        //GetSecs -- source code copied from psychtoolbox
        timeAbsTime=UpTime();
        timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);        
        timeUInt64=UnsignedWideToUInt64(timeNanoseconds);        
        timeDouble=(double)timeUInt64;
        secs= timeDouble / 1000000000;

        tmp_hist.timestamp = secs;
        tmp_hist.TETcode = 0;
        pthread_mutex_lock(&mutex);
        TET_History.push_back(tmp_hist);
        pthread_mutex_unlock(&mutex);

        mexPrintf("Problem initializing tobii\n");
        return(0);
    }
        
    while(!(status & TET_API_FINISHED) ) {
        
        if(!(status & TET_API_CONNECTED) &&
        (status & TET_API_CONNECT) ) {
            
            // connect to tobii
            if(Tet_Connect(TOBII_HOST,TOBII_PORT,"logfile")) {
                //store history and timestamp
                //GetSecs -- source code copied from psychtoolbox
                timeAbsTime=UpTime();
                timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                timeDouble=(double)timeUInt64;
                secs= timeDouble / 1000000000;
                
                tmp_hist.timestamp = secs;
                tmp_hist.TETcode = 1;
                pthread_mutex_lock(&mutex);
                TET_History.push_back(tmp_hist);
                pthread_mutex_unlock(&mutex);
                
                mexPrintf("Problem connecting with tobii\n");
                PrintError();
                Tet_Disconnect();

                pthread_mutex_lock(&mutex);
                status &= ~(TET_API_CONNECTED);
                status &= ~(TET_API_CONNECT);
                pthread_mutex_unlock(&mutex);
            }
            else {
                //store history and timestamp
                //GetSecs -- source code copied from psychtoolbox
                timeAbsTime=UpTime();
                timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                timeDouble=(double)timeUInt64;
                secs= timeDouble / 1000000000;
                
                tmp_hist.timestamp = secs;
                tmp_hist.TETcode = 100;
                pthread_mutex_lock(&mutex);
                TET_History.push_back(tmp_hist);
                pthread_mutex_unlock(&mutex);

                mexPrintf("connecting with tobii...success\n");
                pthread_mutex_lock(&mutex);
                status |= (TET_API_CONNECTED);
                status &= ~(TET_API_CONNECT);
                pthread_mutex_unlock(&mutex);
            }

                  mexPrintf("arrived here\n");
        }
      
        // calibrate
        if( (status & TET_API_CONNECTED) &&
        (status & TET_API_CALIBRATING) ) {
            // tell the eye tracker we're going to start calibrating
            // DO THIS ONLY ONCE PER CALIBRATION!
            
            if( !(status & TET_API_CALIBSTARTED) ) {
            
                if(Tet_CalibClear()) {
                    //store history and timestamp
                    //GetSecs -- source code copied from psychtoolbox
                    timeAbsTime=UpTime();
                    timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                    timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                    timeDouble=(double)timeUInt64;
                    secs= timeDouble / 1000000000;
                    
                    tmp_hist.timestamp = secs;
                    tmp_hist.TETcode = 2;
                    pthread_mutex_lock(&mutex);
                    TET_History.push_back(tmp_hist);
                    pthread_mutex_unlock(&mutex);
                
                    mexPrintf("Problem clearing calibration\n");
                    PrintError();
                    Tet_Disconnect();
                    pthread_mutex_lock(&mutex);
                    status &= ~(TET_API_CONNECTED);
                    status &= ~(TET_API_CALIBRATING);
                    pthread_mutex_unlock(&mutex);
                }
                else {
                    //store history and timestamp
                    //GetSecs -- source code copied from psychtoolbox
                    timeAbsTime=UpTime();
                    timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                    timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                    timeDouble=(double)timeUInt64;
                    secs= timeDouble / 1000000000;
                    
                    tmp_hist.timestamp = secs;
                    tmp_hist.TETcode = 200;
                    pthread_mutex_lock(&mutex);
                    TET_History.push_back(tmp_hist);
                    pthread_mutex_unlock(&mutex);

                    mexPrintf("clearing calibration...success\n");
                    pthread_mutex_lock(&mutex);
                    status |= (TET_API_CALIBSTARTED);
                    pthread_mutex_unlock(&mutex);
                }
            }
            //             if( (status & TET_API_CALIBSTARTED) &&
            //                 (status & TET_API_ADDPOINT) ) {
            if( status & TET_API_CALIBSTARTED ) {
                mexPrintf("thread:LoadCalib=%d\n",LoadCalib);                                
                if(!LoadCalib){ //perform calibration
                    
                    // let eye tracker take samples at point - this is a blocking function
                    // and is concurrent with the drawing routine
                    //   1. we draw first (to get the subject to redirect gaze)
                    //   2. the eye tracker is slowed down a bit by taking a fairly large
                    //      number of calibration samples (see below, I found >16 to be ok,
                    //      I'm assuming a sampling rate of about 30Hz, so that should
                    //      be about half a second).
                    
                    // get server to draw calib point
                    signal_draw(true);
                    
                    // get eye tracker to start recording at this point, taking n samples
                    // blocking function!
                    if(Tet_CalibAddPoint(ci[calpoint], cj[calpoint], samples, gazeDataReceiver, NULL, 0) ) {
                        //store history and timestamp
                        //GetSecs -- source code copied from psychtoolbox
                        timeAbsTime=UpTime();
                        timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                        timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                        timeDouble=(double)timeUInt64;
                        secs= timeDouble / 1000000000;
                        
                        tmp_hist.timestamp = secs;
                        tmp_hist.TETcode = 3;
                        pthread_mutex_lock(&mutex);
                        TET_History.push_back(tmp_hist);
                        pthread_mutex_unlock(&mutex);
                    
                        mexPrintf("Problem adding calibration point:\n");
                        pthread_mutex_lock(&mutex);
                        mexPrintf("%f %f\n",ci[calpoint],cj[calpoint]);
                        PrintError();
                        Tet_Disconnect();
                        status &= ~(TET_API_CONNECTED);
                        status &= ~(TET_API_CALIBRATING);
                        pthread_mutex_unlock(&mutex);
                    }
                    else
                    {
                        //store history and timestamp
                        //GetSecs -- source code copied from psychtoolbox
                        timeAbsTime=UpTime();
                        timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                        timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                        timeDouble=(double)timeUInt64;
                        secs= timeDouble / 1000000000;
                        
                        tmp_hist.timestamp = secs;
                        tmp_hist.TETcode = 300;
                        pthread_mutex_lock(&mutex);
                        TET_History.push_back(tmp_hist);
                        pthread_mutex_unlock(&mutex);
                        
                        mexPrintf("adding calibration point...success:\n");
                        pthread_mutex_lock(&mutex);
                        mexPrintf("calpoint=%d \n",calpoint);
                        mexPrintf("%f %f\n",ci[calpoint],cj[calpoint]);
                        pthread_mutex_unlock(&mutex);
                    }
                    
                    //debug
                    //mexPrintf("sync=%d\n",sync);
                    // wait for server to finish drawing
                    
                    // advance to next calibration point
                    pthread_mutex_lock(&mutex);
                    calpoint++;
                    pthread_mutex_unlock(&mutex);
                    
                    block_server();
                    
                    // was that the last calibration point?
                    if( (calpoint >= cn) ) {
                        signal_draw(false);
                        
                        
                        // done, tell the eye tracker we're done
                        if(Tet_CalibCalculateAndSet()) {
                            //store history and timestamp
                            //GetSecs -- source code copied from psychtoolbox
                            timeAbsTime=UpTime();
                            timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                            timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                            timeDouble=(double)timeUInt64;
                            secs= timeDouble / 1000000000;
                            
                            tmp_hist.timestamp = secs;
                            tmp_hist.TETcode = 4;
                            pthread_mutex_lock(&mutex);
                            TET_History.push_back(tmp_hist);
                            pthread_mutex_unlock(&mutex);

                            mexWarnMsgTxt("Warning:Problem calculating and setting calibration\n");
                            PrintError();
                        }
                        else{
                            //store history and timestamp
                            //GetSecs -- source code copied from psychtoolbox
                            timeAbsTime=UpTime();
                            timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                            timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                            timeDouble=(double)timeUInt64;
                            secs= timeDouble / 1000000000;
                            
                            tmp_hist.timestamp = secs;
                            tmp_hist.TETcode = 400;
                            pthread_mutex_lock(&mutex);
                            TET_History.push_back(tmp_hist);
                            pthread_mutex_unlock(&mutex);
                            
                            mexPrintf("calculating and setting calibration...success\n");
                            
                            // hint: should perform a quality check here and save calibration
                            //       file for future use if calibration is good enough
                            if( quality )
                                delete [] quality;
                            qualityLenOrg = qualityLen;
                            mexPrintf("qualityLenOrg %d\n",qualityLenOrg);
                            quality = new STet_CalibAnalyzeData[qualityLen];
                            if(Tet_CalibGetResult(NULL,quality,&qualityLen)) {
                                //GetSecs -- source code copied from psychtoolbox
                                timeAbsTime=UpTime();
                                timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                                timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                                timeDouble=(double)timeUInt64;
                                secs= timeDouble / 1000000000;
                                
                                tmp_hist.timestamp = secs;
                                tmp_hist.TETcode = 5;
                                pthread_mutex_lock(&mutex);
                                TET_History.push_back(tmp_hist);
                                pthread_mutex_unlock(&mutex);
                                
                                mexWarnMsgTxt("Warning:Problem getting calibration result\n");
                                PrintError();
                            }
                            else{
                                //GetSecs -- source code copied from psychtoolbox
                                timeAbsTime=UpTime();
                                timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                                timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                                timeDouble=(double)timeUInt64;
                                secs= timeDouble / 1000000000;
                                
                                tmp_hist.timestamp = secs;
                                tmp_hist.TETcode = 500;
                                pthread_mutex_lock(&mutex);
                                TET_History.push_back(tmp_hist);
                                pthread_mutex_unlock(&mutex);

                                mexPrintf("Calibration results have been obtained\n");
                                mexPrintf("qualityLen %d\n",qualityLen);
                            }
                            if(qualityLen != qualityLenOrg) {
                                mexPrintf("qualityLen %d\n",qualityLen);
                                mexWarnMsgTxt("Warning: calib quality has different number of records\n");
                                mexWarnMsgTxt("Calibration results will be obtained again...\n");
                                //try again:
                                if( quality )
                                    delete [] quality;
                                qualityLenOrg = qualityLen;
                                quality = new STet_CalibAnalyzeData[qualityLen];
                                if(Tet_CalibGetResult(NULL,quality,&qualityLen)) {
                                    //GetSecs -- source code copied from psychtoolbox
                                    timeAbsTime=UpTime();
                                    timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                                    timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                                    timeDouble=(double)timeUInt64;
                                    secs= timeDouble / 1000000000;
                                    
                                    tmp_hist.timestamp = secs;
                                    tmp_hist.TETcode = 5;
                                    pthread_mutex_lock(&mutex);
                                    TET_History.push_back(tmp_hist);
                                    pthread_mutex_unlock(&mutex);
                                    
                                    mexWarnMsgTxt("Warning:Problem getting calibration result\n");
                                    PrintError();
                                }
                                else{
                                    //GetSecs -- source code copied from psychtoolbox
                                    timeAbsTime=UpTime();
                                    timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                                    timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                                    timeDouble=(double)timeUInt64;
                                    secs= timeDouble / 1000000000;
                                    
                                    tmp_hist.timestamp = secs;
                                    tmp_hist.TETcode = 500;
                                    pthread_mutex_lock(&mutex);
                                    TET_History.push_back(tmp_hist);
                                    pthread_mutex_unlock(&mutex);
                                    
                                    mexPrintf("Calibration results have been obtained\n");
                                }
                                mexPrintf("qualityLen %d\n",qualityLen);
                            }
                            

                            //save calibration
                            if(Tet_CalibSaveToFile(calibFile)) {
                                //GetSecs -- source code copied from psychtoolbox
                                timeAbsTime=UpTime();
                                timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                                timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                                timeDouble=(double)timeUInt64;
                                secs= timeDouble / 1000000000;
                                
                                tmp_hist.timestamp = secs;
                                tmp_hist.TETcode = 6;
                                pthread_mutex_lock(&mutex);
                                TET_History.push_back(tmp_hist);
                                pthread_mutex_unlock(&mutex);

                                mexWarnMsgTxt("Warning:Problem saving calibration\n");
                                PrintError();
                            }
                            else{
                                //GetSecs -- source code copied from psychtoolbox
                                timeAbsTime=UpTime();
                                timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                                timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                                timeDouble=(double)timeUInt64;
                                secs= timeDouble / 1000000000;
                                
                                tmp_hist.timestamp = secs;
                                tmp_hist.TETcode = 600;
                                pthread_mutex_lock(&mutex);
                                TET_History.push_back(tmp_hist);
                                pthread_mutex_unlock(&mutex);
                                
                                mexPrintf("Calibration have been saved\n");
                            }
                            
                        }
                        
                            pthread_mutex_lock(&mutex);
                            status &= ~(TET_API_CALIBSTARTED);
                            status &= ~(TET_API_CALIBRATING);
                            status |= TET_API_CALIBEND;
                            calpoint = 0;
                            pthread_mutex_unlock(&mutex);

                    }
                    
                }
                else{ //load calibration from file
                    mexErrMsgTxt("Load Calibration is not implemented yet!!\n");
                    mexPrintf("Have you arrived here\n");
                    mexPrintf("%s\n",calibFile);
                    
                    if(Tet_CalibGetResult(calibFile,quality,&qualityLen)) {
                        //GetSecs -- source code copied from psychtoolbox
                        timeAbsTime=UpTime();
                        timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                        timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                        timeDouble=(double)timeUInt64;
                        secs= timeDouble / 1000000000;
                        
                        tmp_hist.timestamp = secs;
                        tmp_hist.TETcode = 11;
                        pthread_mutex_lock(&mutex);
                        TET_History.push_back(tmp_hist);
                        pthread_mutex_unlock(&mutex);
                        mexWarnMsgTxt("Warning:Problem getting calibration result\n");
                        PrintError();
                    }
                    else{
                        //GetSecs -- source code copied from psychtoolbox
                        timeAbsTime=UpTime();
                        timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                        timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                        timeDouble=(double)timeUInt64;
                        secs= timeDouble / 1000000000;
                        
                        tmp_hist.timestamp = secs;
                        tmp_hist.TETcode = 110;
                        pthread_mutex_lock(&mutex);
                        TET_History.push_back(tmp_hist);
                        pthread_mutex_unlock(&mutex);
                        
                        mexPrintf("Calibration results have been obtained\n");
                    }
                    
                    if( Tet_CalibLoadFromFile(calibFile) ) {
                        //GetSecs -- source code copied from psychtoolbox
                        timeAbsTime=UpTime();
                        timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                        timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                        timeDouble=(double)timeUInt64;
                        secs= timeDouble / 1000000000;
                        
                        tmp_hist.timestamp = secs;
                        tmp_hist.TETcode = 9;
                        pthread_mutex_lock(&mutex);
                        TET_History.push_back(tmp_hist);
                        pthread_mutex_unlock(&mutex);

                        mexWarnMsgTxt("Warning:Problem loading calibration file\n");
                        PrintError();
                    }
                    else{
                        //GetSecs -- source code copied from psychtoolbox
                        timeAbsTime=UpTime();
                        timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                        timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                        timeDouble=(double)timeUInt64;
                        secs= timeDouble / 1000000000;
                        
                        tmp_hist.timestamp = secs;
                        tmp_hist.TETcode = 900;
                        pthread_mutex_lock(&mutex);
                        TET_History.push_back(tmp_hist);
                        pthread_mutex_unlock(&mutex);
                        
                        mexPrintf("Calibration has been loaded\n");

                        if(Tet_CalibGetResult(calibFile,quality,&qualityLen)) {
                            //GetSecs -- source code copied from psychtoolbox
                            timeAbsTime=UpTime();
                            timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                            timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                            timeDouble=(double)timeUInt64;
                            secs= timeDouble / 1000000000;
                            
                            tmp_hist.timestamp = secs;
                            tmp_hist.TETcode = 12;
                            pthread_mutex_lock(&mutex);
                            TET_History.push_back(tmp_hist);
                            pthread_mutex_unlock(&mutex);
                            
                            mexWarnMsgTxt("Warning:Problem getting calibration results\n");
                            PrintError();
                        }
                        else{
                            //GetSecs -- source code copied from psychtoolbox
                            timeAbsTime=UpTime();
                            timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                            timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                            timeDouble=(double)timeUInt64;
                            secs= timeDouble / 1000000000;
                            
                            tmp_hist.timestamp = secs;
                            tmp_hist.TETcode = 120;
                            pthread_mutex_lock(&mutex);
                            TET_History.push_back(tmp_hist);
                            pthread_mutex_unlock(&mutex);

                            mexPrintf("Calibration results have been obtained\n");
                        }
                        
                    }
                        pthread_mutex_lock(&mutex);
                        status &= ~(TET_API_CALIBSTARTED);
                        status &= ~(TET_API_CALIBRATING);
                        calpoint = 0;
                        pthread_mutex_unlock(&mutex);
                }
            }
        }
        else if( (status & TET_API_CONNECTED) &&
        (status & TET_API_SYNCHRONISE) ) {
            if( !Tet_SynchronizeTime(&Sec,&MicroSec) ) {
                //GetSecs -- source code copied from psychtoolbox
                timeAbsTime=UpTime();
                timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                timeDouble=(double)timeUInt64;
                secs= timeDouble / 1000000000;
                
                tmp_hist.timestamp = secs;
                tmp_hist.TETcode = 700;
                pthread_mutex_lock(&mutex);
                TET_History.push_back(tmp_hist);
                pthread_mutex_unlock(&mutex);
                
                mexPrintf("Synchronised maximal error in second: %ld\n",Sec);
                mexPrintf("Synchronised maximal error in microseconds: %ld\n",MicroSec);
            }
            else {
                //GetSecs -- source code copied from psychtoolbox
                timeAbsTime=UpTime();
                timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                timeDouble=(double)timeUInt64;
                secs= timeDouble / 1000000000;
                
                tmp_hist.timestamp = secs;
                tmp_hist.TETcode = 7;
                pthread_mutex_lock(&mutex);
                TET_History.push_back(tmp_hist);
                pthread_mutex_unlock(&mutex);

                mexWarnMsgTxt("Warning:Synchronisation failed\n");
                PrintError();
            }
            pthread_mutex_lock(&mutex);
            status &= ~(TET_API_SYNCHRONISE);
            status |= TET_API_SYNCHRONISED;
            pthread_mutex_unlock(&mutex);
        }
        else if( (status & TET_API_CONNECTED) &&
        (status & TET_API_RUNNING) ) {
            if( !(status & TET_API_RUNSTARTED) ) {
                // Start the subscription of gaze data.
                // The function will not return until Tet_Stop is called or there
                // is an error.
                // Therefore, the only place to to stop the eye tracker is in
                // the gazeDataReceiver callback.
                
                pthread_mutex_lock(&mutex);
                status |= (TET_API_RUNSTARTED);
                pthread_mutex_unlock(&mutex);
                
                //get some time informations... debug
                //mxArray *plhs;
                //double timestamp;
                //int tmp = mexCallMATLAB( 1, &plhs, 0, NULL, "GetSecs");
                //timestamp = mxGetScalar( plhs );
                
                firstTime = true;
                if(Tet_Start(gazeDataReceiver,NULL,0)) {
                    //GetSecs -- source code copied from psychtoolbox
                    timeAbsTime=UpTime();
                    timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                    timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                    timeDouble=(double)timeUInt64;
                    secs= timeDouble / 1000000000;
                    
                    tmp_hist.timestamp = secs;
                    tmp_hist.TETcode = 8;
                    pthread_mutex_lock(&mutex);
                    TET_History.push_back(tmp_hist);
                    pthread_mutex_unlock(&mutex);
                    
                    mexPrintf("Problem starting tracking! EyeTracker will disconnect...\n");
                    PrintError();
                    Tet_Disconnect();
                    pthread_mutex_lock(&mutex);
                    status &= ~(TET_API_RUNNING);
                    pthread_mutex_unlock(&mutex);
                }
                else{
                    //GetSecs -- source code copied from psychtoolbox
                    timeAbsTime=UpTime();
                    timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
                    timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
                    timeDouble=(double)timeUInt64;
                    secs= timeDouble / 1000000000;
                    
                    tmp_hist.timestamp = secs;
                    tmp_hist.TETcode = 800;
                    pthread_mutex_lock(&mutex);
                    TET_History.push_back(tmp_hist);
                    pthread_mutex_unlock(&mutex);

                    mexPrintf("starting track...success\n");
                }
                
            }
        }
        else if( (status & TET_API_CONNECTED) &&
        (status & TET_API_DISCONNECT) ) {
            Tet_Disconnect();
            pthread_mutex_lock(&mutex);
            status &= ~(TET_API_CONNECTED);
            status &= ~(TET_API_DISCONNECT);
            pthread_mutex_unlock(&mutex);
        }
        
    } /* while */
    
    // clean exit
    pthread_exit(NULL);
    
    return(0);
}


/////////////////////////////////////////////////////////////////////////////////////////////////
/* Demo Functions */

void *tobii_threadDEMO(void *ap)
{
    char		SerialDiodeController[65], SerialCamera[65];
    char		Error[255];
    char		Info[255];
    unsigned long	Sec,MicroSec;
    
  /* allow thread to be cancelled (asynchronously, e.g., immediately) */
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE,NULL);
    pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS,NULL);
    
  /* initialize tobii client - this sets up important internal */
  /* thread data as well as initializing the timer library */
    if(Tet_Init() != 0) {
        mexPrintf("problem initializing tobii\n");
        //    fprintf(stderr,"problem initializing tobii\n");
        //    return;
    }
    
  /* connect to tobii host */
    Tet_Connect(TOBII_HOST,TOBII_PORT,"logfile");
    
  /* perform system check (checks if camera and other things hooked up) */
    if(!Tet_PerformSystemCheck()) {
        mexPrintf("System Check apparently succeeded\n");
        //    fprintf(stderr,"System Check apparently succeeded\n");
    }
    else {
        mexPrintf("System Check apparently failed\n");
        //    fprintf(stderr,"System Check apparently failed\n");
    }
    
  /* get serial info */
    if(!Tet_GetSerialNumber(SerialDiodeController, SerialCamera)) {
        mexPrintf("Diode Controller serial #: %s\n",SerialDiodeController);
        mexPrintf("Camera serial #: %s\n",SerialCamera);
    }
    
  /* get info */
    if(!Tet_GetInfo(Info)) {
        mexPrintf("Info: %s\n",Info);
    }
    
  /* see if this works - I had a heck of a time porting this piece of */
  /* Microsoft-specific code */
  /* */
    if(!Tet_SynchronizeTime(&Sec, &MicroSec)) {
        mexPrintf("Synchronized maximal error (seconds): %ld\n",Sec);
        mexPrintf("Synchronized maximal error (microseconds): %ld\n",MicroSec);
    }
    
    Tet_Disconnect();
    
  /* clean exit */
    pthread_exit(NULL);
    
}

int DemoConnect()
{
    
  /* TODO:
   * Before starting, need to initialize client by putting it in its
   * own thread - this now seems to be a requirement, in particular,
   * the tobii client needs to set up its local variable so that
   *   SGlobal		*pG = TlsGetValue(m_tlsindex);
   * succeeds, which is the same as pthread_getspecific(m_tlsindex)
   * so we have to initialize the thread and also assign that thread
   * its local representation of pG.
   */
    
    pthread_t	threadDemo;
    
    if(pthread_create(&threadDemo,NULL,&tobii_threadDEMO,NULL) != 0) {
        mexPrintf("can't create tobii thread\n");
        
    }
    
    pthread_join(threadDemo,NULL);
    
    return 0;
}

/* End of Demo Functions */
/////////////////////////////////////////////////////////////////////////////////////////////////

void gazeDataReceiver(ETet_CallbackReason reason, void *pData, void *pApplicationData)
{
    STet_GazeData	*pGazeData=NULL;
    
    //get time stamp
    // for retrieving time in secs
    double				timeDouble, secs;
    AbsoluteTime		timeAbsTime;
    Nanoseconds			timeNanoseconds;
    UInt64				timeUInt64;
    double timestamp;    
    
    if(recordFlag){
        //GetSecs -- source code copied from psychtoolbox
        timeAbsTime=UpTime();
        timeNanoseconds=AbsoluteToNanoseconds(timeAbsTime);
        timeUInt64=UnsignedWideToUInt64(timeNanoseconds);
        timeDouble=(double)timeUInt64;
        secs= timeDouble / 1000000000;
        
        timestamp = secs;

        vectorTimeStamp.push_back(timestamp);
    }
    
    //copy gaze data
    pGazeData = (STet_GazeData *)pData;
    
    switch(reason) {
        case TET_CALLBACK_GAZE_DATA:
            if( (status & TET_API_CONNECTED) &&
            ( (status & TET_API_RUNNING) || (status & TET_API_CALIBRATING) ) ) {
                //  PrintGazeData(pGazeData);	// for debugging
                // copy to my mgr data structure (should use mutex here)
                // values are normalized (0,1) with (0,0) being top-left
                pthread_mutex_lock(&mutex);
                tim_Sec = pGazeData->timestamp_sec;
                tim_mSec = pGazeData->timestamp_microsec;
                xl = pGazeData->x_gazepos_lefteye;
                yl = pGazeData->y_gazepos_lefteye;
                xr = pGazeData->x_gazepos_righteye;
                yr = pGazeData->y_gazepos_righteye;
                cxl = pGazeData->x_camerapos_lefteye;
                cyl = pGazeData->y_camerapos_lefteye;
                cxr = pGazeData->x_camerapos_righteye;
                cyr = pGazeData->y_camerapos_righteye;
                
                diamL = pGazeData->diameter_pupil_lefteye;
                diamR = pGazeData->diameter_pupil_righteye;
                distL = pGazeData->distance_lefteye;
                distR = pGazeData->distance_righteye;
                valL = pGazeData->validity_lefteye;
                valR = pGazeData->validity_righteye;
                pthread_mutex_unlock(&mutex);
                
                pthread_mutex_lock(&mutex);
                if(recordFlag)
                    gazeArray.push_back(*pGazeData);                    
                pthread_mutex_unlock(&mutex);
                
            }
            break;
        case TET_CALLBACK_TIMER:
            break;
    }
    if( (status & TET_API_CONNECTED) &&
    (status & TET_API_RUNNING) &&
    (status & TET_API_STOP) ) {
        if(Tet_Stop()) {
            mexPrintf("Problem stopping tobii\n");
            PrintError();
            Tet_Disconnect();
        } else {
            pthread_mutex_lock(&mutex);
            status &= ~(TET_API_RUNNING);
            status &= ~(TET_API_RUNSTARTED);
            status &= ~(TET_API_STOP);
            pthread_mutex_unlock(&mutex);
        }
    }
}


void PrintGazeData(STet_GazeData *pGazeData)
{
/*    mexPrintf("%u%06u %.3f %.3f %.3f %.3f %.3f %u %.3f %.3f %.3f %.3f %.3f %u \n",
    pGazeData->timestamp_sec,
    pGazeData->timestamp_microsec,
    pGazeData->x_gazepos_lefteye,
    pGazeData->y_gazepos_lefteye,
    pGazeData->x_camerapos_lefteye,
    pGazeData->y_camerapos_lefteye,
    pGazeData->diameter_pupil_lefteye,
    pGazeData->validity_lefteye,
    pGazeData->x_gazepos_righteye,
    pGazeData->y_gazepos_righteye,
    pGazeData->x_camerapos_righteye,
    pGazeData->y_camerapos_righteye,
    pGazeData->diameter_pupil_righteye,
    pGazeData->validity_righteye);
 */
    //    mexPrintf("PRINT VALIDITY??\n");
    //    mexPrintf("%u %u \n",
    //    pGazeData->validity_lefteye,
    //    pGazeData->validity_righteye);
    
}


/*******************************************************************************/
/*                                 SAVE DATA                                   */
void SaveDataEyeTrack()
{
    std::ofstream fout;
    if( strcmp( mxArrayToString(my_mexInputArg(3)), "APPEND" ) )
        fout.open(filePathTobii, ofstream::out|ofstream::trunc);
    else
        fout.open(filePathTobii, ofstream::out|ofstream::app);
        
        if (!fout) //try to use a default name
        {
            mexWarnMsgTxt("File couldn't open!\n");
            mexWarnMsgTxt("Attempt to save data to an alternative filename...\n");
            fout.open("TestDataTobii.txt");
            if(!fout)
            {
                mexWarnMsgTxt("Saving data...failed!!!\n");
                return;
            }
        }
        
        
        //    VectorTimeStamp::iterator iclTime = vectorTimeStamp.begin();
        fout.precision(14);   
        VectorTimeStamp::iterator iclTime = vectorTimeStamp.begin();        
        for (VectorGaze::iterator icl = gazeArray.begin(); icl != gazeArray.end(); icl++){
            fout << (*icl).timestamp_sec <<" "
            << (*icl).timestamp_microsec <<" "
            //           << (*iclTime) <<" "
            << (*icl).x_gazepos_lefteye <<" "
            << (*icl).y_gazepos_lefteye <<" "
            << (*icl).x_gazepos_righteye <<" "
            << (*icl).y_gazepos_righteye <<" "
            << (*icl).x_camerapos_lefteye <<" "
            << (*icl).y_camerapos_lefteye <<" "
            << (*icl).x_camerapos_righteye <<" "
            << (*icl).y_camerapos_righteye <<" "
            << (*icl).validity_lefteye <<" "
            << (*icl).validity_righteye <<" "
            << (*icl).diameter_pupil_lefteye <<" "
            << (*icl).diameter_pupil_righteye <<" "
            << (*icl).distance_lefteye <<" "
            << (*icl).distance_righteye <<" "
            << showpoint << *iclTime <<" "
            << std::endl;
            
            if( iclTime != vectorTimeStamp.end() )
                iclTime++;
        }
            fout.close();
            
}

void DiscardDataEyeTrack()
{
    pthread_mutex_lock(&mutex);
    gazeArray.clear();
    pthread_mutex_unlock(&mutex);
}

void SaveDataEvents()
{
    std::ofstream fout;
    if( strcmp( mxArrayToString(my_mexInputArg(3)), "APPEND" ) )
        fout.open(filePathEvents, ofstream::out|ofstream::trunc);
    else
        fout.open(filePathEvents, ofstream::out|ofstream::app);
        
        if (!fout) //try to use a default name
        {
            mexWarnMsgTxt("File couldn't open!\n");
            mexWarnMsgTxt("Attempt to save events to an alternative filename...\n");
            fout.open("TestDataEvents.txt");
            if(!fout)
            {
                mexWarnMsgTxt("Saving events...failed!!!\n");
                return;
            }
        }
        
        fout.precision(14);
        for(VectorTimeStamp::iterator iclTime = vectorTimeStamp.begin(); iclTime != vectorTimeStamp.end(); iclTime++ ){
            fout << "#START "<< showpoint <<(*iclTime) <<std::endl;
            break;
            
        }
        
        
        for (EventDataVector::iterator icl = EventVector.begin(); icl != EventVector.end(); icl++){
            fout << (*icl).code <<" ";
            fout.precision(14);
            fout << showpoint <<(*icl).time <<" ";
            fout.precision(14);
            fout << (*icl).duration <<" "
            << (*icl).details <<" "
            << std::endl;
        }
        fout.close();
}


void DiscardDataEvents()
{
//     for (EventDataVector::iterator icl = EventVector.begin(); icl != EventVector.end(); icl++){
//         //        mxFree( (*icl).code );
//         //        mxFree( (*icl).details );
//     }
    
    EventVector.clear();
}
/*******************************************************************************/
/* Puts double matrix in matlab variable in the array of return argument for mex*/
void my_mexReturnMatrix(int rows, int cols, double *vals)
{
    double *pr;
    if((gret_args>gnlhs) && (gret_args>1))
    {
        mexPrintf("Is this the problem?\n");
        return;
    }
    gplhs[gret_args] = mxCreateDoubleMatrix( rows, cols, mxREAL);
    if( gplhs[gret_args] == NULL)
        mexErrMsgTxt("Matrix creation error");
    pr = (double *)mxGetPr(gplhs[gret_args]);
    memcpy(pr,vals,rows*cols*sizeof(double));
    gret_args++;
}

/**********************************************************************************************/
/* Returns true if specified argument exist                                                  */
int my_mexIsInputArgOK(const int argno)
{
    if(gnrhs>argno)
        return 1;
    
    return 0;
}

/******************************************************************************************************/
/* Returns specified input argument as scalar. Global and error tolerant replacement for mxGetScalar */
const mxArray *my_mexInputArg(const int argno)
{
    if(!my_mexIsInputArgOK(argno))
    {
        mexErrMsgTxt("Missing input argument.");
        return 0;
    }
    return gprhs[argno];
}

/****************************************************************************************************************/
/* Returns pointer to static buffer (max 80 chars) holding a string in argument argno Global and error tolerant */
const char *my_mexInputOptionString(const int argno)
{
    static char buff[80+1];
    buff[0]=0;
    if(my_mexIsInputArgOK(argno))
        if(mxIsChar(my_mexInputArg(argno)))
            mxGetString(my_mexInputArg(argno),buff,80);
    return buff;
}

/******************************************************************************************************/
/* Returns specified input argument as scalar. Global and error tolerant replacement for mxGetScalar */
double my_mexInputScalar(const int argno)
{
    if(mxIsChar(my_mexInputArg(argno)))
        return atof(my_mexInputOptionString(argno));
    else
        return mxGetScalar(my_mexInputArg(argno));
}

/***********************************************************************/
int myoptstrcmp(const char *s1,const char *s2)
{
    int val;
    while( (val= toupper(*s1) - toupper(*s2))==0 ){
        if(*s1==0 || *s2==0) return 0;
        s1++;
        s2++;
        while(*s1=='_') s1++;
        while(*s2=='_') s2++;
    }
    return val;
}

/***********************************************************************/
void Print_Start_Message(){
    mexPrintf(
    "\n===============================================================================\n"
    "Loaded tobii MEX-file for interfacing the TETSERVER with Matlab.\n"
    "This program is distributed with the hope that it will be useful,\n"
    "but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY\n"
    "OR FITNESS FOR A PARTICULAR PURPOSE.\n"
    "UNDER NO CIRCUMSTANCES SHALL THE AUTHORS BE LIABLE FOR ANY INCIDENTAL,\n"
    "SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES ARISING OUT OF OR RELATING TO\n"
    "THIS PROGRAM.\n"
    "\n"
    "Written by Fani Deligianni, email: f.deligianni@bbk.ac.uk \n"
    "Centre of Brain and Cognitive Development, Birkbeck University, London, UK. \n"
    "   http://www.cbcd.bbk.ac.uk/ \n\n"
    "===============================================================================\n\n"
    );
}

/****************************************************************************/
/* This function is called on unloading of mex-file                         */
void CleanUpMex(void)
{
    
    mexWarnMsgTxt("Unloading TOBII mex file. Threads will be destroyed!\n");
    //clear threads etc.
    
    //close communication
    StopTobii();
    mexPrintf("Stop tobii\n");
    DisconnectTobii();
    mexPrintf("Disconnect tobii\n");
    pthread_mutex_lock(&mutex);
    status |= (TET_API_FINISHED);
    pthread_mutex_unlock(&mutex);
    mexPrintf("Finished tobii\n");
    
    
//    mex_call_counter = 0;
    
//     if(ci){
//         mxFree(ci);
//         ci = NULL;
//     }
//     if(cj){
//         mxFree(cj);
//         cj = NULL;
//     }
//     
//     cn = 9;          //number of calibration points
//     calpoint = 0;
//     
//     if(quality)
//         mxFree(quality);
//     quality = NULL;
//     
//     //clear filepaths
//     if( filePathTobii){
//         //delete filePathTobii;
//         mxFree(filePathTobii);
//         filePathTobii = NULL;
//     }
//     if( filePathEvents){
//         //delete filePathEvents;
//         mxFree(filePathEvents);
//         filePathEvents = NULL;
//     }
//     
//     if( calibFile){
//         //delete filePathEvents;
//         mxFree(calibFile);
//         calibFile = NULL;
//     }
    
    //discard any eye tracking and event data
    DiscardDataEyeTrack();
    DiscardDataEvents();
    //clear history
    TET_History.clear();
    
    xl=-1.0f;		// left eye pos
    yl=-1.0f;		// left eye pos
    xr=-1.0f;		// right eye pos
    yr=-1.0f;		// right eye pos
    cxl=-1.0f;	// left camera eye pos
    cyl=-1.0f;	// left camera eye pos
    cxr=-1.0f;	// right camera eye pos
    cyr=-1.0f;	// right camera eye pos
    tim_Sec=0;  // time in sec
    tim_mSec=0; // time in msec
    diamL =0.0f;
    diamR =0.0f;
    distL =0.0f;
    distR =0.0f;
    valL =0;
    valR =0;
        
    recordFlag = false;
    
    //Server
    synchronous = false;
    done_flag = false;
    request_flag = false;
    
//     if(pthread_cancel(thread) != 0)
//         mexPrintf("warning: can't cancel tobii thread\n");
//     else
//         mexPrintf("cancel tobii thread...success\n");
//     
//     
//     if(pthread_mutex_destroy(&mutex) != 0)
//         mexPrintf("warning: can't destroy mutex\n");
//     else
//         mexPrintf("destroy mutex...success\n");
    
//    status = 0x0000;

    mexPrintf("CleanUpMex...passed\n");
    
    //IFWINDOWS(   WSACleanup();  ); //if win32 is defined
}

void CleanUp(void)
{
    
    //clear threads etc.
    
    //close communication
    StopTobii();
    DisconnectTobii();
    pthread_mutex_lock(&mutex);
    status |= (TET_API_FINISHED);
    pthread_mutex_unlock(&mutex);
    
    
    mex_call_counter = 0;
    
//     if(ci){
//         mxFree(ci);
//         ci = NULL;
//     }
//     if(cj){
//         mxFree(cj);
//         cj = NULL;
//     }
//     
//     cn = 9;          //number of calibration points
//     calpoint = 0;
//     
//     if(quality)
//         mxFree(quality);
//     quality = NULL;
//     
//     //clear filepaths
//     if( filePathTobii){
//         //delete filePathTobii;
//         mxFree(filePathTobii);
//         filePathTobii = NULL;
//     }
//     if( filePathEvents){
//         //delete filePathEvents;
//         mxFree(filePathEvents);
//         filePathEvents = NULL;
//     }
//     
//     if( calibFile){
//         //delete filePathEvents;
//         mxFree(calibFile);
//         calibFile = NULL;
//     }
    
    //discard any eye tracking and event data
    DiscardDataEyeTrack();
    DiscardDataEvents();
    //clear history
    TET_History.clear();
    
    xl=-1.0f;		// left eye pos
    yl=-1.0f;		// left eye pos
    xr=-1.0f;		// right eye pos
    yr=-1.0f;		// right eye pos
    cxl=-1.0f;	// left camera eye pos
    cyl=-1.0f;	// left camera eye pos
    cxr=-1.0f;	// right camera eye pos
    cyr=-1.0f;	// right camera eye pos
    tim_Sec=0;  // time in sec
    tim_mSec=0; // time in msec
    diamL =0.0f;
    diamR =0.0f;
    distL =0.0f;
    distR =0.0f;
    valL =0.0f;
    valR =0.0f;
        
    recordFlag = false;
    
    //Server
    synchronous = false;
    done_flag = false;
    request_flag = false;
        
    status = 0x0000;

    mexPrintf("CleanUp...passed\n");
    
    //IFWINDOWS(   WSACleanup();  ); //if win32 is defined
}


/****************************************************************************/
/* Callbacks                                                                */

void StopTobii()
{
    pthread_mutex_lock(&mutex);
    status |= (TET_API_STOP);
    pthread_mutex_unlock(&mutex);
}

void DisconnectTobii()
{
    pthread_mutex_lock(&mutex);
    status |= (TET_API_DISCONNECT);
    pthread_mutex_unlock(&mutex);
}

void ConnectTobii()
{
    //check if it is connected and disconnect
    if(status & TET_API_CONNECTED) {
        //check if it is tracking - stop
        if(status & TET_API_RUNNING) {
            StopTobii();
        }
        DisconnectTobii();
    }
    
    //connect to tobii
    pthread_mutex_lock(&mutex);
    status |= (TET_API_CONNECT);
    pthread_mutex_unlock(&mutex);
    
}

bool InitPntsTobii()
{
    mwSize numDim;
    const mwSize *dim;
    int tmpdim, tmpelem;
    double *pntdata;
    int i;
    
    if(gnrhs<2){
        mexErrMsgTxt("Calibration matrix has not beed defined.\n");
    }
    
    numDim = mxGetNumberOfDimensions(gprhs[1]);
    if( numDim != 2){
        mexErrMsgTxt("Number of Dimensions of calibration matrix should be two.\n");
        return false;
    }
    
    dim = mxGetDimensions(gprhs[1]);
    tmpdim = (int)(*dim);
    
    if( tmpdim < 2 ){
        mexErrMsgTxt("Calibration matrix should have at least two points.\n");
        return false;
    }
    
    pntdata = mxGetPr(gprhs[1]);
    tmpelem = mxGetNumberOfElements(gprhs[1]);

    pthread_mutex_lock(&mutex);
    
    if(ci)
        delete ci;
    if(cj)
        delete cj;
    
    ci = new float[tmpdim];
    cj = new float[tmpdim];
    
    for( i=0; i<tmpdim; i++){
        ci[i] = (float)(pntdata[i]);
    }
    for( i=0; i<tmpdim; i++){
        cj[i] = (float)(pntdata[i+tmpdim]);
    }
    
    cn = tmpdim;
    
    pthread_mutex_unlock(&mutex);
    
    return true;
}

void CalibrateTobii()
{
    //check if it is connected
    if( (status & TET_API_CONNECTED) &&
        !(status & TET_API_CALIBRATING) &&
        !(status & TET_API_CALIBRATING) ) {
        //initialise calibration points
        if( !InitPntsTobii() )
            return;
        if( gnrhs==4 ){
            //store flag that shows whether an old calibratin file will be used
             if( my_mexInputScalar(2) == 1){
                 pthread_mutex_lock(&mutex);
                 LoadCalib = true; //load calibration data from file
                 pthread_mutex_unlock(&mutex);
                 
             }
             else{
                 pthread_mutex_lock(&mutex);
                 LoadCalib = false; //do a new calibration
                 pthread_mutex_unlock(&mutex);
             }
            //store calibration filename
             pthread_mutex_lock(&mutex);
             if(calibFile)
                 delete calibFile;
             calibFile = mxArrayToString(my_mexInputArg(3));
             pthread_mutex_unlock(&mutex);
       }
        
        pthread_mutex_lock(&mutex);
        mexPrintf("loadCalib=%d\n",LoadCalib);
        pthread_mutex_unlock(&mutex);
        
        pthread_mutex_lock(&mutex);
        status &= ~(TET_API_CALIBEND);
        status |= (TET_API_CALIBRATING);
        pthread_mutex_unlock(&mutex);
    }
    else
        mexWarnMsgTxt("Warning:Tobii is not connected -- calibration not attempted\n");
}

void AddCalibrationTobii()
{
    if( (status & TET_API_CONNECTED) &&
    (status & TET_API_CALIBRATING) &&
    (status & TET_API_CALIBSTARTED)
    ) {
        block_draw();
    }
    else
        mexWarnMsgTxt("Tobii is not connected or calibration has not initialised properly\n");
    
}

void CalibrationAnalysisTobii()
{
    double *calibrationData;
    int numfields = 8;
    int i;

    //return quality data or return error
    if( quality ){
        calibrationData = new double[numfields*qualityLen];
        for(i=0; i<qualityLen; i++){
            calibrationData[0*qualityLen+i] = (double)(quality[i].truePointX); //X coordinate for displayed point
            calibrationData[1*qualityLen+i] = (double)(quality[i].truePointY); //X coordinate for displayed point
            calibrationData[2*qualityLen+i] = (double)(quality[i].leftMapX);   //Left eye,X coordinate for mapped point
            calibrationData[3*qualityLen+i] = (double)(quality[i].leftMapY);   //Left eye, Y coordinate for mapped point
            calibrationData[4*qualityLen+i] = (double)(quality[i].leftValidity);//Left eye -1->not found, 0->found but not used, 1->used
            calibrationData[5*qualityLen+i] = (double)(quality[i].rightMapX);  //Right eye,X coordinate for mapped point
            calibrationData[6*qualityLen+i] = (double)(quality[i].rightMapY);  //Right eye,Y coordinate for mapped point
            calibrationData[7*qualityLen+i] = (double)(quality[i].rightValidity);//Right eye -1->not found, 0->found but not used, 1->used
        }
        my_mexReturnMatrix(qualityLen,numfields,calibrationData);
    }
    else {
        calibrationData = new double[1];
        calibrationData[0] = 0.0;
        my_mexReturnMatrix(1,1,calibrationData);
    }
    
    delete [] calibrationData;
      
}


void DrewPointTobii()
{
    if( (status & TET_API_CONNECTED) &&
    (status & TET_API_CALIBRATING) &&
    (status & TET_API_CALIBSTARTED) ) {
        signal_server(); //unblock thread
    }
}

void RunTobii()
{
    if(status & TET_API_CONNECTED) {
        pthread_mutex_lock(&mutex);
        status |= (TET_API_RUNNING);
        pthread_mutex_unlock(&mutex);
    }
    else
        mexWarnMsgTxt("Tobii is not connected -- Tracking command will be ignored\n");
}

void GetSampleTobii()
{
    int i;
    double gazeDataTemp[12] = {0};
    const int numFields = 12;
    
    double *pr;
    gplhs[gret_args] = mxCreateDoubleMatrix( 1, numFields, mxREAL);
    if( gplhs[gret_args] == NULL)
        mexErrMsgTxt("Matrix creation error");
    pr = (double *)mxGetPr(gplhs[gret_args]);

    if( (status & TET_API_CONNECTED) ){
        pthread_mutex_lock(&mutex);
        pr[0]=(double)(xl);
        pr[1]=(double)(yl);
        pr[2]=(double)(xr);
        pr[3]=(double)(yr);
        pr[4]=(double)(tim_Sec);
        pr[5]=(double)(tim_mSec);
        pr[6]=(double)(valL);
        pr[7]=(double)(valR);
        pr[8]=(double)(cxl);
        pr[9]=(double)(cyl);
        pr[10]=(double)(cxr);
        pr[11]=(double)(cyr);
        
        pthread_mutex_unlock(&mutex);
    }
    else
        for(i=0;i<numFields;i++)
            pr[i] = -1.0;
        
//    memcpy(pr,vals,rows*cols*sizeof(double));
    gret_args++;

//    my_mexReturnMatrix(1,numFields,gazeDataTemp);
}


void GetSampleTobii_ext()
{
    int i;
    const int numFields = 16;
    
    double *pr;
    gplhs[gret_args] = mxCreateDoubleMatrix( 1, numFields, mxREAL);
    if( gplhs[gret_args] == NULL)
        mexErrMsgTxt("Matrix creation error");
    pr = (double *)mxGetPr(gplhs[gret_args]);
	
    if( (status & TET_API_CONNECTED) ){
        pthread_mutex_lock(&mutex);
        pr[0]=(double)(xl);
        pr[1]=(double)(yl);
        pr[2]=(double)(xr);
        pr[3]=(double)(yr);
        pr[4]=(double)(tim_Sec);
        pr[5]=(double)(tim_mSec);
        pr[6]=(double)(valL);
        pr[7]=(double)(valR);
        pr[8]=(double)(cxl);
        pr[9]=(double)(cyl);
        pr[10]=(double)(cxr);
        pr[11]=(double)(cyr);
        pr[12]=(double)(distL);
        pr[13]=(double)(distR);
        pr[14]=(double)(diamL);
        pr[15]=(double)(diamR);
        
        pthread_mutex_unlock(&mutex);
    }
    else
        for(i=0;i<numFields;i++)
            pr[i] = -1.0;
	
    gret_args++;
}

void SynchTobii()
{
    if( (status & TET_API_CONNECTED) ){
        pthread_mutex_lock(&mutex);
        status &= ~(TET_API_SYNCHRONISED);
        status |= (TET_API_SYNCHRONISE);
        pthread_mutex_unlock(&mutex);

        
    }
    else
        mexWarnMsgTxt("Tobii is not connected -- synchronisation not attempted\n");
}

void EventTobii()
{
    //error tests
    if( !mxIsChar(my_mexInputArg(1)) )
        mexErrMsgTxt("Second Argument should be a string specifing the name of the event.\n");
    if(! mxIsNumeric(my_mexInputArg(2)) )
        mexErrMsgTxt("starttime should be a numeric value.\n");
    if(! mxIsNumeric(my_mexInputArg(3)) )
        mexErrMsgTxt("duration should be a numeric value.\n");
    for( int i=4; i<gnrhs; i++ )
    {
        if(i%2){ //it should be numeric
            if(! mxIsNumeric(my_mexInputArg(i)) )
                mexErrMsgTxt("key value should be numeric.\n");
        }
        else{
            if( !mxIsChar(my_mexInputArg(i)) )
                mexErrMsgTxt("key name should be a string.\n");
        }
    }
    
    //store values
    EVENTData eventNow;
    eventNow.code = mxArrayToString( my_mexInputArg(1) );
    eventNow.time = mxGetScalar( my_mexInputArg(2) );
    eventNow.duration = mxGetScalar( my_mexInputArg(3) );
    
    //ostringstream details;
    ostringstream details;
    for( int i=4; i<gnrhs; i++ )
    {
        if(i%2){ //it should be numeric
            details.precision(14);
            details << mxGetScalar( my_mexInputArg(i) );
            details << " ";
        }
        else{
            details << mxArrayToString( my_mexInputArg(i) );
            details << " ";
        }
    }
    
    int len = details.str().size();
    eventNow.details = new char[len+1];
    strcpy( eventNow.details, (char*)details.str().c_str() );
    
    
    EventVector.push_back(eventNow);
    
}

void RecordTobii()
{
    //synchronise clocks
    //SynchTobii();
    
    //start recording
    pthread_mutex_lock(&mutex);
    recordFlag = true;
    pthread_mutex_unlock(&mutex);
    
}

void StopRecordTobii()
{
    pthread_mutex_lock(&mutex);
    recordFlag = false;
    pthread_mutex_unlock(&mutex);
}

void SaveDataTobii()
{
    if( filePathTobii)
        delete filePathTobii;
    if( filePathEvents)
        delete filePathEvents;
    
    filePathTobii = NULL;
    filePathEvents = NULL;
    
    filePathTobii = mxArrayToString(my_mexInputArg(1));
    filePathEvents = mxArrayToString(my_mexInputArg(2));
    SaveDataEyeTrack();
    SaveDataEvents();
}

void DiscardDataTobii()
{
    DiscardDataEyeTrack();
    DiscardDataEvents();
}

void DiscardHistory()
{
    pthread_mutex_lock(&mutex);
    TET_History.clear();
    pthread_mutex_unlock(&mutex);    
}

void GetStatusTobii()
{
    double tmp_status[12] = {0};
    unsigned long tmp = 0;
    
    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_CONNECT;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[0] = 1;
    else
        tmp_status[0] = 0;
    
    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_CONNECTED;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[1] = 1;
    else
        tmp_status[1] = 0;
    
    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_DISCONNECT;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[2] = 1;
    else
        tmp_status[2] = 0;
    
    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_CALIBRATING;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[3] = 1;
    else
        tmp_status[3] = 0;

    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_CALIBSTARTED;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[4] = 1;
    else
        tmp_status[4] = 0;

    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_RUNNING;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[5] = 1;
    else
        tmp_status[5] = 0;

    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_RUNSTARTED;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[6] = 1;
    else
        tmp_status[6] = 0;

    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_STOP;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[7] = 1;
    else
        tmp_status[7] = 0;

    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_FINISHED;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[8] = 1;
    else
        tmp_status[8] = 0;

    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_SYNCHRONISE;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[9] = 1;
    else
        tmp_status[9] = 0;

    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_CALIBEND;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[10] = 1;
    else
        tmp_status[10] = 0;

    pthread_mutex_lock(&mutex);
    tmp = status & TET_API_SYNCHRONISED;    
    pthread_mutex_unlock(&mutex);
    if(tmp)
        tmp_status[11] = 1;
    else
        tmp_status[11] = 0;
    

    my_mexReturnMatrix(1,12,tmp_status);
        
    // if there is a second return argument
    // return history
    if( gnlhs ==2 )
    {
        int count = 0;

        pthread_mutex_lock(&mutex);
        int rows = TET_History.size();
        double *tmphist = new double[rows*2];
        for(Vector_history::iterator iclHist = TET_History.begin(); iclHist != TET_History.end(); iclHist++ ){
            tmphist[count] = double( (*iclHist).TETcode );
            tmphist[rows+count] = (double)( (*iclHist).timestamp );
            count = count+1;
        }
        pthread_mutex_unlock(&mutex);
        
        my_mexReturnMatrix(rows,2,tmphist);
        delete [] tmphist;
    }
}

/*****************************************************************/
/*                                                               */
/*    ----Main function that is called from matlab--------       */
/*                                                               */
void mexFunction(
int           nlhs,           /* number of expected outputs */
mxArray       *plhs[],        /* array of pointers to output arguments */
int           nrhs,           /* number of inputs */
const mxArray *prhs[]         /* array of pointers to input arguments */
)
{
    char fun[80+1];
    double* tmp;
    double point[2];
    
    //print welcome message
    mex_call_counter++;
    if( mex_call_counter == 1 )
    {
        Print_Start_Message();
        
        //initCalPoints();
        
        //initialise threads etc
        pthread_mutex_init(&mutex,NULL);
        pthread_cond_init(&request,NULL);
        pthread_cond_init(&done,NULL);
        
        if(pthread_create(&thread,NULL,&tobii_thread,NULL) != 0) {
            mexPrintf("can't create tobii thread\n");
        }
        else
            mexPrintf("create tobii thread...success\n");
        
        mexAtExit(CleanUpMex);
    }
    
    /* GLOBAL IN-OUT ARGUMENTS */
    gnlhs=nlhs;       /* number of expected outputs */
    gplhs=plhs;       /* array of pointers to output arguments */
    gnrhs=nrhs;       /* number of inputs */
    gprhs=prhs;       /* array of pointers to input arguments */
    gret_args=0;      /* No return argumens returned */
    
    
    if(mxIsChar(my_mexInputArg(0))){
        /* GET FIRST ARGUMENT -- The "function" name */
        strncpy(fun,my_mexInputOptionString(0),80);
        
        if(myoptstrcmp(fun,"GET_SAMPLE")==0){
            GetSampleTobii();
            return;
        }
		
        if(myoptstrcmp(fun,"GET_SAMPLE_EXT")==0){
            GetSampleTobii_ext();
            return;
        }
        
        /* Find of the function name corresponds to a non connection associated function */
        if(myoptstrcmp(fun,"DEMO")==0){
            mexPrintf("\n This is a DEMO function that it will connect to the Tobii\n");
            DemoConnect();
            return;
        }
        
        if(myoptstrcmp(fun,"CONNECT")==0){
            //check input arguments
            if(nrhs<1)
                mexErrMsgTxt("IP adress of host computer hasn't been specified.\n");
            if( !mxIsChar(my_mexInputArg(1) ) )
                mexErrMsgTxt("IP address should be a string of numbers.\n");
            if(nrhs<1)
                mexErrMsgTxt("Port of host computer hasn't been specified.\n");
                        
            //define new host address
            pthread_mutex_lock(&mutex);
            strncpy(TOBII_HOST, my_mexInputOptionString(1),20);
            pthread_mutex_unlock(&mutex);

            pthread_mutex_lock(&mutex);
            TOBII_PORT =  (short unsigned int)my_mexInputScalar(2);
            pthread_mutex_unlock(&mutex);
            
            mexPrintf("\n Connecting to EyeTracker...\n");
            ConnectTobii();
            
            return;
        }
        
        if(myoptstrcmp(fun,"START_CALIBRATION")==0){
            //check input arguments
            if(nrhs<1)
                mexErrMsgTxt("Calibration Matrix has not been specified\n");
            CalibrateTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"ADD_CALIBRATION_POINT")==0){
            AddCalibrationTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"CALIBRATION_ANALYSIS")==0){
            CalibrationAnalysisTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"DREW_POINT")==0){
            mexPrintf("calibration point was displayed\n");
            DrewPointTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"START_TRACKING")==0){
            mexPrintf("Start Tracking...\n");
            RunTobii();
            return;
        }
                
        if(myoptstrcmp(fun,"SYNCHRONISE")==0){
            SynchTobii();
            return;
        }
        
        
        if(myoptstrcmp(fun,"EVENT")==0){
            if(nrhs<4)
                mexErrMsgTxt("EVENT should have at least three fields:Name,StartTime,Duration.\n");
            if(nrhs%2 != 0)
                mexErrMsgTxt("An even number of arguments should provided to this function.\n");
            EventTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"RECORD")==0){
            RecordTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"STOP_RECORD")==0){
            StopRecordTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"SAVE_DATA")==0){
            //check input arguments
            if(nrhs<1)
                mexErrMsgTxt("FileNames hasn't been specified.\n");
            if( !mxIsChar(my_mexInputArg(1) ) )
                mexErrMsgTxt("Filenames should be a string.\n");
            if(nrhs<2)
                mexErrMsgTxt("Event's FileName hasn't been specified.\n");
            if( !mxIsChar(my_mexInputArg(2) ) )
                mexErrMsgTxt("Event's Filename should be a string.\n");
            if(nrhs<3)
                mexErrMsgTxt("Mode should be specified.\n");
            if( !mxIsChar(my_mexInputArg(3) ) )
                mexErrMsgTxt("Mode should be a character.\n");
            
            SaveDataTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"CLEAR_DATA")==0){
            mexPrintf("\n Discard Eye Tracking data and Events...\n");
            DiscardDataTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"CLEAR_HISTORY")==0){
            mexPrintf("\n Discard Eye Tracking data and Events...\n");
            DiscardHistory();
            return;
        }

        if(myoptstrcmp(fun,"STOP_TRACKING")==0){
            mexPrintf("\n Stop Tracking...\n");
            StopTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"DISCONNECT")==0){
            mexPrintf("Disconnecting...\n");
            DisconnectTobii();
            return;
        }
        
        if(myoptstrcmp(fun,"GET_STATUS")==0){
            //get status of eye tracker
            //report last error
            GetStatusTobii();
            return;
        }

        if(myoptstrcmp(fun,"CLEANUP")==0){
            //get status of eye tracker
            //report last error
            CleanUp();
            return;
        }
        
        mexErrMsgTxt("Unknown 'function name' in argument.");
        
        
    } //end of if( mxIsChar(my_mexInputArg(0)) )
}
