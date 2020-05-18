function TALK2TOBII
% "\n===============================================================================\n"
% "This is a tobii MEX-file for interfacing the TETSERVER with Matlab.\n"
% "This program is distributed with the hope that it will be useful,\n"
% "but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY"
% "OR FITNESS FOR A PARTICULAR PURPOSE.\n"
% "UNDER NO CIRCUMSTANCES SHALL THE AUTHORS BE LIABLE FOR ANY INCIDENTAL,\n"
% "SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES ARISING OUT OF OR RELATING TO\n"
% "THIS PROGRAM.\n"
% "\n"
% "Written by Fani Deligianni, email: f.deligianni@bbk.ac.uk \n"
% "Centre of Brain and Cognitive Development, Birkbeck University, London, UK. \n"
% "   http://www.cbcd.bbk.ac.uk/ \n\n"
% "===============================================================================\n\n"
% 11/07/2007
%
% This mex function is written in c++ and uses multi-threading to allow 
% building contingent eyetracking applications. It creates a 'tobii' thread
% that handles the communication between the underlyined application and the 
% TETserver. 
% The main matlab thread handles the display and any additional computation
% required. Eye tracking data and status can be acquired online so that the
% stimulus presentation may be updated accordingly.
% This function can be combined with the psychtoolbox that is able to deliver
% accurate stimulus presentation. 
%
% Contents:
% TALK2TOBII('CONNECT',hostname);
% TALK2TOBII('DISCONNECT');
% TALK2TOBII('START_TRACKING');
% TALK2TOBII('STOP_TRACKING');
% [status,history] = TALK2TOBII('GET_STATUS');
% TALK2TOBII('CLEAR_HISTORY');
% gazeData=TALK2TOBII('GET_SAMPLE');
% TALK2TOBII('START_CALIBRATION',calibration_pnts,load_calibration,filename);
% TALK2TOBII('ADD_CALIBRATION_POINT');
% TALK2TOBII('DREW_POINT');
% quality = TALK2TOBII('CALIBRATION_ANALYSIS');
% TALK2TOBII('SYNCHRONISE');
% TALK2TOBII('EVENT',Event_Name, duration, 'nameOfField', value, ...);
% TALK2TOBII('RECORD');
% TALK2TOBII('STOP_RECORD');
% TALK2TOBII('SAVE_DATA', eye_trackin_data, events, 'APPENDorTRUNK');
% TALK2TOBII('CLEAR_DATA');
%
%
% 
% TALK2TOBII('CONNECT',hostname);
% Sets a flag that allows the tobii thread to connect to the TETserver via TCP/IP. 
% 'hostname' is the ip address of the pc that runs the TETserver. This function 
% does not return any value. If an error has been occured cannot be detected with
% this function. Use 'GET_STATUS' to check the status of the connection with the 
% TET server and to detect any errors. 
% 
%
%
% TALK2TOBII('DISCONNECT');
% Sets a flag that allows the tobii thread to disconnect. If the tobii thread is 
% not connected with the TETserver nothing happens. This function does not destroy 
% tobii thread. Tobii tread is destroyed when the TALK2TOBII  
%
%
% 
% TALK2TOBII('START_TRACKING');
% Sets a flag that allows the tobii thread to start subscribing gaze data. 
% If the tobii thread is not connected with the TETserver nothing happens. 
% This function does not return any value. If an error has been occured 
% cannot be detected with this function. Use 'GET_STATUS' to check the status 
% of the connection with the TET server and to detect any errors. 
% 
%
% 
% TALK2TOBII('STOP_TRACKING');
% Sets a flag that allows the tobii thread to stop the subscription of gaze data. 
% If the tobii thread is not connected with the TETserver nothing happens. 
% This function does not return any value. If an error has been occured 
% cannot be detected with this function. Use 'GET_STATUS' to check the status 
% of the connection with the TET server and to detect any errors. 
% 
%
% 
% [status,history] = TALK2TOBII('GET_STATUS');
% This function returns an array with 0 or 1 describing bits that correspond
% to the following values, respectively:
% TET_API_CONNECT         -> to request connection
% TET_API_CONNECTED       -> 1 indicates that the communication with the 
%                             TETserver has been initialised succesfully
% TET_API_DISCONNECT      -> to request terminating the connection
% TET_API_CALIBRATING     -> to request calibration
% TET_API_CALIBSTARTED    -> 1 indicates that previous calibration has been 
%                             cleared succesfully and the calibration process
%                             has been started.
% TET_API_RUNNING         -> to request the subscription of eye tracking data
% TET_API_RUNSTARTED      -> 1 indicates that the subscription of gaze data
%                             has been initialised succesfully.
% TET_API_STOP            -> to request stopping the subscription of gaze data
% TET_API_FINISHED        -> 1 indicates that the tobii thread has exit
% TET_API_SYNCHRONISE     -> 1 indicates that synchronisation process has
%                             started
% TET_API_CALIBEND        -> 1 indicates that calibration has finished
% TET_API_SYNCHRONISED    -> 1 indicates that host and remote computer has 
%                             been synchronised
% 'history' is an m-by-2 array that records whether the main calls to the 
% TET API were succesful and a timestamp as it is recorded by GetSecs 
% after the function's call. 
% The first column of this array are integer values from 1-12 if an error
% has occur or integer values above 100 if an error has not occur:
% 0 -> 'Problem initialising tobii' (Tet_Init has failed)
% 1 -> 'Problem connecting with tobii' (Tet_Connect failed)
% 2 -> 'Problem clearing calibration' (Tet_CalibClear failed)
% 3 -> 'Problem adding Calibration point' (Tet_CallibAddPoint failed)
% 4 -> 'Warning: Problem calculating and setting calibration 
%      (Tet_CalibCalculateAndSet failed)
% 5 -> 'Warning: Pronlem getting calibration results (Tet_CalibGetResult
%      failed)
% 6 -> 'Warning: Problem saving calibration' (Tet_CalibSaveToFile failed)
% 7 -> 'Warning: Synchronisation failed' (Tet_Synchronise failed)
% 8 -> 'Problem starting tracking! EyeTracker will disconnect' (Tet_Start 
%      failed)
% 9 -> 'Warning: Problem loading calibration file' (Tet_CalibLoadFromFile 
%      failed)
% 100 -> 'connecting with tobii...success' (Tet_Connect was successful)
% 200 -> 'clearing calibration...success' (Tet_CalibClear was successful)
% 300 -> 'adding calibration point...success' (Tet_CallibAddPoint was 
%      successful)
% 400 -> 'calculating and setting calibration...success' 
%      (Tet_CalibCalculateAndSet was successful)
% 500 -> 'Calibration results have been obtained' (Tet_CalibGetResult
%      was successful)
% 600 -> 'Calibration have been saved' (Tet_CalibSaveToFile was successful)
% 700 -> 'Synchronised maximal error...' (Tet_Synchronise was successful)
% 800 -> 'starting track...success' (Tet_Start was successful)
% 900 -> 'Calibration has been loaded' (Tet_CalibLoadFromFile 
%      was successful)
%
%
%
% TALK2TOBII('CLEAR_HISTORY');
% Discard previous history records. See the 'GET_STATUS' for more
% information on what history contains.
%
%
%
% gazeData=TALK2TOBII('GET_SAMPLE');
% Use this function to receive online gaze data
% It returns an array 'gazeData' with the following fields:
% x coordinate of the left eye
% y coordinate of the left eye
% x coordinate of the right eye
% y coordinate of the right eye
% time in Sec returned from the TETserver
% time in mSec returned form the TETserver
% left eye validity 
% right eye validity
%               (Validity indicates how likely is it that the eye is found)
%               0 - Certainly (>99%),
%               1 - Probably (80%),
%               2 - (50%),
%               3 - Likely not (20%),
%               4 - Certainly not (0%)
% left camera eye position - x coordinate
% left camera eye position - y coordinate
% right camera eye position - x coordinate
% right camera eye position - y coordinate
% 
%
% 
% TALK2TOBII('START_CALIBRATION',calibration_pnts,load_calibration,filename);
% This function implements the following steps:
% 1. calibration_pnts sets the calibration points. This should be an m-by-2 
% array where m is the number of points and the columns correspond to the x 
% and y coordinates respectively. The coordinates take values from 0 to 1.
% 2. load_calibration sets a flag that defines if a stored calibration will be
%    loaded (This feature is not implemented yet)
%    'filename' is the filename of the calibration file to be loaded if 
%    load_calibration is 1 or the filename to store a succesful calibration if 
%    load_calibration is 0.
% 3. Sets a flag that allows the tobii thread to start calibrating
% 
%
%
% TALK2TOBII('ADD_CALIBRATION_POINT');
% It informs the tobii thread that the drawing of the next point has been started
% and it blocks the thread till the eye tracker is ready to continue. 
% 
%
% 
% TALK2TOBII('DREW_POINT');
% It signals the tobii thread that the drawing of the calibration point has been
% finished and calibration can be continue with the next point.
% 
%
% 
% The three last functions are combined to calibrate the Tobii eye tracker.
% If there are not used properly the tobii thread MAY LOCK and do not allow 
% further interaction. See example code of how to use them properly.
% 
%
% 
% quality = TALK2TOBII('CALIBRATION_ANALYSIS');
% It returns an array of the data acquired during calibration and their 
% accuracy.
% 
%
% 
% TALK2TOBII('SYNCHRONISE');
% It synchronises the host pc time to the TETserver.
% 
%
% 
% TALK2TOBII('EVENT',Event_Name, start_time, duration, 'nameOfField', value, ...);
% Use this function to record events:
% 'Event_Name' is a string that specifies the event
% 'duration' specifies the time that the event last (set constant if it is not
%             required).
% An unlimited number of pair values can be specified with the following format:
% 'nameOfField', numerical value that corresponds to this field. 
% 
%
% 
% TALK2TOBII('RECORD');
% It calls the TALK2TOBII('SYNCHRONISE') and it sets a flag to start recording
% the eyetracking data. Data are stored in memory and they are not saved on 
% hard drive unless 'SAVE_DATA' is called. This function does not start the 
% subscription of eye tracking data. Normally 'START_TRACKING' is called prior
% to this function.
% 
%
% 
% TALK2TOBII('STOP_RECORD');
% Sets a flag that prevents further eye tracking data to store on memory
% 
%
% 
% TALK2TOBII('SAVE_DATA', eye_trackin_data, events, 'APPENDorTRUNK');
% It writes in text files both the eye tracking data and events.
% 'Eye_tracking_data' specifies the filename that will be used to store 
% the data collected from tobii. The eye tracking data are stored in
% columns in the following order:
% time in sec
% time in msec
% x gaze coordinate of the left eye
% y gaze coordinate of the left eye
% x gaze coordinate of the right eye
% y gaze coordinate of the right eye
% left camera eye position - x coordinate
% left camera eye position - y coordinate
% right camera eye position - x coordinate
% right camera eye position - y coordinate
% left eye validity
% right eye validity
% diameter of pupil of the left eye
% diameter of pupil of the right eye
% distance of the camera from the left eye
% distance of the camera from the right eye
% 'events' specifies the filename that it will be used to store the events
% as they are specified during an 'EVENT' call. 
% A '#START timestamp' provides a timestamp of when gaze data subscription
% started. This time is acquired with a call to the psychtoolbox function
% 'GetSecs'.
% 'APPENDorTRUNK'-> use 'APPEND' to allow appending data to existing file or 
% 'TRUNK' to delete any previous data stored in the specified file.
% 
%
% 
% TALK2TOBII('CLEAR_DATA');
% Discard eye tracking data and events stored in memory
%
% 11/07/2007
