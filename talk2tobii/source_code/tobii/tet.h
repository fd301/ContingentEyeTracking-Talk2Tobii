/*  
 *	tet.h :	Tobii Eye Tracker API 3.0
 *
 *			Prototypes to interface the Tobii Eye Tracker Server.
 *	
 *			Ver 2004-02-23 LK
 *
 *  Copyright (C) Tobii Technology 2002-2004, all rights reserved.
 */


/* Interface changes version 1.0.3 2004-04-05:	
 *
 * Tet_Init renamed to Tet_Connect.
 * AD: I have reinstated Tet_Init since the Windows version initializes
 *     some things in DllMain - no such functionality exists in
 *     Linux, so I added Tet_Init
 *		
 * Tet_Close renamed to Tet_Disconnect.
 *
 * Tet_CalibAbort is removed - Wait for the Tet_CalibAddPoint completion  
 * instead or call Tet_Stop for an abortive stop. 
 *
 * Tet_CalibStartAddPoints - is removed. Functionality not required any more.
 *
 * Tet_CalibClear is added.
 *		
 * Tet_CalibRemovePoints is added. 
 *		
 * Tet_CalibAddNewPoint is changed to Tet_CalibAddPoint. 
 * See function prototype description for the change of functionality.
 *
 * Tet_CalibCalculateFromPoints are renamed to Tet_CalibCalculateAndSet
 * See function prototype description for the change of functionality.
 *
 * Tet_GetLastErrorAsText is added.
 *
 * Error codes are added.
 *
 * The name of error code 1 is changed from TET_ERR_INVALID_STATE to
 * TET_ERR_SERVER_IS_NOT_CONNECTED.  
 * 
 *
 * Interface changes version 1.0.1 2003-12-17:
 *		
 * Tet_GetLastError is changed. 
 */


#ifndef TET_H_
#define TET_H_


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


/* Return codes from all Tet_ functions, where applicable.		     */
/* When TET_ERROR is returned, call Tet_GetLastError for specific error code.*/
#define TET_ERROR			-1  /* Was error	*/
#define TET_NO_ERROR			 0  /* Was no error */


/* These are possible error codes returned by Tet_GetLastError.		*/
#define TET_ERR_NO_ERROR		 0 /* No error	*/
#define TET_ERR_SERVER_IS_NOT_CONNECTED	 1 /* There is no connection to a
                                              Tobii Eye Tracker Server. */
#define TET_ERR_SERVER_COMMUNICATION	 2 /* Failed to communicate with
                                              server. */
#define TET_ERR_FILE_OPEN		 3 /* Cannot open file.		*/
#define TET_ERR_FILE_READ		 4 /* Cannot read file.		*/
#define TET_ERR_INTERNAL		 5 /* Internal error, please report
                                              to support@tobii.se.	*/
#define TET_ERR_MEMORY			 6 /* Memory allocation failure.*/
#define TET_ERR_CAMERA			 7 /* Camera or camera driver failure.*/
#define TET_ERR_DIOD			 8 /* Diod controller failure.	*/
#define TET_ERR_LOCKED_SYSTEM		 9 /* No valid key has been provided
                                              to unlock the system.	*/
#define TET_ERR_CALIB_INCOMPATIBLE_DATA_FORMAT	10 /* The calibration data
                                                      is incompatible with
                                                      current server version.*/
#define TET_ERR_CALIB_INSUFFICIENT_DATA	11 /* There are not enough data to
                                              base a new calibration
                                              calculation on.	*/
#define TET_ERR_CALIB_NO_DATA_SET	12 /* A calibration must be set.*/
#define TET_ERR_INVALID_STATE		13 /* Either busy tracking/calibrating
                                              or the Tobii Eye Tracker Server
                                              is in a state where requested
                                              operation is not permitted.*/
#define TET_ERR_INCOMPATIBLE_SERVER_VERSION	14 /* Compatiblility error.
                                                      Cannot connect to this
                                                      version of the Tobii
                                                      Eye Tracker Server.*/
 
/* Default ip adress and port number */
#define LOCALHOST_IPADDRESS		"127.0.0.1"
#define SERVER_PORT_NUMBER		4455


/* Parameter to Tet_CalibRemovePoints	*/
typedef enum _ETet_Eye {
  TET_EYE_LEFT	= 1, /* Subject (person beeing tracked) left eye from subject
                        point of view.	*/
  TET_EYE_RIGHT	= 2, /* Subject (person beeing tracked) right eye from subject
                        point of view.*/
  TET_EYE_BOTH	= 3  /* Both eyes	*/
} ETet_Eye;


/* Gaze data passed to application provided callback function
    Tet_CallbackFunction.	*/
/* Left is left from user (beeing eye-tracked) point of view.		*/
typedef struct _STet_GazeData {
  unsigned long timestamp_sec;	/* Timestamp when image was taken in
                                   ttime format. Seconds.		*/
  unsigned long timestamp_microsec;	/* Timestamp when image was
                                           taken in ttime format.
                                           Microseconds.		*/
  float x_gazepos_lefteye;	/* Left eye horizontal gaze position.
                                   Same unit as used when calibration was
                                   done. Normally 0.0 is leftmost and 1.0
                                   is rightmost of the object beeing gazed at.*/
  float y_gazepos_lefteye;	/* Left eye vertical gaze position.
                                   Same unit as used when calibration was
                                   done. Normally 0.0 is topmost and 1.0
                                   is bottommost of the object beeing
                                   gazed at.	*/
  float x_camerapos_lefteye;	/* Left eye position seen by the camera.
                                   0.0 is leftmost and 1.0 is rightmost.*/
  float y_camerapos_lefteye;	/* Left eye position seen by the camera.
                                   0.0 is topmost and 1.0 is bottommost.*/
  float diameter_pupil_lefteye;	/* Diameter of left eye pupil. Proprietary
                                   unit. Will be improved and documented
                                   for a future version.		*/
  float distance_lefteye;	/* Distance to left eye pupil. Proprietary
                                   unit. Will be improved and documented
                                   for a future version.		*/
  unsigned long validity_lefteye;/* How likely is it that the left eye was
                                    found? 0 - Certainly (>99%),
                                           1 - Probably (80%),
                                           2 - (50%),
                                           3 - Likely not (20%),
                                           4 - Certainly not (0%) */
  float x_gazepos_righteye;	/* Right eye horizontal gaze position.
                                   Same unit as used when calibration was
                                   done. Normally 0.0 is leftmost and
                                   1.0 is rightmost of the object beeing
                                   gazed at.*/
  float y_gazepos_righteye;	/* Right eye vertical gaze position.
                                   Same unit as used when calibration was done.
                                   Normally 0.0 is topmost and 1.0 is
                                   bottommost of the object beeing gazed at.*/
  float x_camerapos_righteye;	/* Right eye position seen by the camera.
                                   0.0 is leftmost and 1.0 is rightmost.*/
  float y_camerapos_righteye;	/* Right eye position seen by the camera.
                                   0.0 is topmost and 1.0 is bottommost.*/
  float diameter_pupil_righteye;/* Diameter of right eye pupil. Proprietary
                                   unit. Will be improved and documented for
                                   a future version.		*/
  float distance_righteye;	/* Distance to right eye pupil. Proprietary
                                   unit. Will be improved and documented for
                                   a future version.		*/
  unsigned long validity_righteye; /* How likely is it that the right eye was
                                      found?
                                      0 - Certainly (>99%),
                                      1 - Probably (80%),
                                      2 - (50%),
                                      3 - Likely not (20%),
                                      4 - Certainly not (0%)	*/
} STet_GazeData;


/* Calibration information data. Left means left from user point of view.*/
/* Coordinates in percentage of object gazed at (normally the screen)	*/
/* where (0.0, 0.0) is upper left corner of object and (1.0, 1.0) is lower*/
/* right corner of object, i.e X increases downwards and Y to the right.*/
typedef struct _STet_CalibAnalyzeData {
  float truePointX;	/* X coordinate for point where it was displayed
                           for the user.				*/
  float truePointY;	/* Y coordinate for point where it was displayed
                           for the user.				*/
  float leftMapX;	/* Left eye, X coordinate for mapped point.	*/
  float leftMapY;	/* Left eye, Y coordinate for mapped point.	*/
  long leftValidity;	/* Left eye, (-1) - was not found,
                                      (0) - found but not used,
                                      (1) - used.	*/
  float leftQuality;	/* Left eye, quality measurement
                           (feature to come, not implemented).		*/
  float rightMapX;	/* Right eye, X coordinate for mapped point.	*/
  float rightMapY;	/* Right eye, Y coordinate for mapped point.	*/
  long rightValidity;	/* Right eye, (-1) - was not found,
                                       (0) - found but not used,
                                       (1) - used.	*/
  float rightQuality;	/* Right eye, quality measurement
                           (feature to come, not implemented).		*/
} STet_CalibAnalyzeData;


/* The reason why callback was called	*/
typedef enum _ETet_CallbackReason {
	TET_CALLBACK_GAZE_DATA = 1,
	TET_CALLBACK_TIMER = 2
} ETet_CallbackReason;


/* Prototype of callback function to implement and set as argument to
   Tet_Start and Tet_CalibAddPoint */
typedef void  (__stdcall *Tet_CallbackFunction)
              (ETet_CallbackReason reason, void *pData, void *pApplicationData);



/*  ----------------------------------------------------------------------------
 * 		Tet_Init
 *  ----------------------------------------------------------------------------
 *  This function will set up some basic things, mainly thread-related
 *  items such as the TLS index.
 *
 *  Note: THIS FUNCTION ASSUMES IT IS RUNNING IN A THREAD
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *
 *  Change log:
 *  2004-06-18 AD Added Tet_Init
 */

DLL_EXPORT long __stdcall Tet_Init(void);


/*  ----------------------------------------------------------------------------
 * 		Tet_Connect
 *  ----------------------------------------------------------------------------
 *  This function will connect to the Tobii Eye Tracker Server and setup  
 *  necessary internal states.
 *  No other functionality is available prior to this call. 
 *	Call Tet_Disconnect for a cleanup when done.
 *  It is possible to turn on logging.
 *
 *  All Tet_XXX functions can be called from any thread. However, each thread 
 *  will have its own connection to the server and do not share anything with
 *  other threads within the same process. This means that Tet_Connect (and 
 *  Tet_Disconnect) must be called in each thread. Note, if the threads are
 *  connected to the same TETServer, the tasks must be coordinated. If one
 *  thread is tracking another one is allowed to calibrate at the same time,
 *  for instance. 
 *  The debug file parameter is allowed to be the same for different threads 
 *  without problem. The printouts will be marked with the id of calling thread.
 *
 *  Arguments: IN: pServerAddress - pointer to a null terminated array of 
 *                   chars that contains the ip address or host name of 
 *                   the host where the Tobii Eye Tracker Server is hosted. 
 *				 Example: "133.73.6.12" or "www.myserver.com".
 *                   Set NULL to use the default (local host). 
 *             IN: portnumber - Tobii Eye Tracker Server listening port number. 
 *                   Set NULL to use the default value.
 *             IN: pDebugLogFile  - pointer to a null terminated array of chars 
 *                   that contains the path and filename to the file where 
 *                   internal debug information will be written. May be 
 *		     important to the development team when reporting possible
 *			 bugs. 
 *                   Set NULL to not log. 
 *
 *  Modifying: Sets up a TCP/IP connection and changes internal 
 *             initialization states.
 * 
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *             If debug log file cannot be opened the function will not
 *             fail for that reason.
 *
 *  Change log:
 *  2002-12-17 LK First version
 *  2003-01-13 LK Removed start server parameter
 *  2003-02-25 LK Changed call convention from __cdecl to __stdcall
 *  2003-05-23 LK pIPAdress renamed to pServerAddress and host name is allowed.
 *  2004-01-20 LK Threads allowed. Function always returns error when state is
 *                bad.
 *  2004-02-23 LK Renamed from Tet_Init. Internal improvments.
 */

DLL_EXPORT long __stdcall Tet_Connect(char *pServerAddress, unsigned short portnumber, char *pDebugLogFile);


/*  ----------------------------------------------------------------------------
 * 		Tet_Disconnect
 *  ----------------------------------------------------------------------------
 *  Performs necessary cleanups. After a call no other functions are 
 *  available but Tet_Connect. 
 *
 *  Arguments: -
 *
 *  Modifying: Drops TCP/IP connection if any and changes 
 *             internal initialization states.
 *
 *  Returning: Always TET_NO_ERROR.
 *
 *  Change log:
 *  2002-12-17	LK  First version
 *  2003-01-20  LK  Removed stop server parameter.
 *  2003-02-25	LK  Changed call convention from __cdecl to __stdcall
 *  2004-01-20	LK  Threads allowed. Function always returns error when state
 *                  is bad.
 *  2004-02-23	LK  Renamed from Tet_Close. Internal improvments.
 */

DLL_EXPORT long __stdcall Tet_Disconnect(void);


/*  ----------------------------------------------------------------------------
 * 		Tet_Start
 *  ----------------------------------------------------------------------------
 *  Blocking function that will start the image acquisition and calculate the 
 *  gaze data. When new data is available the callback function will be called 
 *  immediatly with fresh data and ETet_CallbackReason parameter set to 
 *  TET_CALLBACK_GAZE_DATA. The pData parameter will point to a STet_GazeData 
 *  struct. 
 *
 *  To set the callback function to be called at regular interval, even though
 *  there are no new gaze data, set the interval parameter to something else 
 *  than zero and the callback function will periodically be called with 
 *  ETet_CallbackReason TET_CALLBACK_TIMER and pData set to NULL.
 *
 *  Tet_Start will exit only on unrecoverable error or if Tet_Stop is called. 
 *  To stop, call Tet_Stop before your callback function returns.
 *
 *  Arguments: IN : Fnc - callback function
 *             IN : pApplicationData - optional pointer to user defined 
 *                  structure. Will be provided as argument to callback 
 *                  function.
 *	       IN : interval - interval in milliseconds the callback function
 *		     will be called. If set to 0, the callback will never 
 *		     be called for timer reason. 
 *
 *  Modifying: Sets up data internally to enable callbacks to Fnc upon data 
 *			   arrival or timer ticks.
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2002-12-17	LK First version
 *  2003-02-12	LK Change time format of parameter passed to callback function.
 *  2003-02-25	LK Changed call convention from __cdecl to __stdcall
 *  2004-01-20	LK Threads allowed. Function always returns error when state
 *                 is bad.
 *  2004-02-10	LK Callbacks at regular intervals added. See the interval
 *                 parameter.
 *		   The callback function is changed to allow this change.
 */

DLL_EXPORT long __stdcall Tet_Start(Tet_CallbackFunction Fnc, void *pApplicationData, unsigned long interval);


/*  ----------------------------------------------------------------------------
 * 		Tet_Stop
 *  ----------------------------------------------------------------------------
 *  Stop the image acquisition and callbacks.  
 *  When performed, Tet_Start or Tet_CalibAddPoint will return and let the  
 *  execution control back to the caller.
 *
 *  Arguments: -
 *
 *  Modifying: Cleaning up internal callback structures.
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2002-12-17	LK First version
 *  2003-02-25	LK Changed call convention from __cdecl to __stdcall
 *  2004-01-20	LK Threads allowed. Function always returns error when state
 *                 is bad.
 */

DLL_EXPORT long __stdcall Tet_Stop(void);


/*  ----------------------------------------------------------------------------
 * 		Tet_CalibLoadFromFile
 *  ----------------------------------------------------------------------------
 *  Reuses a personal calibration saved with Tet_CalibSaveToFile. 
 *  Enables the system to run without having to perform a calibration by calling
 *  Tet_CalibPerform.
 *
 *  Arguments: IN:  pFile - Pointer to a NULL terminated array of chars 
 *                  that contains the path and filename to a personal 
 *                  calibration file.
 *             OUT: -
 *
 *  Modifying: Current personal calibration in use and keeps a copy of it in 
 *	   collection that is used to calculate new calibration parameters.
 *			   
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2002-12-17	LK  First version
 *  2003-01-20  LK  Removed quality as output parameter
 *  2003-02-25	LK  Changed call convention from __cdecl to __stdcall
 *  2004-01-20	LK  Threads allowed. Function always returns error when
 *                  state is bad.
 */

DLL_EXPORT long __stdcall Tet_CalibLoadFromFile(char *pFile);



/*  ----------------------------------------------------------------------------
 * 		Tet_CalibSaveToFile
 *  ----------------------------------------------------------------------------
 *  Saves current personal calibration to a file for future reuse.
 *  Enables the system to run without having to perform a calibration by calling
 *  Tet_CalibPerform.
 *  The calibration saved is valid only for the person that performed the 
 *  calibration only.
 *
 *  Arguments: IN:  pFile - Pointer to a NULL terminated array of chars 
 *                    that contains the path and filename to a personal 
 *                    calibration file.
 *
 *  Modifying: Current personal calibration in use.
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2002-12-17	LK First version
 *  2003-02-25	LK Changed call convention from __cdecl to __stdcall
 *  2004-01-20	LK Threads allowed. Function always returns error when
 *                 state is bad.
 */

DLL_EXPORT long __stdcall Tet_CalibSaveToFile(char *pFile);


 
/*  ----------------------------------------------------------------------------
 * 		Tet_CalibGetResult
 *  ----------------------------------------------------------------------------
 *
 *  Gets all information about a personal calibration, for a manual/automatic 
 *  quality inspection. 
 *  Provided are target points, the resulting mapped points and an indication 
 *  if the point was discarded or not for some reason.
 *
 *  Result may be retrieved from either current personal calibration or from 
 *  a saved personal calibration (created by Tet_CalibSaveToFile). See in 
 *  parameter below.
 *
 *  If 200 items are allocated, it will be enough for most calibrations.
 *
 *  Arguments: IN:  pFile - NULL to get result from current personal calibration
 *                    or pointer to a NULL terminated array of chars 
 *                    that contains the path and filename to a personal 
 *                    calibration file saved by Tet_CalibSaveToFile.
 *	   OUT: pData - pointer to array of STet_CalibAnalyzeData. Must be 
 *					  allocated prior to call. 
 *         IN/OUT: pLen - in: number of items allocated in pData.
 *                       out: number of items returned in pData. If data 
 *			won't fit pData is filled to its limit and 
 *			pLen will point to the true length, making
 *			it possible to reallocate using the true
 *			length and make a new call. 
 *
 *  Modifying: -
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Note: when data won't fit it is still considered success.
 *                   Use pLen to detect this instead. 
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2003-05-22	LK	First version
 *  2004-01-20	LK	Threads allowed. Function always returns error when
 *                      state is bad.
 */

DLL_EXPORT long __stdcall Tet_CalibGetResult(char *pFile, STet_CalibAnalyzeData *pData, long *pLen);



/*  ----------------------------------------------------------------------------
 * 		Tet_CalibAddPoint
 *  ----------------------------------------------------------------------------
 *  Blocking function to use use when application defined (not the built-in 
 *	tool) calibration is to be performed. This adds new calibration points.
 *  
 *  Normal usage is to display something on screen at position (x,y)
 *  and make sure subject to track gazes at this point. Then call this function 
 *  to make the system try to record nrofdata calibration datas for this point.
 *  
 *  A good calibration should have about 16 calibration points evenly split on
 *  the item to monitor (screen).
 *
 *  When done with all points call Tet_CalibCalculateAndSet to set all the
 *  the new calibration.
 *
 *  When new data is available the callback function (optional) will be called 
 *  immediatly with fresh data and ETet_CallbackReason parameter set to 
 *  TET_CALLBACK_GAZE_DATA. The pData parameter will point to a STet_GazeData 
 *  struct. 
 *
 *  The callback function may also be setup for periodic calls even though
 *  there are no new gaze data. Set the interval parameter to something else 
 *  than zero and the callback function will be called with ETet_CallbackReason 
 *  TET_CALLBACK_TIMER and pData set to NULL.
 *
 *  The function is blocking and will return only if it is finished, if Tet_Stop
 *  prematurely stops this calibration or if an error occurs. 
 *  Tet_Stop must be called from within the callback function. 
 *
 *  If a callback function is passed it will be called each time an image 
 *  is acquired and periodically at regular interval each time a 
 *
 *  Note that nrofdata is a hint to the system of how much data it will try to
 *  acquire. Never rely on this number in code. There may be much more callbacks 
 *  if quality is poor and it may be less if an error occurs.
 *  Typically if nrofdata is set to 6 there will be 12-24 callbacks if no errors
 *  occur.
 *
 *  Arguments: IN: nrofdata - hint to the system of how much good data to 
 *                 collect for this calibration points. 
 *		  A value of 6 is considered optimal for many
 *					  environments.
 *             IN:  x - horisontal position ranging from 0 to 1 where 0 is 
 *                    leftmost position and 1 is rightmost.
 *                    Normally, it is used as percentage of screen.
 *             IN:  y - vertical position ranging from 0 to 1 where 0 is 
 *                    topmost position and 1 bottom position.
 *                    Normally, it is used as percentage of screen.
 *   	     IN : Fnc - callback function
 *             IN : pApplicationData - optional pointer to user defined 
 *                    structure. Will be provided as argument to callback 
 *                    function.
 *	   IN : interval - interval in milliseconds the callback function
 *			  will be called. If set to 0, the callback will never 
 *			  be called for timer reason. 
 *
 *  Modifying: Adds new calibration points to the collection that is used to 
 *		   calculate new calibration parameters.
 *		   Sets up data internally to enable callbacks to Fnc upon data 
 *		   arrival or timer ticks.
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2003-01-22	LK	First version
 *  2003-02-25	LK	Changed call convention from __cdecl to __stdcall
 *  2004-01-20	LK	Threads allowed. Function always returns error when
 *                      state is bad.
 *  2004-02-10	LK	Callbacks enabled. Based on obsolete function
 *                      Tet_CalibAddNewPoint.
 */

DLL_EXPORT long __stdcall Tet_CalibAddPoint(float x, float y, unsigned long nrofdata, Tet_CallbackFunction Fnc, void *pApplicationData, unsigned long interval);



/*  ----------------------------------------------------------------------------
 * 		Tet_CalibCalculateAndSet
 *  ----------------------------------------------------------------------------
 *  Used when application defined (not the built-in tool) calibration is to be 
 *  performed. 
 *  This ends the calibration process and calculates points that were added or
 *  removed by calls to Tet_CalibAddPoint, Tet_CalibClear or 
 *  Tet_CalibRemovePoints.
 *
 *  Arguments: -
 *
 *  Modifying: Current calibration used to calculata gaze data.
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2003-01-22	LK	First version
 *  2003-02-25	LK	Changed call convention from __cdecl to __stdcall
 *  2004-01-20	LK	Threads allowed. Function always returns error
 *                      when state is bad.
 */

DLL_EXPORT long __stdcall Tet_CalibCalculateAndSet(void);	



/*  ----------------------------------------------------------------------------
 * 		Tet_CalibClear
 *  ----------------------------------------------------------------------------
 *  Used when application defined (not the built-in tool) calibration is to be 
 *  performed. 
 *  This clears all the points that Tet_CalibCalculateAndSet bases its 
 *  calculations on. For information: New points are added by Tet_CalibAddPoint 
 *  or Tet_CalibLoadFromFile and points may be removed by Tet_CalibRemove.
 * 
 *  Arguments: -
 *
 *  Modifying: Clears the collection of data that is used to calculate new 
 *			   calibration parameters.
 *				
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2004-02-11	LK	First version
 */

DLL_EXPORT long __stdcall Tet_CalibClear(void);	



/*  ----------------------------------------------------------------------------
 * 		Tet_CalibRemovePoints
 *  ----------------------------------------------------------------------------
 *  Used when application defined (not the built-in tool) calibration is to be 
 *  performed. 
 *  This clears all points, that Tet_CalibCalculateAndSet bases its 
 *  calculations on, within a radius from the point (x,y). 
 * 
 *  Arguments:	IN:  eye - the eys(s) to remove calibration points for. 
 *		IN:  x - horisontal position ranging from 0 to 1 where 0 is 
 *                   leftmost position and 1 is rightmost.
 *                   Normally, it is used as percentage of screen.
 *		IN:  y - vertical position ranging from 0 to 1 where 0 is 
 *                   topmost position and 1 bottom position.
 *                   Normally, it is used as percentage of screen.
 *		IN:  radius - distance from point (x,y) where calibration points
 *		  will be removed. Same unit as x and y.
 *							
 *
 *  Modifying: Clears some data in the collection that is used to calculate new 
 *			   calibration parameters.
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2004-02-11	LK	First version
 */

DLL_EXPORT long __stdcall Tet_CalibRemovePoints(ETet_Eye eye, float x, float y, float radius);




/*  ----------------------------------------------------------------------------
 * 		Tet_SynchronizeTime
 *  ----------------------------------------------------------------------------
 *  Setting up the Tobii Time Module (ttime), i.e. calling 
 *  TT_SetSynchronizedTime to enable routines to convert local timestamps to and
 *  from the Tobii Eye Tracker Server timestamps and returns the maximal error. 
 *
 *  A successful call to Tet_Connect must be performed prior to this call.
 *  
 *  WARNING: All applications using the Tobii Time Module (ttime.dll) on the 
 *  client side host (this side) will be affected.
 *
 *  Note: Dependent on how different the hardware clocks are on the Tobii Eye 
 *  Tracker Server host and the one on the client side (this side), the drift
 *  causing an error is likely to increase as time goes.
 *
 *  If Tobii Eye Tracker Server is running on the same host (client side), 
 *  this will be detected and handled properly only if loopback interface was 
 *  used (IP address 127.0.0.1) to connect. If any other address is used to 
 *	connect to the localhost, an unnecessary error will be introduced in 
 *  timestamps. 
 *
 *  Arguments: IN:  -
 *             OUT: pSec - maximal error (seconds fraction). 
 *		    pMicroSec -  maximal error (microseconds fraction). 
 *
 *  Modifying: Uses Tobii Time Module (ttime) and calls TT_SetSynchronizedTime 
 *             which in turn sets an timestamp offset internally enabling  
 *             the conversion routines TT_Local2Remote and TT_Remote2Local.
 *
 *  Returning: TET_NO_ERROR on success, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2003-06-18	LK	First version
 *  2003-06-23	LK	Changed behaviour.
 *  2004-01-20	LK	Threads allowed. Function always returns error when
 *                      state is bad.
 */

DLL_EXPORT long __stdcall Tet_SynchronizeTime(unsigned long *pSec, unsigned long *pMicroSec);




/*  ----------------------------------------------------------------------------
 * 		Tet_PerformSystemCheck
 *  ----------------------------------------------------------------------------
 *  Get the current status of the Tobii Eye Tracker Server.
 *  Use it to find out if camera and diods are attached.
 *  
 *
 *  Use Tet_GetLastError for detailed description if there are any errors.
 *
 *  Arguments: IN:  -
 *             OUT: -
 *
 *  Modifying: -
 *
 *  Returning: TET_NO_ERROR if there are no errors, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2003-11-13	LK	First version
 *  2004-01-20	LK	Threads allowed. Function always returns error
 *                      when state is bad.
 */

DLL_EXPORT long __stdcall Tet_PerformSystemCheck(void);




/*  ----------------------------------------------------------------------------
 * 		Tet_GetSerialNumber
 *  ----------------------------------------------------------------------------
 *  Get the hardware serial numbers, if present, from the diode controller and
 *  the camera.
 *  
 *  Use Tet_GetLastError for detailed description if there are any errors.
 *
 *  Arguments: OUT:	pSerialDiodeController - null terminated array of chars 
 *			 containing the diode controller serial number. 
 *			 Will never be more than 64 bytes including null 
 *			 terminator. Must be allocated by caller.
 *			 First byte is zero if not present.
 *		OUT: pSerialCamera - null terminated array of chars containing
 *                    the camera serial number. 
 *			 Will never be more than 64 bytes including null 
 *			 terminator. Must be allocated by caller.
 *			 First byte is zero if not present.
 *  Modifying: -
 *
 *  Returning: TET_NO_ERROR if there are no errors, else TET_ERROR.
 *             Call Tet_GetLastError for error details.
 *
 *  Change log:
 *  2003-12-22	LK	First version
 *  2004-01-20	LK	Threads allowed. Function always returns error
 *                      when state is bad.
 */

DLL_EXPORT long __stdcall Tet_GetSerialNumber(char *pSerialDiodeController, char *pSerialCamera);



/*  ----------------------------------------------------------------------------
 * 		Tet_GetLastError
 *  ----------------------------------------------------------------------------
 *  Whenever a TET_ERROR is returned from any Tet_XXX function, 
 *  a call to this function will return the specific last error.
 *  The error will be overwritten as soon as another error occur. 
 *	See also Tet_GetLastErrorAsText.
 *
 *  Arguments:  IN:  -	
 *		OUT: -
 *                                 
 *  Modifying: -
 *  Returning: Last error code. See TET_ERR_XXX definitions in this file.
 *
 *  Change log:
 *  2002-12-17	LK  First version
 *  2003-01-23  LK  Parameter change.
 *  2003-01-24  LK  Parameter change.
 *  2003-02-25	LK  Changed call convention from __cdecl to __stdcall
 *  2003-12-01	LK  Removed all parameters: low level parameter and user 
 *		    description. See description of possible error codes in
 *					this file instead. 
 */

DLL_EXPORT unsigned long __stdcall Tet_GetLastError(void);



/*  ----------------------------------------------------------------------------
 * 		Tet_GetLastErrorAsText
 *  ----------------------------------------------------------------------------
 *  Whenever a TET_ERROR is returned from any Tet_XXX function, a call to this 
 *  function will return the specific last error as a text string.
 *	The error will be invalid as soon as another error occur. 
 *	See also Tet_GetLastError.
 *
 *  Arguments:  IN:  -	
 *		OUT: pError - placeholder for error text. 
 *		 Must be allocated by caller. The result will never require 
 *					 more than 255 bytes. 
 *                                 
 *  Modifying: -
 *  Returning: pError
 *
 *  Change log:
 *  2004-02-19	LK	First version
 */

DLL_EXPORT char * __stdcall Tet_GetLastErrorAsText(char *pError);

DLL_EXPORT long __stdcall Tet_GetInfo(char *Info);


#if defined(__cplusplus)
}
#endif


#endif /* TET_H_ */

