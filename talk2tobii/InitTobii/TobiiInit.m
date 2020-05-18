function [ErrorCode, varargout ]= TobiiInit( hostName, portName, win, res, subjNum, StimPaths, AbstPath )
% This is a matlab function that initialises Tobii Connection
% Calibrate Eye Tracker and subscribe gaze data
%
% hostName is the IP address of the PC running the TET server
% win is the handle of the window that has been initialised with the
% psychtoolbox
% res is a vector with the width and the height of the win in pixels
%
% ErrorCode returns 1 if there is an error or 0 if no error
% has occured

%try max_wait times
%each time wait for tim_interv secs before try again
max_wait = 20;
tim_interv = 0.5;

% if you want to make it interesting
FLAGforInfants = 1;

%if subject number is not provided use 0
if(nargin<5)
    subjNum = 0;
    FLAGforInfants = 0;
end


if(FLAGforInfants)
    FixatPath = StimPaths{1};
    CalibPath = StimPaths{2};
    STrackPath = StimPaths{3};
    SLTrackPath = StimPaths{4};
    SCTrackPath = StimPaths{5};
end

%calibration points in X,Y coordinates
if( FLAGforInfants )
    pos = [0.2 0.2;...
        0.8 0.2;
        0.5 0.5;
        0.2 0.8;
        0.8 0.8];
else
    pos = [0.2 0.2;...
        0.5 0.2;
        0.8 0.2;
        0.2 0.5;
        0.5 0.5;
        0.8 0.5;
        0.2 0.8;
        0.5 0.8;
        0.8 0.8];
end
numpoints = length(pos);

%this call is important because it loads the 'GetSecs' mex file!
%without this call the talk2tobii mex file will crash
GetSecs();

%find indexes for correspond keys
ESCAPE = KbName('Escape');
Play = KbName('P');

try
    ifi = Screen('GetFlipInterval',win,100);

    % Init Draw eyes

    %% try to connect to the eyeTracker
    talk2tobii('CONNECT',hostName, portName);

    %check status of TETAPI
    cond_res = check_status(2, max_wait, tim_interv,1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed');
    end

    % Init Draw eyes
    if(FLAGforInfants)
        [Epnts, FixatText, CalibText, SoundNov, LSoundNov, SoundCNov, AbstText ] = InitDrawEyes( win, res, FixatPath, STrackPath, SLTrackPath, CalibPath, SCTrackPath, numpoints, AbstPath );

        lenS = length(SoundCNov);
        lenC = length( CalibText );

    end

    if( nargout>=2 )
        if( exist('SoundNov','var') )
            varargout{1} = SoundNov;
        else
            varargout{1} = [];
        end
    end

    if( nargout>=3 )
        if( exist('LSoundNov','var') )
            varargout{2} = LSoundNov;
        else
            varargout{2} = [];
        end
    end

    if( nargout>=4 )
        if( exist('SoundCNov','var') )
            varargout{3} = SoundCNov;
        else
            varargout{3} = [];
        end
    end

    if( nargout>=5 )
        if( exist('Epnts','var') )
            varargout{4} = Epnts;
        else
            varargout{4} = [];
        end
    end

    if( nargout>=6 )
        if( exist('FixatText','var') )
            varargout{5} = FixatText;
        else
            varargout{5} = [];
        end
    end

    if( nargout>=7 )
        if( exist('FixatText','var') )
            varargout{6} = CalibText;
        else
            varargout{6} = [];
        end
    end
    if( nargout>=8 )
        if( exist('AbstText','var') )
            varargout{7} = AbstText;
        else
            varargout{7} = [];
        end
    end


    calib_not_suc = 1;
    while calib_not_suc


        %% monitor/find eyes
        talk2tobii('START_TRACKING');
        %check status of TETAPI
        cond_res = check_status(7, max_wait, tim_interv,1);
        tmp = find(cond_res==0);
        if( ~isempty(tmp) )
            error('check_status has failed');
        end

        flagNotBreak = 0;
        disp('Press Esc to start calibration');

        if( FLAGforInfants )
            Screen('PlayMovie',LSoundNov{1},1);
        end

        while ~flagNotBreak
            eyeTrack = talk2tobii('GET_SAMPLE');
            if( FLAGforInfants )
                DrawEyes(win, res, eyeTrack(9), eyeTrack(10), eyeTrack(11), eyeTrack(12), eyeTrack(8), eyeTrack(7), FLAGforInfants, Epnts, FixatText );
            else
                DrawEyes(win, res, eyeTrack(9), eyeTrack(10), eyeTrack(11), eyeTrack(12), eyeTrack(8), eyeTrack(7) );
            end

            if( IsKey(ESCAPE) )
                flagNotBreak = 1;
                if( flagNotBreak )
                    break;
                end
            end
            if( IsKey(Play) ) % rewind movie and play again
                Screen('SetMovieTimeIndex', LSoundNov{1}, 0 );
                Screen('PlayMovie',LSoundNov{1},1);
            end
        end

        if( FLAGforInfants )
            Screen('PlayMovie',LSoundNov{1},0);
        end

        talk2tobii('STOP_TRACKING');
        %% start calibration
        %display stimulus in the four corners of the screen
        totTime = 3;        % swirl total display time during calibration

        talk2tobii('START_CALIBRATION',pos,0,'./calibrFileTest.txt');
        %% It is wrong to try to check the status here because the
        %% eyetracker waits for an 'ADD_CALIBRATION_POINT' and 'DREW_POINT'.

        %check for the three flags first
        cond_res = check_status([ 2 4 5], max_wait, tim_interv,[1 1 1]);
        tmp = find(cond_res==0);
        if( ~isempty(tmp) )
            disp(cond_res);
            error('check_status has failed');
        end

        for i=1:numpoints
            position = pos(i,:);
            %            disp(position);
            when0 = GetSecs()+ifi;
            talk2tobii('ADD_CALIBRATION_POINT');
            if( FLAGforInfants )
                k = mod(i,lenS)+1;
                if(k>1)
                    Screen('PlayMovie',SoundCNov{k-1},0);
                end
                Screen('SetMovieTimeIndex', SoundCNov{k}, 0 );
                Screen('PlayMovie',SoundCNov{k},1);
                indexC = mod(i,lenC)+1;
                CalibTextTmp = CalibText(indexC);
            end
            StimulusOnsetTime=swirl(win,totTime,ifi,when0,position,1, FLAGforInfants, CalibTextTmp);
            WaitSecs(0.5);
            talk2tobii('DREW_POINT');
        end

        cond_res = check_status(11, 20, 1, 1);
        tmp = find(cond_res==0);
        if( ~isempty(tmp) )
            error('check_status has failed- CAIBRATION');
        end

        %save quality of calibration
        quality = talk2tobii('CALIBRATION_ANALYSIS');
        save( strcat('quality_Calibration_',num2str(subjNum),'.mat'), 'quality' );
        %display calibration results
        if(length(quality)>1)
            displayQuality( pos, quality, win, res);
        else
            disp('calibration does not have any data');
        end
        %choose if you want to redo the calibration
        %disp('Press space to resume calibration or q to exit calibration and continue tracking');
        tt= input('press "C" and "ENTER" to resume calibration or any other key to continue\n','s');
        if( strcmpi(tt,'C') )
            calib_not_suc = 1;
        else
            calib_not_suc = 0;
        end

    end
    disp('EndOfCalibration');


    Screen('TextSize', win,50);
    Screen('DrawText', win, '+',res(1)/2,res(2)/2,[255 0 0]);
    Screen('Flip', win );

    talk2tobii('RECORD');
    talk2tobii('START_TRACKING');

    %check status of TETAPI
    cond_res = check_status(7, max_wait, tim_interv,1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed');
    end

    ErrorCode = 0;

catch
    ErrorCode = 1;
    rethrow(lasterror);
    talk2tobii('STOP_TRACKING');
    talk2tobii('DISCONNECT');
end

return;



function ctrl=IsKey(key)
global KEYBOARD;
[keyIsDown,secs,keyCode]=PsychHID('KbCheck', KEYBOARD);
if ~isnumeric(key)
    kc = KbName(key);
else
    kc = key;
end
ctrl=keyCode(kc);
return
