/*  
 *	tetext.h :	Tobii Eye Tracker API Extensions
 *
 *			Prototypes to interface the Tobii Eye Tracker Server.
 *			Only for internal use. Not exposed for SDK users.
 *	 
 *			Ver 2004-02-11 LK
 *
 *  Copyright (C) Tobii Technology 2004, all rights reserved.
 */

#ifndef TETEXT_H_
#define TETEXT_H_

#include "tet.h"
#include "common_et_core.h"
 

#if defined(__cplusplus)
extern "C" {
#endif


#if defined(_WIN32)
/* Ensures MS VC Compiler packs struct byte by byte (fully aligned) */
#pragma pack(push, mypack, 1)

/* Enable Windows dll export */
#define	DLL_EXPORT __declspec (dllexport) 
#else
#define	DLL_EXPORT
#define __stdcall
#endif


/* Internal declaration not to expose for external sdk users.	*/
/* The first part of struct (STet_GazeData) is exposed in		*/
/* tet.h header.							*/

typedef struct _STet_GazeDataExtended {
	STet_GazeData gz;  
	SET_CompleteImageData gze_left;	
	SET_CompleteImageData gze_right;	
} STet_GazeDataExtended;


/* Usage: Cast Fnc paramter pData to STet_GazeDataExtended to get extended */
/* data if reason is TET_CALLBACK_GAZE_DATA */
DLL_EXPORT long __stdcall Tet_StartPassive(Tet_CallbackFunction Fnc, void *pApplicationData, unsigned long interval);
DLL_EXPORT long __stdcall Tet_DumpImages(unsigned long nrofimages, unsigned long frequency);


#if defined(_WIN32)
#pragma pack(pop, mypack)	/* Restore MS VC Compiler packing setting */
#endif

#if defined(__cplusplus)
}
#endif


#endif /* TETEXT_H_ */
