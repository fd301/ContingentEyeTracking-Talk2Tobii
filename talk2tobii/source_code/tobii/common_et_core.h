/*  
 *  common_et_core.h :	Tobii private interfaces and defines for 
 *			common tasks.
 *
 *
 *  Change log:
 *  2003-03-04	LK	First version
 *  2004-02-11	GE	Added all ET typedefs.
 *  2004-05-05	GE	Update EET_Hardware enum.
 *
 *  Copyright (C) Tobii Technology 2003, all rights reserved.
 */

#ifndef COMMON_ET_CORE_H_
#define COMMON_ET_CORE_H_

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(_WIN32)
#pragma pack(push, mypack, 1)		/* Ensures MS VC Compiler packs
                                           struct byte by byte
                                           (fully aligned) */
#endif


/* Indeces of left and right eye respectively, in arrays containing */
/* inforamtion for both eyes. */
#define NR_OF_EYES 2
#define EYE_LEFT   0			/* Left eye means left eye in image */
#define EYE_RIGHT  1


/* Position in pixels using base coordinate system (which normally is 	*/
/* based on the largest possible image from camera)			*/ 
/* Origo (first pixel) is (x,y)=(0,0) at the upper left corner of image */
/* x increases to right	*/
/* y increases downwards */
typedef struct _SPos {
	unsigned short x;
	unsigned short y;
} SPos;


/* Same as SPos, but with high precision (double).*/
/* Used in result, since resulting positions are */
/* calculated at a subpixel level.		*/
typedef struct _SPosReal {
	double x;
	double y;
} SPosReal;


/* Interval limiting properties. */
/* min is minimal value (limit included) */
/* max is maximal value (limit included) */
typedef struct _SInterval {
	unsigned short min;
	unsigned short max;
} SInterval;


/* Interval limiting properties.	*/
/* min is minimal value (limit included)*/
/* max is maximal value (limit included)*/
typedef struct _SIntervalReal {
	double min;
	double max;
} SIntervalReal;


/* Ellipse parameters; */
/* Center, in absolute coordinates.*/
/* Axis, minor (2a) and major (2b).*/
/* v is angle from x-axis to minor axis (counter clockwise)*/
typedef struct _SEllipseReal {
	SPosReal center;
	double a;
	double b;
	double v;
} SEllipseReal;


/* Defines an area using base coordinates */
/* Upperleft and lowerright pixel IS included in area.*/
typedef struct _SRegion {
	SPos upperleft; 
	SPos lowerright; 
} SRegion;


/* Defines hardware. Decides image processing		*/
/* method, map method, etc. */
typedef enum _EET_Hardware
{
	hw_ET17			= 1,			/* ET17.	*/
	hw_1750A		= 2,			/* Tobii 1750A.	*/
	hw_1750B		= 3,			/* Tobii 1750B.	*/
	hw_x50			= 4,			/* Tobii x50.	*/
	hw_UNDEFINED	= 0				/*		*/
} EET_Hardware;


/* Defines pupil data validity.				*/
/* Grades how cerain it is that found data belongs	*/
/* to current pupil. 					*/
/* Ex: left eye has validity 'prob', means that it	*/
/* is probable that found data belongs to left eye	*/
/* (but it could belong to right eye).			*/
typedef enum _EET_Validity
{
	val_sure     =0,	/* Sure that data belongs to pupil.*/
	val_prob     =1,	/* Probable that data ...	*/
	val_mightBe  =2,	/* Data might belong to either pupil.	*/
	val_probNot  =3,	/* Probable that data does NOT ... */
	val_sureNot  =4		/* Sure that data does NOT ...	*/
} EET_Validity;


/* Defines simple image data. Position of pupil		*/
/* in image.						*/
typedef struct _SET_ImageData
{
	SPosReal posCamera;			/* Camera image coordinates. */
} SET_ImageData;


/* Defines complete image data. Position of all		*/
/* image objects. Bitfields tells whether objects	*/
/* were found or not. If bitfield is not set,		*/
/* position is undefined.				*/
typedef struct _SET_CompleteImageData
{
	SEllipseReal ellipse;		/* Ellipse parameters.		*/
	SPosReal glintM;		/* Direction glint coordinates.	*/
	SPosReal glint1;		/* Distance glint 1 coordinates.*/
	SPosReal glint2;		/* Distance glint 2 coordinates.*/
	SPosReal glint3;		/* Distance glint 3 coordinates.*/
	SPosReal glint4;		/* Distance glint 4 coordinates.*/
	struct {			/* Objects validity bit field	*/
		unsigned long ellipse : 1;	/* 00000000 0000000X =  1 */
		unsigned long glintM  : 1;	/* 00000000 000000X0 =  2 */
		unsigned long glint1  : 1;	/* 00000000 00000X00 =  4 */
		unsigned long glint2  : 1;	/* 00000000 0000X000 =  8 */
		unsigned long glint3  : 1;	/* 00000000 000X0000 = 16 */
		unsigned long glint4  : 1;	/* 00000000 00X00000 = 32 */
	} isfound;
} SET_CompleteImageData;


/* Defines map data. User gaze point and distance.	*/
typedef struct _SET_MapData
{
	SPosReal screen;		/* Screen (gaze) coordinates.	*/
	float diameter;			/* Pupil diameter.	*/
	float distance;			/* Pupil distance.	*/
} SET_MapData;


/* Defines all gaze data specific for one eye.		*/
/* Mapdata is set if tracking with calibration set	*/
/* and validity is better than 'sureNot'. Imagedata	*/
/* is non-negative is found, and might be set even	*/
/* if validity is 'sureNot'.				*/
typedef struct _SET_OnePupilData {
  SET_ImageData imageData;		   /* Public image data.	*/
  SET_CompleteImageData completeImageData; /* Internal,complete,image data. */
  SET_MapData mapData;		           /* Map data. */
  EET_Validity validity;		   /* Validity.			*/
} SET_OnePupilData;


/* Defines all gaze data.				*/
/* Left means user left, from user point of view.	*/
typedef struct _SET_AllPupilData {
  unsigned long timestamp_sec;	    /* Time stamp from image grab [sec.].*/
  unsigned long timestamp_microsec; /* Time stamp from image grab [microsec].*/
  SET_OnePupilData leftPupilData;   /* All left pupil data.		*/
  SET_OnePupilData rightPupilData;  /* All right pupil data.		*/
} SET_AllPupilData;


/* Defines analyze data specific for one eye.		*/
/* Validity: (-1) not found - (0) not used - (1) used.	*/
typedef struct _SET_OneEyeCalibAnalyzeData
{
	float mapX; 		/* Screen (gaze) x coordinate.		*/
	float mapY; 		/* Screen (gaze) y coordinate.		*/
	long  validity; 	/* Validity measurement.		*/
	float quality; 		/* Quality (yet to be implemented).	*/
} SET_OneEyeCalibAnalyzeData;


/* Defines data to analyze calibration.			*/
/* Left means user left, from user point of view.	*/
typedef struct _SET_CalibAnalyzeData
{
  float truePointX;		/* User view point, x coordinate. */
  float truePointY;		/* User view point, y coordinate. */
  SET_OneEyeCalibAnalyzeData leftCalibData; /* Analyze data for left eye. */
  SET_OneEyeCalibAnalyzeData rightCalibData; /* Analyze data for right eye. */
} SET_CalibAnalyzeData;


/* Defines data to analyze calibration.			*/
/* Left means user left, from user point of view.	*/
typedef struct _SET_AllCalibAnalyzeData
{
	unsigned long nrOfData;			 /* Nr of data.		*/
	SET_CalibAnalyzeData *pCalibAnalyzeData; /* Pointer to array of data.*/
} SET_AllCalibAnalyzeData;


/* Calibration data. 					*/
typedef struct _SET_CalibData
{
	unsigned long length;			/* Length of data array. */
	char *pData;				/* All data.	*/
} SET_CalibData;


/* Specifies eye.					*/
typedef enum _EET_Eye
{
	eye_left   =1,				/* User left eye.	*/
	eye_right  =2,				/* User right eye.	*/
	eye_both   =3				/*			*/
} EET_Eye;


#if defined(_WIN32)
#pragma pack(pop, mypack)	/* Restore MS VC Compiler packing setting */
#endif

	
#if defined(__cplusplus)
}
#endif

#endif /* COMMON_ET_CORE_H_ */
