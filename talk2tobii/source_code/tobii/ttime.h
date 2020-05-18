/*  
 *	ttime.h :	Tobii Time Function Library 
 *
 *			Prototypes for all time functions used by Tobii software.
 *	
 *			Ver 2003-06-23 LK
 *
 *  Copyright (C) Tobii Technology 2003, all rights reserved.
 */

#ifndef TTIME_H_
#define TTIME_H_


#if defined(__cplusplus)
extern "C" {
#endif


#if defined(_WIN32)
/* Enable Windows dll export */
#define	DLL_EXPORT __declspec (dllexport) 
#else
#define	DLL_EXPORT
#define __stdcall
#endif



/* This is the timestamp given at a precision of a millisecond, but	*/
/* the timer started is accurate to a precision of a microsecond	*/
/* Note, struct alignment is sequential without any padding.		*/
/* Note, unsigned short is 2 bytes ranging from 0 to 2^16-1 = 65 535	*/

typedef struct _STTime { 
	unsigned short year;		
	unsigned short month;	/* January = 1, February = 2, and so on.*/
	unsigned short dayofweek;  /* day of the week; Sun = 0, Mon = 1, etc.*/
	unsigned short day; 
	unsigned short hour; 
	unsigned short minute; 
	unsigned short second; 
	unsigned short milliseconds; 
} STTime; 


/* Time stamp given in seconds and microseconds since timer was started.*/
/* Note, struct alignment is sequential without any padding.		*/
typedef struct _STimeStamp {
	unsigned long second;		
	unsigned long microsecond;
} STimeStamp;




/* -----------------------------------------------------------------------------
 * 		TT_IsSupported
 * -----------------------------------------------------------------------------
 *  This function should be called prior to any other call in this module to
 *  find out if hard- and software does support ttimers. 
 *  If not supported, the result from all other functions will be undefined.
 *  
 *  TT_IsSupported will never change its return value if hardware or
 *  software is not exchanged. 
 *
 *  Arguments: -
 *
 *  Modifying: -
 * 
 *  Returning: Non-zero if ttimer functionality is available.
 *
 *  Change log:
 *  2003-02-05	LK	First version
 */

DLL_EXPORT long __stdcall TT_IsSupported(void);




/*  ----------------------------------------------------------------------------
 * 		TT_GetTimeStampBase
 *  ----------------------------------------------------------------------------
 *  This function gives the local time when time stamp counter was started at
 *  a precision normally of better than 10 microseconds. 
 *
 *  There is no way of controlling the time when the counter starts and
 *  there is no way to reset it.
 *  
 *  The timer is started when first process loads the dll and counter start time 
 *  is shared between all processes calling this module, making all ttime calls 
 *  synchronized between processes. 
 *
 *  This time base is fixed and not changed due to time adjustments or 
 *  day-light savings.
 *
 *  Call TT_IsSupported to find out if a call to TT_GetTimeStampBase is valid. 
 *
 *
 *  Arguments: OUT: pBaseTime - See typedef declaration above. 
 *
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-02-05	LK	First version
 */

DLL_EXPORT void __stdcall TT_GetTimeStampBase(STTime *pBaseTime);




/*  ----------------------------------------------------------------------------
 * 		TT_GetTimeStamp
 *  ----------------------------------------------------------------------------
 *  This returns a timestamp with following features:
 *      + high-resolution at microseconds level.
 *	+ high-efficient, call overhead is less than 2 microseconds on a 1 GHz
 *        system. May vary on heavy CPU load though. 
 *      + values in sequence - will NOT wrap after, say, 47 days.
 *		+ unaffeced of time adjustments or day-light savings changes.
 *
 *  There is no way of controlling the time when the counter starts and
 *  there is no way to reset it. 
 *  
 *  The timer is started when first process loads the dll and counter start time 
 *  is shared between all processes calling this module, making all time calls 
 *  synchronized between processes. 
 *
 *  Call TT_GetTimeStampBase to know when the timer was started. 
 * 
 *  Call TT_IsSupported to find out if a call to TT_GetTimeStamp is valid. 
 *
 *
 *  Arguments: OUT: pTimeStamp - Seconds and microseconds.
 *				 See typedef declaration above. 
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-02-05	LK	First version
 */


DLL_EXPORT void __stdcall TT_GetTimeStamp(STimeStamp *pTimeStamp);




/*  ----------------------------------------------------------------------------
 * 		TT_GetCurrentTime
 *  ----------------------------------------------------------------------------
 *  This function calculates current time by adding the time stamp to the base
 *  time. 
 *  If time adjustments have been done since timer was started, this value will 
 *  not match the computer local time. 
 *
 *  Arguments: IN: -
 *             OUT: pCurrentTime - will contain current time. 
 *
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-02-05	LK	First version
 */

DLL_EXPORT void __stdcall TT_GetCurrentTime(STTime *pCurrentTime);




/*  ----------------------------------------------------------------------------
 * 		TT_ElapsedTime
 *  ----------------------------------------------------------------------------
 *  This function calculates elapsed time, either from two time stamps or from 
 *  one time stamp till now.
 *  
 *  Only positive difference (start before stop) are treated correctly.
 *
 *
 *  Arguments: IN:  pStart - pointer to time stamp in seconds and microseconds.
 *             IN:  pStop - pointer to time stamp in seconds and microseconds.  
 *                          This may optionally be a NULL pointer to use current 
 *                          time stamp.
 *             OUT: pRes - Resulting elapsed time. 
 *
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-02-05	LK	First version
 */

DLL_EXPORT void __stdcall TT_ElapsedTime(STimeStamp *pStart, STimeStamp *pStop, STimeStamp *pRes);




/*  ----------------------------------------------------------------------------
 * 		TT_AddTime
 *  ----------------------------------------------------------------------------
 *  This function adds two timestamps.
 *
 *  Arguments: IN:  pTime1 - pointer to first timestamp;
 *	       IN:  pTime2 - pointer to second timestamp;
 *
 *             OUT: pRes - Resulting sum of time. 
 *
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-06-23	LK	First version
 */

DLL_EXPORT void __stdcall TT_AddTime(STimeStamp *pTime1, STimeStamp *pTime2, STimeStamp *pRes);




/* -----------------------------------------------------------------------------
 * 		TT_AverageTime
 * -----------------------------------------------------------------------------
 *  This function calculates the average of two timestamps. 
 *
 *  Arguments: IN:  pTime1 - pointer to first timestamp;
 *	       IN:  pTime2 - pointer to second timestamp;
 *
 *             OUT: pRes - Resulting average time. 
 *
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-06-23	LK	First version
 */

DLL_EXPORT void __stdcall TT_AverageTime(STimeStamp *pTime1, STimeStamp *pTime2, STimeStamp *pRes);




/*  ----------------------------------------------------------------------------
 * 		TT_Compare
 *  ----------------------------------------------------------------------------
 *  Compare timestamps. 
 *
 *  Arguments: IN:  pTime1 - pointer to first timestamp;
 *     	       IN:  pTime2 - pointer to second timestamp;
 *								
 *
 *  Modifying: -
 * 
 *  Returning: < 0 pTime1 less than pTime2 
 *			   0 pTime1 identical to pTime2
 *			   > 0 pTime1 greater than pTime2
 *
 *  Change log:
 *  2003-06-23	LK	First version
 */

DLL_EXPORT long __stdcall TT_Compare(STimeStamp *pTime1, STimeStamp *pTime2);




/*  ----------------------------------------------------------------------------
 * 		TT_TickCount2TimeStamp
 *  ----------------------------------------------------------------------------
 *  This function converts the time in milliseconds since boot time to the 
 *  STimeStamp. 
 *  This boot time parameter is what you get from functions like GetTickCount
 *  or from a hook callback procedure. 
 *  
 *  Note that the indata is an unsigned long, making it wrap after about 49.7 
 *  days uptime. This is not handled and output will be wrong.
 *
 *
 *  Arguments: IN:  tickCount - Time stamp in milliseconds since reboot.
 *             OUT: pRes - time stamp converted to STimeStamp format. 
 *
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-02-11	LK	First version
 */

DLL_EXPORT void __stdcall TT_TickCount2TimeStamp(unsigned long tickCount, STimeStamp *pRes);




/*  ----------------------------------------------------------------------------
 * 		TT_SetSynchronizedTime
 *  ----------------------------------------------------------------------------
 *  Stores an offset to the timestamp of another host to prepare for conversion 
 *  routines TT_Remote2Local or TT_Local2Remote, which translates timestamps 
 *  using two different timestamp bases. 
 *  
 *  Note that this affects all processes using this ttime module. 
 * 
 *  Different time drift on different hardware will increase the error 
 *  (time difference) between the computers as time elapses. 
 *  A new call to TT_SetSynchronizedTime will compensate for this. 
 *
 *
 *  Arguments: IN:  pRemoteTime - pointer to remote timestamp. 
 *             IN:  pLocalTime - pointer to the local time stamp at the point in
 *                               time when the server timestamp was retrieved. 
 *             OUT: - 
 *
 *  Modifying: The remote timestamp offset used in TT_Remote2Local and
 *			   TT_Local2Remote.
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-06-23	LK	First version
 */

DLL_EXPORT void __stdcall TT_SetSynchronizedTime(STimeStamp *pRemoteTime, STimeStamp *pLocalTime);




/*  ----------------------------------------------------------------------------
 * 		TT_Remote2Local
 *  ----------------------------------------------------------------------------
 *  This function converts a timestamp from another ttime to local timestamp.
 * 
 *  TT_SetSynchronizedTime must be called at least once prior to a call 
 *  or else the result is undefined. 
 *  
 *  Result will also be undefined if the in parameter is set so result normally 
 *  would have been negative. 
 *  
 *
 *  Arguments: IN:  pRemote - pointer to time stamp to be converted. 
 *
 *             OUT: pLocal - pointer to resulting local timestamp.
 *
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-06-23	LK	First version
 */

DLL_EXPORT void __stdcall TT_Remote2Local(STimeStamp *pRemote, STimeStamp *pLocal);




/*  ----------------------------------------------------------------------------
 * 		TT_Remote2Local
 *  ----------------------------------------------------------------------------
 *  This function converts a local timestamp to a timestamp from another ttime. 
 * 
 *  TT_SetSynchronizedTime must be called at least once prior to a call 
 *  or else the result is undefined. 
 *  
 *  Result will also be undefined if the in parameter is set so result normally 
 *  would have been negative. 
 *  
 *
 *  Arguments: IN:  pLocal - pointer to time stamp to be converted. 
 *
 *             OUT: pRemote - pointer to resulting remote timestamp.
 *
 *  Modifying: -
 * 
 *  Returning: -
 *
 *  Change log:
 *  2003-06-23	LK	First version
 */

DLL_EXPORT void __stdcall TT_Local2Remote(STimeStamp *pLocal, STimeStamp *pRemote);




#if defined(__cplusplus)
}
#endif


#endif /* TTIME_H_ */
