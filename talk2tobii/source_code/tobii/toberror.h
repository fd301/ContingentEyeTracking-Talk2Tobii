/*
 *	toberror.h :  Tobii Error Codes
 *
 *	Copyright (C) Tobii Technology 2003, all rights reserved.
 */

#ifndef TOBERROR_H_
#define TOBERROR_H_

#define TOB_NO_ERROR				0x0
#define TOB_ERR_BASE				0x20000000


/* IP communication, ip_comm.c (used in tet.dll, dcs.dll and cv.dll) codes. */
#define IP_COMM_NO_ERROR			TOB_NO_ERROR
#define IP_COMM_BASEERR				(TOB_ERR_BASE | 0x100)
#define IP_COMM_INCOMPATIBLE_WINSOCK_VERSIONS	(IP_COMM_BASEERR | 0x1)
#define IP_COMM_TIMEOUT				(IP_COMM_BASEERR | 0x2)
#define IP_COMM_SOCKET_CLOSED			(IP_COMM_BASEERR | 0x3)
#define IP_COMM_MEMORY				(IP_COMM_BASEERR | 0x4)
#define IP_COMM_STOPPED	(IP_COMM_BASEERR | 0x5) /* Not an error really */

#ifndef INADDR_NONE
#define INADDR_NONE 0xffffffff
#endif

#ifndef SOCKET_ERROR
#define SOCKET_ERROR -1
#endif


/*									*/
/* TETServer error codes						*/
/*									*/

/* Unrecoverable errors TET_SERV_ERR_XXX				*/
/* Server will terminate						*/
#define TET_SERV_ERR_NO_ERROR                       TOB_NO_ERROR
#define TET_SERV_ERR_BASE                          (TOB_ERR_BASE| 0x200)
#define TET_SERV_ERR_INCOMPATIBLE_WINSOCK_VERSIONS (TET_SERV_ERR_BASE | 0x1)
#define TET_SERV_ERR_MEMORY			   (TET_SERV_ERR_BASE | 0x2)
#define TET_SERV_ERR_CONFIG_FILE_ERROR		   (TET_SERV_ERR_BASE | 0x3)
#define TET_SERV_ERR_NO_HARDWARE_CALIBRATION  	   (TET_SERV_ERR_BASE | 0x4)
#define TET_SERV_ERR_EYE_TRACKER_INIT		   (TET_SERV_ERR_BASE | 0x5)
#define TET_SERV_ERR_REGISTRY_ERROR		   (TET_SERV_ERR_BASE | 0x6)
#define TET_SERV_ERR_TTIME_UNSUPPORTED		   (TET_SERV_ERR_BASE | 0x7)
#define TET_SERV_ERR_SERVER_ALREADY_RUNNING_OR_PORT_IS_BUSY \
                                                   (TET_SERV_ERR_BASE | 0x8)


/* Recoverable errors TET_SERV_NONFATAL_ERR_XXX				*/
/* One or more socket(s) may be dropped but server will still run.	*/
#define TET_SERV_NONFATAL_ERR_BASE	      (TET_SERV_ERR_BASE | 0x300)
#define TET_SERV_NONFATAL_ERR_IP_RECV_TIMEOUT (TET_SERV_NONFATAL_ERR_BASE | 0x1)
#define TET_SERV_NONFATAL_ERR_SELECT_TIMEOUT  (TET_SERV_NONFATAL_ERR_BASE | 0x2)
#define TET_SERV_NONFATAL_ERR_SOCKET_CLOSED   (TET_SERV_NONFATAL_ERR_BASE | 0x3)
#define TET_SERV_NONFATAL_ERR_MSG_BAD_FORMAT  (TET_SERV_NONFATAL_ERR_BASE | 0x4)
#define TET_SERV_NONFATAL_ERR_ET_ACTION_IMPOSSIBLE \
                                              (TET_SERV_NONFATAL_ERR_BASE | 0x5)
#define TET_SERV_NONFATAL_ERR_ET_INTERNAL     (TET_SERV_NONFATAL_ERR_BASE | 0x6)
#define TET_SERV_NONFATAL_ERR_ET_LOWLEVEL     (TET_SERV_NONFATAL_ERR_BASE | 0x7)


/*									*/
/* tet_protocol.h.							*/
/*									*/

#define TET_PROTOCOL_ERR_NO_ERR			TOB_NO_ERROR
#define TET_PROTOCOL_ERR_BASE			(TOB_ERR_BASE | 0x400)	
#define TET_PROTOCOL_ERR_OPERATION_IMPOSSIBLE_IN_CURRENT_STATE \
                                                (TET_PROTOCOL_ERR_BASE | 0x1)
#define TET_PROTOCOL_ERR_BAD_FORMAT		(TET_PROTOCOL_ERR_BASE | 0x2)
#define TET_PROTOCOL_ERR_INTERNAL		(TET_PROTOCOL_ERR_BASE | 0x3)
#define TET_PROTOCOL_ERR_CAMERA			(TET_PROTOCOL_ERR_BASE | 0x4)
#define TET_PROTOCOL_ERR_DIOD			(TET_PROTOCOL_ERR_BASE | 0x5)
#define TET_PROTOCOL_ERR_CALIB_INCOMPATIBLE_DATA_FORMAT \
                                                (TET_PROTOCOL_ERR_BASE | 0x6)
                                                /* MC2_ERR_OLD_CALIB_FORMAT */
#define TET_PROTOCOL_ERR_CALIB_INSUFFICIENT_DATA \
                                                (TET_PROTOCOL_ERR_BASE | 0x7)
                                                /* MC2_ERR_MAP_NOT_ENOUGH_DATA */
#define TET_PROTOCOL_ERR_CALIB_NO_DATA_SET	(TET_PROTOCOL_ERR_BASE | 0x8)
                                                /* MC2_ERR_NO_CALIB_SET */


/*									*/
/* dcs_protocol.h.							*/
/*									*/

#define DCS_ERR_NO_ERR				TOB_NO_ERROR
#define DCS_ERR_BASE				(TOB_ERR_BASE | 0x500)	
#define DCS_ERR_UNKNOWN_COMMAND			(DCS_ERR_BASE | 0x1)
#define DCS_ERR_BADFORMAT			(DCS_ERR_BASE | 0x2)
#define DCS_ERR_EYE_TRACKER			(DCS_ERR_BASE | 0x3)

 
/*									*/
/* These are possible error codes returned by Cam_GetLastError in camera.dll.*/
/*									*/

#define CAM_ERR_NO_ERROR 			TOB_NO_ERROR
#define CAM_ERR_BASE				(TOB_ERR_BASE | 0x600)	

/* Fatal errors: a new internal call to Cam_Init will be performed	*/
/* next time a function (that requires a sucessful initiation) is called*/
#define CAM_ERR_NOT_INITIALIZED			(CAM_ERR_BASE | 0x1)
                                       /* Camera is not initialized.*/
#define CAM_ERR_CAMERA_NOT_FOUND		(CAM_ERR_BASE | 0x2)
                                       /* Camera or framegrabber not found.*/
#define CAM_ERR_CAMERA_DRIVER_RETURNED_FATAL_ERR (CAM_ERR_BASE | 0x3)
                                       /* Camera driver error.	*/
#define CAM_ERR_MEMORY				(CAM_ERR_BASE | 0x4)
                                       /* Cannot allocate memory.	*/

/* Fatal only if diod controller is required (set as parameter to Cam_Init).*/
/* If fatal a new internal call to Cam_Init will be performed next time a */
/* function (that requires a sucessful initiation) is called. 		*/
#define CAM_ERR_DIOD_USB_INIT_FAILED		(CAM_ERR_BASE | 0x5)
 /* Misc OS error making initiation of diod controller impossible.*/ 
#define CAM_ERR_DIOD_NOT_INITIALIZED		(CAM_ERR_BASE | 0x6)
 /* A successful call to Diod_Init must be performed.	*/
#define CAM_ERR_DIOD_CONTROLLER_NOT_FOUND	(CAM_ERR_BASE | 0x7)
 /* No diod device found.				*/
#define CAM_ERR_DIOD_COMMUNICATION		(CAM_ERR_BASE | 0x8)
 /* Communication error.					*/
#define CAM_ERR_SERIAL_PORT			(CAM_ERR_BASE | 0x9)
 /* Cannot control diods via serial port.		*/

/* Non-fatal errors. no re-initialize camera (Cam_Init) is necessary	*/
#define CAM_ERR_CAMERA_DRIVER_RETURNED_NON_FATAL_ERR	(CAM_ERR_BASE | 0xa)
 /* Camera driver error.						*/
#define CAM_ERR_FILE_OR_DIRECTORY		(CAM_ERR_BASE | 0xb)
 /* Nothing will be dumped. Directory, file name or file name extension error.*/
#define CAM_ERR_CANNOT_DO_THIS_IN_THIS_STATE	(CAM_ERR_BASE | 0xc)
 /* Function should not be called in this state.			*/
#define CAM_ERR_NOT_IMPLEMENTED			(CAM_ERR_BASE | 0xd)
 /* Not implemented.							*/



/*									*/
/* EyeTracker dll error codes, return values from each function.	*/
/*									*/

#define ET_ERR__NO_ERROR 			TOB_NO_ERROR
#define ET_ERR__BASE				(TOB_ERR_BASE | 0x700)	
#define ET_ERR__LOW_LEVEL			(ET_ERR__BASE | 0x1)
 /* Fatal low level error, call ET_GetLastLowLevelError for more info.*/
#define ET_ERR__NOT_INIT			(ET_ERR__BASE | 0x2)
 /* Fatal error, ET has not been initialized.			*/
#define ET_ERR__INTERNAL			(ET_ERR__BASE | 0x3)
 /* An internal error occured, reason unknown.			*/



/*								*/
/* cv_protocol.h.						*/
/*								*/

#define CV_PROTOCOL_ERR_NO_ERR			TOB_NO_ERROR
#define CV_PROTOCOL_ERR_BASE			(TOB_ERR_BASE | 0x800)	
#define CV_PROTOCOL_ERR_OPERATION_IMPOSSIBLE_IN_CURRENT_STATE \
                                                (CV_PROTOCOL_ERR_BASE | 0x1)
#define CV_PROTOCOL_ERR_NOCALIBSET		(CV_PROTOCOL_ERR_BASE | 0x2)
#define CV_PROTOCOL_ERR_BAD_FORMAT		(CV_PROTOCOL_ERR_BASE | 0x3)
#define CV_PROTOCOL_ERR_INTERNAL		(CV_PROTOCOL_ERR_BASE | 0x4)						

/*                                */
/* Mapping and calibration errors */
/*                                */

#define MC2_NO_ERR				TOB_NO_ERROR
#define MC2_ERR_BASE				(TOB_ERR_BASE | 0x900)
#define MC2_ERR_NOT_INIT			(MC2_ERR_BASE | 0x1)
#define MC2_ERR_BAD_FORMAT			(MC2_ERR_BASE | 0x2)
#define MC2_ERR_OLD_CALIB_FORMAT		(MC2_ERR_BASE | 0x3)
#define MC2_ERR_CALC			        (MC2_ERR_BASE | 0x4)
#define MC2_ERR_MAP_NOT_ENOUGH_DATA		(MC2_ERR_BASE | 0x5)
#define MC2_ERR_INTERNAL			(MC2_ERR_BASE | 0x6)
#define MC2_ERR_NO_CALIB_SET			(MC2_ERR_BASE | 0x7)



/*								*/
/* ImageProcessing dll error codes, return values from each function.*/
/*								*/

#define IP_ERR__NO_ERROR 			TOB_NO_ERROR
#define IP_ERR__BASE				(TOB_ERR_BASE | 0xa00)	
#define IP_ERR__NOT_INIT			(IP_ERR__BASE | 0x1)
 /* Fatal error, IP has not been initialized.				*/
#define IP_ERR__BAD_DATA			(IP_ERR__BASE | 0x2)
 /* Fatal error, data into IP had bad format.				*/
#define IP_ERR__INTERNAL			(IP_ERR__BASE | 0x3)
 /* Fatal error, an internal error occured, reason unknown.		*/



#endif /* TOBERROR_H_ */

