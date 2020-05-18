/*  
 *	tet_protocol.h :  Tobii Eye Tracker API 3.0
 *
 *			Prototypes for the Tobii Eyetracker Interface.
 *          Defines the message format to access Eyetracker Engine directly (TCP/IP)
 *
 *  Copyright (C) Tobii Technology 2002-2004, all rights reserved.
 */
 
#ifndef TET_PROTOCOL_H_
#define TET_PROTOCOL_H_

#include "toberror.h"
#include "common_et_core.h"
#include "ttime.h"

#if defined(__cplusplus)
extern "C" {
#endif


/* Message format in both directions is always:		*/
/* <STetProtocol_MsgHeader>				*/
/*	or						*/
/* <STetProtocol_MsgHeader><STetProtocol_XXXData>	*/


typedef enum _ETetProtocol_Command {
	TET_CMD_SUBSCRIBE_GAZEDATA	    =  1, /* To server	 */
	TET_CMD_UNSUBSCRIBE_GAZEDATA	    =  2, /* To server	 */
	TET_CMD_SUBSCRIBE_GAZEDATA_PASSIVE  =  3, /* To server	 */
	TET_CMD_GAZEDATA		    =  4, /* From server */
	TET_CMD_CALIB_SET		    =  5, /* To server	 */
	TET_CMD_CALIB_GET		    =  6, /* To server	 */
	TET_CMD_CALIB_START_ADD_POINTS      =  7, /* To server - Obsolete */
	TET_CMD_CALIB_ADD_NEW_POINT	    =  8, /* To server - Obsolete */
	TET_CMD_CALIB_CALCULATE_NEW_POINT   =  9, /* To server - Obsolete */
	TET_CMD_CALIB_ABORT		    = 10, /* To server - Obsolete */
	TET_CMD_GET_TIMESTAMP		    = 11, /* To server	 */
	TET_CMD_DUMPIMAGES	   	    = 12, /* To server	 */
	TET_CMD_PERFORMSYSTEMCHECK	    = 13, /* To server	 */
	TET_CMD_SERIALNUMBER_GET	    = 14, /* To server	 */
	TET_CMD_REINITIALIZE		    = 15, /* To server - Not used */
	TET_CMD_CALIB_ADD_POINT		    = 16, /* To server	 */
	TET_CMD_CALIB_CLEAR		    = 17, /* To server	 */
	TET_CMD_CALIB_REMOVE_POINTS	    = 18, /* To server	 */
	TET_CMD_CALIB_COMPUTE		    = 19, /* To server	 */
	TET_CMD_GETINFO			    = 20  /* To server	 */
} ETetProtocol_Command;



#define TET_TRANSACTION_TYPE_QUESTION			'Q'
#define TET_TRANSACTION_TYPE_RESPONSE			'R'
#define TET_TRANSACTION_TYPE_SUBSCRIPTION		'S'
#define TET_TRANSACTION_TYPE_LAST_SUBSCRIPTION		'L'


/* Message header format */
typedef struct _STetProtocol_MsgHeader {
	unsigned long type;		/* ETetProtocol_Type:
                                           'Q' - question,
                                           'R' - response,
                                           'S' - subscription,
                                           'L' - last subscription */
	unsigned long transaction_id;	/* ID set by caller for question type
                                           and copied to response	*/ 
	unsigned long transaction_seq;	/* Sequential number incremented by
                                           1 for each response		*/
	unsigned long command;		/* ETetProtocol_Command: Kind of
                                           message. Copied to response.*/
	unsigned long errorcode;	/* errorcode, anything but 0 is error,
                                           see toberror.h for definitions.*/
	unsigned long datalen;		/* Length, not including header,
                                           of data followed		*/ 
} STetProtocol_MsgHeader;


/* Message data formats	*/
typedef struct _STetProtocol_CalibRemovePointsData {
	SPosReal userviewpoint;
	double radius;
	unsigned long eye;		/* See EET_Eye in common_et_core.h */
} STetProtocol_CalibRemovePointsData;


typedef struct _STetProtocol_DumpImagesData {
	unsigned long nrofimages;
	unsigned long frequency;
} STetProtocol_DumpImagesData;


typedef struct _STetProtocol_AddPointData {
	unsigned long nrofdata;
	double x;
	double y;
} STetProtocol_AddPointData;


typedef struct _STetProtocol_SerialNumberData {
	char serialDiodeController[64];
	char serialCamera[64];
} STetProtocol_SerialNumberData;


typedef SET_AllPupilData STetProtocol_GazeData;


typedef STimeStamp STetProtocol_TimeStampData;


typedef struct _STetProtocol_Info {
	char info[32];
} STetProtocol_Info;


/* Calib data format:							*/
/* Format:  <NrOfCalibParameters><CalibParameters> *
     NrOfCalibParameters<NrOfCalibPlotData><CalibPlotData>*NrOfCalibPlotData */

/* Warning! Currently there is a perfect match between the types	*/
/* used to call the ET_XXX functions in server (SET_AllCalibAnalyzeData)*/
/* the type sent over the protocol, the type saved to file and the type	*/
/* in tet.h (STet_CalibAnalyzeData)					*/
/* If any one of them is altered, the others must also be changed 	*/
/* accordingly.								*/


#if defined(__cplusplus)
}
#endif


#endif /* TET_PROTOCOL_H_ */
