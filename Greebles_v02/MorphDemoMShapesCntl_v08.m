%function vpos = MorphDemoMShapes_v03(textureon, dotson, normalson, stereomode, usefastoffscreenwindows)
close all;
clear all;
% function MorphDemo([textureon][, dotson][, normalson][, stereomode][,
% usefastoffscreenwindows])
% MorphDemo -- Demonstrates use of "moglmorpher" for fast morphing
% and rendering of 3D shapes. See "help moglmorpher" for info on
% moglmorphers purpose and capabilities.
%
% This demo will load two morpheable shapes from OBJ files and then
% morph them continously into each other, using a simple sine-function
% to define the timecourse of the morph.
%
% Control keys and their meaning:
% 'a' == Zoom out by moving object away from viewer.
% 'z' == Zoom in by moving object close to viewer.
% 'k' and 'l' == Rotate object around axis.
% 'q' == Quit demo.
%
% Options:
%
% textureon = If set to 1, the objects will be textured, otherwise they will be
% just shaded without a texture. Defaults to zero.
%
% dotson = If set to 0 (default), just show surface. If set to 1, some dots are
% plotted to visualize the vertices of the underlying mesh. If set to 2, the
% mesh itself is superimposed onto the shape. If set to 3 or 4, then the projected
% vertex 2D coordinates are also visualized in a standard Matlab figure window.
%
% normalson = If set to 1, then the surface normal vectors will get visualized as
% small green lines on the surface.
%
% stereomode = n. For n>0 this activates stereoscopic rendering - The shape is
% rendered from two slightly different viewpoints and one of Psychtoolbox's
% built-in stereo display algorithms is used to present the 3D stimulus. This
% is very preliminary so it doesn't work that well yet.
%
% usefastoffscreenwindows = If set to 0 (default), work on any graphics
% card. If you have recent hardware, set it to 1. That will enable support
% for fast offscreen windows - and a much faster implementation of shape
% morphing.
%
% This demo and the morpheable OBJ shapes were contributed by
% Dr. Quoc C. Vuong, MPI for Biological Cybernetics, Tuebingen, Germany.
morphnormals = 1;
morphnormals1 = 1;
morphnormals2 = 1;
morphnormals3 = 1;
morphnormals4 = 1;

global win;

% Is the script running in OpenGL Psychtoolbox?
AssertOpenGL;

% Should per pixel lighting via OpenGL shading language be used? This doesnt work
% well yet.
perpixellighting = 0

dotson = [];
normalson = [];
stereomode = [];
usefastoffscreenwindows = 0;


if nargin < 2 | isempty(dotson)
    dotson = 0;     % turn reference dots: off(0), on (1) or show reference lines (2)
end
dotson

if nargin < 3 | isempty(normalson)
    normalson = 0;     % turn reference dots: off(0), on (1) or show reference lines (2)
end
normalson

if nargin < 4 | isempty(stereomode)
    stereomode = 0;
end;
stereomode

if nargin < 5 | isempty(usefastoffscreenwindows)
    usefastoffscreenwindows = 0;
else
    kPsychNeedFastOffscreenWindows = 1;
end
usefastoffscreenwindows

% Response keys: Mapping of keycodes to keynames.
quitkey = KbName('q'); 
sound1 = KbName('1!');
sound2 = KbName('2@');
sound3 = KbName('3#');
sound4 = KbName('4$');
sound5 = KbName('5%');
MouseKey = KbName('m');
CalibBut = KbName('C');
%ESCAPE = KbName('Escape');
%Play = KbName('P');

%clear command window
clc;

%eyetracker: record or playback-capture screen
EYETRACKER = 1;
CNTRLCOND = 0;
PLAYBACK = 0;
CAPTURESCREEN = 0;
PLOT_ELLIPSE_PNTS = 0;
disp( strcat('EYETRACKER=', num2str(EYETRACKER) ) );
disp( strcat('CNTRLCOND=', num2str(CNTRLCOND) ) );
disp( strcat('PLAYBACK=', num2str(PLAYBACK) ) );
disp( strcat('CAPTURESCREEN=', num2str(CAPTURESCREEN) ) );
disp( strcat('PLOT_ELLIPSE_PNTS=', num2str(PLOT_ELLIPSE_PNTS) ) );

SUBJECT=input('Test Subject number: ');
if(CNTRLCOND)
    SUBJECT_PRO=input('Pro Subject number: ');
end
inputPathEvents = strcat('./events_rot_',num2str(SUBJECT),'.txt');
inputPathEyeTracking = strcat('./Tracking_rot_', num2str(SUBJECT), '.txt');
%DataFile = './EllipsePoints_rot.mat';
outPicDir = './picts_rot';
outPicName = 'pict_';
%hostName = '169.254.6.97'; %T120
hostName = '193.61.45.213'; %1750
port = 4455;

%stimulus
FixatPath = '../common/stimulus/fixation';
CalibPath = '../common/stimulus/calibration';
STrackPath = '../common/stimulus/sounds';
SLTrackPath = '../common/stimulus/long_music';
SCTrackPath = '../common/stimulus/sounds_calib';
AbstPath = '../common/stimulus/abstract_pict';

% FixatPath = '/Users/cbcd/Documents/Fani/common/stimulus/fixation';
% CalibPath = '/Users/cbcd/Documents/Fani/common/stimulus/calibration';
% STrackPath = '/Users/cbcd/Documents/Fani/common/stimulus/sounds';
% SLTrackPath = '/Users/cbcd/Documents/Fani/common/stimulus/long_music';
% SCTrackPath = '/Users/cbcd/Documents/Fani/common/stimulus/sounds_calib';
StimPaths = {FixatPath,CalibPath,STrackPath,SLTrackPath,SCTrackPath };

%create colors for middle object
a = 0.1:1/20:1;
b = 0.9:-1/20:0;
c = zeros(1,19);
ColArray = [a' b' c'; b' c' a'; c' a' b'];
ColLen = length(ColArray);


if( PLAYBACK && EYETRACKER)
    EYETRACKER = 0;
    warning('PLAYBACK is on, eyetracking has been disabled.');
end

% keep a log file
if( EYETRACKER)
    diary(['TEST_' num2str(SUBJECT) '.log']);
end

if(PLAYBACK)
    FieldNames = {'EyeEventSec','EyeEventMsec','ThetaEvent', 'AngEvent',...
        'w_1','w_2','w_3','w_4','w_5', ...
        'numObj', 'Obj1', 'Obj2', 'Obj3', 'Obj4' };
    EventNames = {'FLIP','NOFLIP','BREAK','CALIB_START','CALIB_END'};
    [TimeLine, EyeTrackingInfo, ...
        EyeEventSec, EyeEventMsec, ThetaEvent, AngEvent, ...
        w_1, w_2, w_3, w_4, w_5, ...
        numObj, Obj1, Obj2, Obj3, Obj4, ...
        IndexSamples, SynchSamples, EyeTrackingData, ...
        BreaksOut, CalBreaks, ...
        IndF] = ...
        InitEyeEventsForPlayBack_v3(inputPathEvents, inputPathEyeTracking, FieldNames, EventNames, SUBJECT);
    EyeEventSec = EyeEventSec(:,2);
    EyeEventMsec = EyeEventMsec(:,2);
    ThetaEvent = ThetaEvent(:,2);
    AngEvent = AngEvent(:,2);
    w_1 = w_1(:,2);
    w_2 = w_2(:,2);
    w_3 = w_3(:,2);
    w_4 = w_4(:,2);
    w_5 = w_5(:,2);
    
    numObjAll = numObj(:,2);
    clear numObj;
    
    Obj1 = Obj1(:,2);
    Obj2 = Obj2(:,2);
    Obj3 = Obj3(:,2);
    Obj4 = Obj4(:,2);

    SynchIndex = SynchSamples(:,1);
        
    %to improve time accuracy of playback, use morph of an object only if
    %it has changed
    lenPlaytmp = length(TimeLine);
    Morph1 = zeros(lenPlaytmp,1);
    Morph1(1) = 1;
    Morph1( IndF{5}+1 ) = 1;
    Morph2 = zeros(lenPlaytmp,1) -1;
    Morph2(1) = 1;
    Morph2( IndF{6}+1 ) = 1;
    Morph3 = zeros(lenPlaytmp,1) -1;
    Morph3(1) = 1;
    Morph3( IndF{7}+1 ) = 1;
    Morph4 = zeros(lenPlaytmp,1) -1;
    Morph4(1) = 1;
    Morph4( IndF{8}+1 ) = 1;
    Morph5 = zeros(lenPlaytmp,1) -1;
    Morph5(1) = 1;
    Morph5( IndF{9}+1 ) = 1;
            
    %Playback data of around 20Hz minimum
    [rE, cE] = size(EyeTrackingData);
    
    if(cE==17)
        EyeTrackingInfoN = EyeTrackingInfo;
        EyeTrackTLine = EyeTrackingData(:,end);
        SynchIndexN = SynchIndex;
        TimeLineN = TimeLine;
        ThetaEventN = ThetaEvent;
        AngEventN = AngEvent;
        w_1N = w_1;
        w_2N = w_2;
        w_3N = w_3;
        w_4N = w_4;
        w_5N = w_5;
        numObjAllN = numObjAll;
        Obj1N = Obj1;
        Obj2N = Obj2;
        Obj3N = Obj3;
        Obj4N = Obj4;
        
        Morph1N = Morph1;
        Morph2N = Morph2;
        Morph3N = Morph3;
        Morph4N = Morph4;
        Morph5N = Morph5;

        DSample = diff(SynchIndex);
        tmpInd = find(DSample>=5);
        ShiftPos = 0;
        for i=1:length(tmpInd)
            indW = tmpInd(i);
            tmp = DSample( indW );
            timX = floor( (tmp-2)/3 );
            %tmpPos = SynchIndex(indW);
            tmpPos = indW;
            tmpPos = tmpPos+ShiftPos;
            for j=1:timX
                %find which eyetracking data you display
                %add this index
                tmpETind = SynchIndexN(tmpPos)+3;
                SynchIndexN = cat( 1, SynchIndexN(1:tmpPos), tmpETind, SynchIndexN(tmpPos+1:end) );
                ShiftPos = ShiftPos+1;

                %find out when are you going to display them
                TimeLineN = cat(1, TimeLineN(1:tmpPos), EyeTrackingData(tmpETind,end), TimeLineN(tmpPos+1:end) );

                %concatenate arrays of rest info (w's, angles etc )
                ThetaEventN = cat(1, ThetaEventN(1:tmpPos), ThetaEventN(tmpPos), ThetaEventN(tmpPos+1:end));
                AngEventN = cat(1, AngEventN(1:tmpPos), AngEventN(tmpPos), AngEventN(tmpPos+1:end));
                w_1N = cat(1, w_1N(1:tmpPos), w_1N(tmpPos), w_1N(tmpPos+1:end) );
                w_2N = cat(1, w_2N(1:tmpPos), w_2N(tmpPos), w_2N(tmpPos+1:end) );
                w_3N = cat(1, w_3N(1:tmpPos), w_3N(tmpPos), w_3N(tmpPos+1:end) );
                w_4N = cat(1, w_4N(1:tmpPos), w_4N(tmpPos), w_4N(tmpPos+1:end) );
                w_5N = cat(1, w_5N(1:tmpPos), w_5N(tmpPos), w_5N(tmpPos+1:end) );
                numObjAllN = cat(1, numObjAllN(1:tmpPos), numObjAllN(tmpPos), numObjAllN(tmpPos+1:end));
                Obj1N = cat(1, Obj1N(1:tmpPos), Obj1N(tmpPos), Obj1N(tmpPos+1:end) );
                Obj2N = cat(1, Obj2N(1:tmpPos), Obj2N(tmpPos), Obj2N(tmpPos+1:end) );
                Obj3N = cat(1, Obj3N(1:tmpPos), Obj3N(tmpPos), Obj3N(tmpPos+1:end) );
                Obj4N = cat(1, Obj4N(1:tmpPos), Obj4N(tmpPos), Obj4N(tmpPos+1:end) );
                EyeTrackingInfoN = cat(1, EyeTrackingInfoN(1:tmpPos,:), EyeTrackingInfoN(tmpPos,:), EyeTrackingInfoN(tmpPos+1:end,:) );

                Morph1N = cat(1, Morph1N(1:tmpPos), 0, Morph1N(tmpPos+1:end) );
                Morph2N = cat(1, Morph2N(1:tmpPos), -1, Morph2N(tmpPos+1:end) );
                Morph3N = cat(1, Morph3N(1:tmpPos), -1, Morph3N(tmpPos+1:end) );
                Morph4N = cat(1, Morph4N(1:tmpPos), -1, Morph4N(tmpPos+1:end) );
                Morph5N = cat(1, Morph5N(1:tmpPos), -1, Morph5N(tmpPos+1:end) );

%                 if( BreaksOut(tmpPos+1)==1 )
%                     BreaksOut = cat(1, BreaksOut(1:tmpPos), 1, BreaksOut(tmpPos+1:end) );
%                 else
%                     BreaksOut = cat(1, BreaksOut(1:tmpPos), 0, BreaksOut(tmpPos+1:end) );
%                 end
                CalBreaks = cat(1, CalBreaks(1:tmpPos), CalBreaks(tmpPos), CalBreaks(tmpPos+1:end) );

                tmpPos = tmpPos+1;

            end
        end
        EyeTrackingInfo = EyeTrackingInfoN; 
        SynchIndex = SynchIndexN;
        TimeLine = TimeLineN;
        ThetaEvent = ThetaEventN;
        AngEvent = AngEventN;
        w_1 = w_1N;
        w_2 = w_2N;
        w_3 = w_3N;
        w_4 = w_4N;
        w_5 = w_5N;
        numObjAll = numObjAllN;
        Obj1 = Obj1N;
        Obj2 = Obj2N;
        Obj3 = Obj3N;
        Obj4 = Obj4N;
        
        Morph1 = Morph1N;
        Morph2 = Morph2N;
        Morph3 = Morph3N;
        Morph4 = Morph4N;
        Morph5 = Morph5N;
        
        clear SynchIndexN TimeLineN ThetaEventN AngEventN w_1N w_2N w_3N w_4N w_5N;
        clear EyeTrackingInfoN numObjAllN Obj1N Obj2N Obj3N Obj4N;
        clear Morph1N Morph2N Morph3N Morph4N Morph5N;
    end

    TimeLine0 = TimeLine;
    TimeLine = TimeLine - TimeLine(1);
    TimeLineR = [diff(TimeLine);0];
    
    if( length(BreaksOut) ==1 )
        BreaksOut = zeros( length(TimeLineR), 1);
    else
        BreaksOutN = zeros( length(TimeLineR), 1);
        TimLBrkST = BreaksOut(:,3) - TimeLine0(1);
        TimLBrkFn = BreaksOut(:,4) - TimeLine0(1);        
        for i=1:length(TimLBrkST)
            dist = TimeLine - TimLBrkST(i);
            [tmp xx] = min( abs(dist) );
            dist = TimeLine - TimLBrkFn(i);
            [tmp yy] = min( abs(dist) );
            BreaksOutN(xx:yy) = 1;
        end
        BreaksOut = BreaksOutN;
    end
    
    lenPlayBack = length(TimeLine);
    lenPlay = lenPlayBack;
    
else
    lenPlay = 1800000;
end

if(CNTRLCOND)
    filename = fullfile( pwd, strcat('eventsC_',num2str(SUBJECT_PRO),'.mat' ) );
    
    if( exist(filename,'file') )
        load(filename);
        disp('Cond events loaded from mat file.');
    else
        disp('.mat cond events file does not exist.');
        disp('Cond Events will be loaded from text file... usually takes several minutes');
        
        filename2 = strcat('./events_rot_',num2str(SUBJECT_PRO),'.txt');
        
        FieldNames{1} = {'ThetaEvent', 'AngEvent',...
            'w_1','w_2','w_3','w_4','w_5', ...
            'numObj', 'Obj1', 'Obj2', 'Obj3', 'Obj4' };
        FieldNames{2} = {'EyeEventSec'};
        EventNames = {'FLIP'};
        [TimeLine, ...
            ThetaEvent, AngEvent, ...
            w_1, w_2, w_3, w_4, w_5, ...
            numObj, Obj1, Obj2, Obj3, Obj4, ...
            BreaksInd, numEF, IndF] = ...
            InitEyeEventsForCntrlCond_v2(filename2, FieldNames, EventNames, SUBJECT_PRO);
        ThetaEvent = ThetaEvent(:,2);
        AngEvent = AngEvent(:,2);
        w_1 = w_1(:,2);
        w_2 = w_2(:,2);
        w_3 = w_3(:,2);
        w_4 = w_4(:,2);
        w_5 = w_5(:,2);

        numObjAll = numObj(:,2);
        clear numObj;

        Obj1 = Obj1(:,2);
        Obj2 = Obj2(:,2);
        Obj3 = Obj3(:,2);
        Obj4 = Obj4(:,2);
        
        lenPlayBack = length(TimeLine);
        lenPlay = lenPlayBack;
        
        TurnEventH = zeros(lenPlay,1);
        TurnEventH(1) = 1;
        TurnEventH( IndF{1}+1 ) = 1;
        
        Morph1 = zeros(lenPlay,1);
        Morph1(1) = 1;
        Morph1( IndF{3}+1 ) = 1;
        Morph2 = zeros(lenPlay,1) -1;
        Morph2(1) = 1;
        Morph2( IndF{4}+1 ) = 1;
        Morph3 = zeros(lenPlay,1) -1;
        Morph3(1) = 1;
        Morph3( IndF{5}+1 ) = 1;
        Morph4 = zeros(lenPlay,1) -1;
        Morph4(1) = 1;
        Morph4( IndF{6}+1 ) = 1;
        Morph5 = zeros(lenPlay,1) -1;
        Morph5(1) = 1;
        Morph5( IndF{7}+1 ) = 1;
        
        save(filename, 'TimeLine','ThetaEvent','AngEvent',...
                        'w_1','w_2','w_3','w_4','w_5','numObjAll','Obj1','Obj2','Obj3','Obj4', ...
                        'BreaksInd', 'numEF', ...
                        'TurnEventH','Morph1','Morph2','Morph3','Morph4','Morph5');
                            
    end

    TimeLine = TimeLine - TimeLine(1);
    TimeLineR = [ diff(TimeLine);0 ];
    
    filterBreaks = find(TimeLineR>10);
    if( ~isempty(filterBreaks) )
        warning('there are break time intervals that will be excluded!');
        disp( filterBreaks );
        disp( TimeLineR(filterBreaks) );
        TimeLineR(filterBreaks) = 0;
    end
    
    lenPlayBack = length(TimeLine);
    lenPlay = lenPlayBack;
    
    %you should break here
    Break_flag = zeros(lenPlay,1);
    Break_flag( BreaksInd(1:numEF(1),2) ) = 1; 
    
    %you should start music here
    w_1M_flag = zeros(lenPlay,1);
    w_1M_flag( BreaksInd(1:numEF(3),5) ) = 1; 
    
    w_2M_flag = zeros(lenPlay,1);
    w_2M_flag( BreaksInd(1:numEF(4),7) ) = 1; 

    w_3M_flag = zeros(lenPlay,1);
    w_3M_flag( BreaksInd(1:numEF(5),9) ) = 1; 
    
    w_4M_flag = zeros(lenPlay,1);
    w_4M_flag( BreaksInd(1:numEF(6),11) ) = 1; 
    
    w_5M_flag = zeros(lenPlay,1);
    w_5M_flag( BreaksInd(1:numEF(7),13) ) = 1; 
end

% Load OBJs. This will define topology and use of texcoords and normals:
% One can call LoadOBJFile() multiple times for loading multiple objects.
% shape 1
% file1 = './m1_12_a.obj';
% tmpobj = LoadOBJFile_v02(file1);
% tmpobj{1} = centreMesh(tmpobj{1},0);

%load from saved mat file to save time
loadFromSaved = 1;

if( loadFromSaved )
    load('./ObjMesh.mat');
else

    %shape 1
    file2 = './Fb3_n01.obj';
    tmpobjSh2 = LoadOBJFile_v02(file2);
    tmpobjSh2{1} = sortObj_v2(tmpobjSh2{1});
    tmpobjSh2{1} = centreMesh_v2(tmpobjSh2{1},2, [0,0,0],3);
    fribble2{1} = morphFribble_v3(tmpobjSh2, [], 7);
    objs = {tmpobjSh2{1} fribble2{1}};

    %shape 2
    file3 = './Fb3_n02.obj';
    tmpobjSh3 = LoadOBJFile_v02(file3);
    tmpobjSh3{1} = sortObj_v2(tmpobjSh3{1});
    tmpobjSh3{1} = centreMesh_v2(tmpobjSh2{1},2, [0,0,0], 3);
    fribble3{1} = morphFribble_v3(tmpobjSh3, [3], 5);
    objs1 = {tmpobjSh3{1} fribble3{1}};

    %shape 3
    file4 = './Fb3_n03.obj';
    tmpobjSh4 = LoadOBJFile_v02(file4);
    tmpobjSh4{1} = sortObj_v2(tmpobjSh4{1});
    tmpobjSh4{1} = centreMesh_v2(tmpobjSh4{1},2, [0,0,0],34);
    fribble4{1} = morphFribble_v3(tmpobjSh4, [1], 1);
    objs2 = {tmpobjSh4{1} fribble4{1}};

    file5 = './Fb3_n04.obj';
    tmpobjSh5 = LoadOBJFile_v02(file5);
    tmpobjSh5{1} = sortObj_v2(tmpobjSh5{1});
    tmpobjSh5{1} = centreMesh_v2(tmpobjSh5{1},2, [0,0,0],2);
    fribble5{1} = morphFribble_v3(tmpobjSh5, [3 4 5 6 7 8], 4);
    objs3 = {tmpobjSh5{1} fribble5{1}};

    file6 = './Fb3_n05.obj';
    tmpobjSh6 = LoadOBJFile_v02(file6);
    tmpobjSh6{1} = sortObj_v2(tmpobjSh6{1});
    tmpobjSh6{1} = centreMesh_v2(tmpobjSh6{1},2, [0,0,0],33);
    fribble6{1} = morphFribble_v3(tmpobjSh6, 34, 3);
    objs4 = {tmpobjSh6{1} fribble6{1}};

    playtest_v2( tmpobjSh2, tmpobjSh3, tmpobjSh4, tmpobjSh5, tmpobjSh6);
    playtest_v3( tmpobjSh2, fribble2 );
    playtest_v3( tmpobjSh3, fribble3 );
    playtest_v3( tmpobjSh4, fribble4 );
    playtest_v3( tmpobjSh5, fribble5 );
    playtest_v3( tmpobjSh6, fribble6 );
    
    save ObjMesh.mat objs objs1 objs2 objs3 objs4;

end

if(~exist('IndStore','var'))
    IndStore = [];
end

%to check whether data have been saved
flagDataStored = 0;

%% Execute this block
clear Screen;

% times for reaction
t1 = 0;
t2 = 10;
tWait = 0.2;  %time to wait before turn
rand('twister',sum(100*clock));
tt1p = rand(1)*(t2-t1)+t1;
tt2p = rand(1)*(t2-t1)+t1;
tt3p = rand(1)*(t2-t1)+t1;
tt4p = rand(1)*(t2-t1)+t1;
tt5p = rand(1)*(t2-t1)+t1;
tt1 = tt1p;
tt2 = tt2p;
tt3 = tt3p;
tt4 = tt4p;
tt5 = tt5p;

% Find the screen to use for display:
screenid=max(Screen('Screens'));

% Disable Synctests for this simple demo:
%Screen('Preference','SkipSyncTests',1);

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper. We need to do this before the first call
% to any OpenGL function:
InitializeMatlabOpenGL(0,1);

% Open a double-buffered full-screen window: Everything is left at default
% settings, except stereomode:
if dotson~=3 & dotson~=4
    rect = [];
    %rect = [0 0 500 500];
else
    rect = [0 0 500 500];
end;

try

    if usefastoffscreenwindows
        [win , winRect] = Screen('OpenWindow', screenid, 0, rect, [], [], stereomode, [], kPsychNeedFastOffscreenWindows);
    else
        [win , winRect] = Screen('OpenWindow', screenid, 0, rect, [], [], stereomode);
    end
    res = winRect(3:4);
    
    disp( strcat('resolution=', num2str( res(1) ), '-by-', num2str( res(2) ) ) );

    %calculate ellipse points
    Cen = [res(1)/2,res(2)/2];
    a = 170;
    b = 200;
    f1 = [res(1)/2,res(2)/2+a/2];
    f2 = [res(1)/2,res(2)/2-a/2];
    steps = 10;
    Epnts = CalcEllipse( Cen, a, b, f1, f2, steps, 1);
    disp( strcat('ellipse a=', num2str(a), ' b=', num2str(b) ) );
    
    %calculate ellipse points
    Cen = [res(1)/2,res(2)/2];
    a = 170;
    b = 200;
    f1 = [res(1)/2,res(2)/2+a/2];
    f2 = [res(1)/2,res(2)/2-a/2];
    steps = 500;
    Epnts1 = CalcEllipse( Cen, a, b, f1, f2, steps, 1);
    disp( strcat('ellipse a=', num2str(a), ' b=', num2str(b) ) );
    
    Epnts2{1} = Epnts1;
    a = 140;
    b = 170;
    f1 = [res(1)/2,res(2)/2+a/2];
    f2 = [res(1)/2,res(2)/2-a/2];
    steps = 500;
    Epnts2{2} = CalcEllipse( Cen, a, b, f1, f2, steps, 1);    
    disp( strcat('ellipse a=', num2str(a), ' b=', num2str(b) ) );
    
    a = 110;
    b = 150;
    f1 = [res(1)/2,res(2)/2+a/2];
    f2 = [res(1)/2,res(2)/2-a/2];
    steps = 500;
    Epnts2{3} = CalcEllipse( Cen, a, b, f1, f2, steps, 1);    
    disp( strcat('ellipse a=', num2str(a), ' b=', num2str(b) ) );

    
    % Retrieve duration of a single monitor flip interval: Needed for smooth
    % animation.
    ifi = Screen('GetFlipInterval', win);
    
    if(PLAYBACK || CNTRLCOND)
        tmp = find(TimeLineR<=ifi+ifi/2);
        TimeLineR(tmp) = 0;
%        TimeLineR(1:end-1) = TimeLineR(1:end-1) - ifi;
    end

    %initialise & calibrate eyetracker
    if( EYETRACKER )
        Screen('TextSize', win, 50);
        Screen('DrawText', win, num2str(SUBJECT), res(1)/2, res(2)/2, [255 0 0] );
        Screen('Flip',win);
        [errorCode, SoundNov, LSoundNov,tmpSoundCNov,tmpEpnts,tmpFixatText,tmpCalibText,tmpAbstText] = TobiiInit(hostName, port, win, res, SUBJECT, StimPaths, AbstPath);
        if( errorCode )
            EYETRACKER = 0;
        end
        HideCursor();
        %show subject number
    else
        [tmpEpnts, tmpFixatText, tmpCalibText, SoundNov, LSoundNov, tmpSoundCNov, tmpAbstText ] = InitDrawEyes( win, res, FixatPath, STrackPath, SLTrackPath, CalibPath, SCTrackPath, 5, AbstPath );
    end


    % Reset moglmorpher:
    moglmorpher('reset');
    moglmorpher1('reset');
    moglmorpher2('reset');
    moglmorpher3('reset');
    moglmorpher4('reset');

    % Add the OBJS to moglmorpher for use as morph-shapes:
    for i=1:size(objs1,2)                
        meshid1(i) = moglmorpher1('addMesh', objs1{i});
    end
    count1 = moglmorpher1('getMeshCount');
    
    % Add the OBJS to moglmorpher for use as morph-shapes:
    for i=1:size(objs,2)
        meshid(i) = moglmorpher('addMesh', objs{i});
    end
    count = moglmorpher('getMeshCount');

    for i=1:size(objs2,2)
        meshid2(i) = moglmorpher2('addMesh', objs2{i});
    end
    count2 = moglmorpher2('getMeshCount');

    for i=1:size(objs3,2)
        
        meshid3(i) = moglmorpher3('addMesh', objs3{i});
    end
    count3 = moglmorpher3('getMeshCount');

    for i=1:size(objs4,2)
        meshid4(i) = moglmorpher4('addMesh', objs4{i});
    end
    count4 = moglmorpher4('getMeshCount');

    % Setup the OpenGL rendering context of the onscreen window for use by
    % OpenGL wrapper. After this command, all following OpenGL commands will
    % draw into the onscreen window 'win':
    Screen('BeginOpenGL', win);

    if perpixellighting==1
        % Load a GLSL shader for per-pixel lighting, built a GLSL program out of it...
        shaderpath = [PsychtoolboxRoot '/PsychDemos/OpenGL4MatlabDemos/GLSLDemoShaders/'];
        glsl=LoadGLSLProgramFromFiles([shaderpath 'Pointlightshader'],1);
        % ...and activate the shader program:
        glUseProgram(glsl);
    end;

    % Get the aspect ratio of the screen, we need to correct for non-square
    % pixels if we want undistorted displays of 3D objects:
    ar=winRect(4)/winRect(3);

    % Turn on OpenGL local lighting model: The lighting model supported by
    % OpenGL is a local Phong model with Gouraud shading.
    glEnable(GL.LIGHTING);

    % Enable the first local light source GL.LIGHT_0. Each OpenGL
    % implementation is guaranteed to support at least 8 light sources.
    glEnable(GL.LIGHT0);

    % Enable proper occlusion handling via depth tests:
    glEnable(GL.DEPTH_TEST);

    % Define the light reflection properties by setting up reflection
    % coefficients for ambient, diffuse and specular reflection:
    glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 0.5 0.5 0.5 1.0 ]);
    glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 0.7 0.7 0.7 1.0 ]);
    glMaterialfv(GL.FRONT_AND_BACK,GL.SPECULAR, [ 0.2 0.2 0.2 1.0 ]);
    glMaterialfv(GL.FRONT_AND_BACK,GL.SHININESS,12);

    % Make sure that surface normals are always normalized to unit-length,
    % regardless what happens to them during morphing. This is important for
    % correct lighting calculations:
    glEnable(GL.NORMALIZE);

    % Set projection matrix: This defines a perspective projection,
    % corresponding to the model of a pin-hole camera - which is a good
    % approximation of the human eye and of standard real world cameras --
    % well, the best aproximation one can do with 3 lines of code ;-)
    glMatrixMode(GL.PROJECTION);
    glLoadIdentity;

    % Field of view is +/- 25 degrees from line of sight. Objects close than
    % 0.1 distance units or farther away than 200 distance units get clipped
    % away, aspect ratio is adapted to the monitors aspect ratio:
    gluPerspective(25.0,1/ar,0.1,200.0);

    % Setup modelview matrix: This defines the position, orientation and
    % looking direction of the virtual camera:
    glMatrixMode(GL.MODELVIEW);
    glLoadIdentity;

    % Setup position of lightsource wrt. origin of world:
    % Pointlightsource at (20 , 20, 20)...
    glLightfv(GL.LIGHT0,GL.POSITION,[ 20 20 20 0 ]);

    % Setup emission properties of the light source:

    % Emits white (1,1,1,1) diffuse light:
    glLightfv(GL.LIGHT0,GL.DIFFUSE, [ 1 1 1 1.0 ]);

    % Emits white (1,1,1,1) specular light:
    glLightfv(GL.LIGHT0,GL.SPECULAR, [ 1.0 1.0 1.0 1 ]);

    % There's also some weak ambient light present:
    glLightfv(GL.LIGHT0,GL.AMBIENT, [ 0.1 0.1 0.1 1 ]);

    % Set size of points for drawing of reference dots
    glPointSize(3.0);
    glColor3f(0,0,1);

    % Set thickness of reference lines:
    glLineWidth(2.0);

    % Add z-offset to reference lines, so they do not get occluded by surface:
    glPolygonOffset(0, -5);
    glEnable(GL.POLYGON_OFFSET_LINE);

    % Initialize amount and direction of rotation for our slowly spinning,
    % morphing objects:
    %theta=-90;
    theta = 0.0;
    theta2 = 0.0;
    rotatev=[ 1 0 0 ];

    % Initialize morph vector:
    w=zeros(1,length(objs));
    w(1) = 1;

    w1 = zeros(1,length(objs1));
    w1(1) = 1;

    w2 = zeros(1,length(objs2));
    w2(1) = 1;

    w3 = zeros(1,length(objs3));
    w3(1) = 1;

    w4 = zeros(1,length(objs4));
    w4(1) = 1;
        
    % Setup initial z-distance of objects:
    zz = 10.0;

    ang = 0.0;      % Initial rotation angle

    % Half eye separation in length units for quick & dirty stereoscopic
    % rendering. Our way of stereo is not correct, but it makes for a
    % nice demo. Figuring out proper values is not too difficult, but
    % left as an exercise to the reader.
    eye_halfdist=2;

    % Finish OpenGL setup and check for OpenGL errors:
    Screen('EndOpenGL', win);

    % Compute initial morphed shape for next frame, based on initial weights:
    moglmorpher('computeMorph', w, morphnormals);
    moglmorpher1('computeMorph', w1, morphnormals1);
    moglmorpher2('computeMorph', w2, morphnormals2);
    moglmorpher3('computeMorph', w3, morphnormals3);
    moglmorpher4('computeMorph', w4, morphnormals4);

    if( EYETRACKER )
        weights = w;
        angle_theta = theta;
    end

    % Initially sync us to the VBL:
    vbl=Screen('Flip', win);

    % Some stats...
    tstart=vbl;
    waitframes = 0;

    mx0 = 10;
    my0 = 10;
    if(~EYETRACKER)
        SetMouse(mx0,my0,win);
    end
    tt0 = GetSecs;
    tt02 = tt0;
    tt03 = tt0;
    tt04 = tt0;
    tt05 = tt0;
    indR = -1;
    indR2 = -1;
    indR3 = -1;
    indR4 = -1;
    indR5 = -1;
    
    flagStart = 0;
    flagStart2 = 1;
    
    %random contingent response
    tc1 = 0.15;
    tc2 = 0.3;
    TimeInsist = 2.0; %if keeps looking for 2 sec move again
    
    BFlag0 = 0;
    RFlag = 0;
    countB = 0;
    countBM = 7;
    countBM2 = 4;
    countBM3 = 3;
    indTurn = 0;
    trials = 1;
    TcountNF0 = 0;
    
    flagScreenUpdated = 0;
    StillUpdate = 1; %update only this time

    AtLeastOnce =0;
    
    startCont=0;
        
    % Animation loop: Run until key press or one minute has elapsed...
    t = GetSecs;
    count = 0;

    countM = 1; %counts breaks to find eyes
    countC = 1; %counts breaks to re-calibrate
    UpdateColorStamp = t;
    countUp = 0;
    
    objOrd = randperm(4); %order of displaying objects
    numObj = 4; % num of objects displayed
    
    nextFrame = t;
    
    countCntrlTrials = 1;
    
    indSCN = 1; %sound index    
    while ( lenPlay-1 > count)

        count = count+1;
        
        waitframes = 0;

        % morphing depends on eyetracking data

        if( EYETRACKER )
            eyeTrack = talk2tobii('GET_SAMPLE');
            psychStamp = GetSecs;
            if ( eyeTrack(7)==0 && eyeTrack(8)==0 )
                mx = (eyeTrack(1)+eyeTrack(3))*res(1)/2;
                my = (eyeTrack(2)+eyeTrack(4))*res(2)/2;                
            elseif(eyeTrack(7)==0 && eyeTrack(8)>0)
                mx = eyeTrack(1)*res(1);
                my = eyeTrack(2)*res(2);                
            elseif(eyeTrack(7)>0 && eyeTrack(8)==0)
                mx = eyeTrack(3)*res(1);
                my = eyeTrack(4)*res(2);                
            else
                mx = -1;
                my = -1;
            end
            EyeEvent = {'EyeEvent',eyeTrack(5),eyeTrack(6),psychStamp};
            TimeStamp = eyeTrack(5)+eyeTrack(6)/1000000;
            if( mx==-1 && my==-1 )
                TcountNF = TimeStamp;
                if( TcountNF-TcountNF0 > 0.5 )
                    TcountNF0 = TimeStamp;
                    tmpstr = strcat('Eyes have not found: Total time elapsed:',num2str(psychStamp-t) );
                    disp(tmpstr);
                    BFlag0 = 0; % baby doesn't look now
                    RFlag = 0;
                    startCont = 0;
                end
            else
                TcountNF0 = TimeStamp;
            end
            
            if( psychStamp-UpdateColorStamp>0.1 ) %use this stamp for color update
                StillUpdate = 1;
            end
        elseif(PLAYBACK)
            if( count > lenPlayBack )
                break;
            end
            eyeTrack = EyeTrackingInfo(count,:);
            if ( eyeTrack(7)==0 && eyeTrack(8)==0 )
                mx = (eyeTrack(1)+eyeTrack(3))*res(1)/2;
                my = (eyeTrack(2)+eyeTrack(4))*res(2)/2;                
            elseif(eyeTrack(7)==0 && eyeTrack(8)>0)
                mx = eyeTrack(1)*res(1);
                my = eyeTrack(2)*res(2);                
            elseif(eyeTrack(7)>0 && eyeTrack(8)==0)
                mx = eyeTrack(3)*res(1);
                my = eyeTrack(4)*res(2);                
            else
                mx = -1;
                my = -1;
            end
                        
        else
            psychStamp = GetSecs;
            [mx,my,buttons] = GetMouse(win);
            eyeTrack = [mx my mx my round(psychStamp) abs(psychStamp-round(psychStamp))*1000000 0 0 -1 -1 -1 -1];
            EyeEvent = {'EyeEvent',eyeTrack(5),eyeTrack(6),psychStamp};
            TimeStamp = eyeTrack(5)+eyeTrack(6)/1000000;
            
        end

        
        if( PLAYBACK || CNTRLCOND )
            w(1) = w_1(count);
            w(2) = 1- w(1);
            w1(1) = w_2(count);
            w1(2) = 1-w1(1);
            w2(1) = w_3(count);
            w2(2) = 1-w2(1);
            w3(1) = w_4(count);
            w3(2) = 1-w3(1);
            w4(1) = w_5(count);
            w4(2) = 1-w4(1);

            theta = ThetaEvent(count);
            ang = AngEvent(count);
            
            numObj = numObjAll(count);
            objOrd = [Obj1(count)  Obj2(count) Obj3(count) Obj4(count)];
            
%             AtLeastOnce = 1;
%             indR2 = 0;
%             indR3 = 0;
%             indR4 = 0;
%             indR5 = 0;
            StillUpdate = 1;

            if( CNTRLCOND  )
                if( Break_flag(count) == 1 ) 
                    
                    waitframes = 5;
                    disp( strcat( 'Trial:', num2str(countCntrlTrials) ) );
                    countCntrlTrials = countCntrlTrials+1;
                end
                if( w_1M_flag(count) == 1 )
                    Screen('SetMovieTimeIndex', SoundNov{1}, 0 );
                    Screen('PlayMovie',SoundNov{1},1);
                end
                if( w_2M_flag(count) == 1 )
                    Screen('SetMovieTimeIndex', SoundNov{2}, 0 );
                    Screen('PlayMovie',SoundNov{2},1);
                end
                if( w_3M_flag(count) == 1 )
                    Screen('SetMovieTimeIndex', SoundNov{3}, 0 );
                    Screen('PlayMovie',SoundNov{3},1);
                end
                if( w_4M_flag(count) == 1 )
                    Screen('SetMovieTimeIndex', SoundNov{4}, 0 );
                    Screen('PlayMovie',SoundNov{4},1);
                end
                if( w_5M_flag(count) == 1 )
                    Screen('SetMovieTimeIndex', SoundNov{5}, 0 );
                    Screen('PlayMovie',SoundNov{5},1);
                end
                                
            end
            AtLeastOnce = Morph1(count);
            indR2 = Morph2(count);
            indR3 = Morph3(count);
            indR4 = Morph4(count);
            indR5 = Morph5(count);
            
        else


            if( mx~=-1 && my~=-1 )
                BFlag = contourInOut( [mx my], Epnts );
                if (BFlag && ~BFlag0 ) %It looks now but it wasn't looking before
                    BFlag0 = 1;
                    RFlag = 1;  %use this flag to start contingent response
                    TimeStamp0 = TimeStamp;
                    psychStamp0 = psychStamp;
                    startCont = 0;
                elseif(BFlag && BFlag0)
                    if( psychStamp-psychStamp0>TimeInsist )
                        RFlag = 1;
                        TimeStamp0 = TimeStamp;
                        psychStamp0 = psychStamp;
                    else
                        RFlag = 0;
                    end
                    
                else
                    BFlag0 = 0;
                    RFlag = 0;
                    startCont = 0;
                end

%                 TcountNF0 = TimeStamp;
%             elseif(mx==-1 && my==-1)
%                 TcountNF = TimeStamp;
%                 if( TcountNF-TcountNF0 > 0.5 )
%                     TcountNF0 = TimeStamp;
%                     tmpstr = strcat('Eyes have not found: Total time elapsed:',num2str(psychStamp-t) );
%                     disp(tmpstr);
%                     BFlag0 = 0; % baby doesn't look now
%                     RFlag = 0;
%                     startCont = 0;
%                 end
% 
                
            end

            if(~flagStart)  %if object has started turning rest scene shouldn't move

                tt = GetSecs;

                if( (RFlag && indR<0) || indR>=0 ) %respond contingently
                    if(indR<0)
                        indR = 20;
                        ttc = rand(1)*(tc2-tc1)+tc1;
                        tt0 = tt;
                        flagStart2 = 0;
                        AtLeastOnce = 0;
                        startCont = 1;
                        RFlag = 0;
                    end

                    if( tt-tt0>=ttc ) %respond after ttc time
                        if( startCont || AtLeastOnce )  % respond if the baby still looks
                            w(2) = sin( (indR * pi * 2) / 20 );
                            w(1) = 1-w(2);
                            indR = indR-1;
                            if(startCont)
                                startCont = 0;
                                AtLeastOnce = 1;         % use this so if you start don't stop
                                countB = countB+1;
                                disp( strcat( 'countB=',num2str(countB) ) );

                                Screen('SetMovieTimeIndex', SoundNov{1}, 0 );
                                Screen('PlayMovie',SoundNov{1},1);
                            end

                        else %if the baby doesn't look then reduce this by one.
                            %countB = countB-1;
                            %disp( strcat( 'R countB=',num2str(countB) ) );
                            indR = -1;
                        end

                    end

                    if( indR < 0 )
                        flagStart2 = 1;
                        startCont = 0;
                        AtLeastOnce = 0;
                        
                        if( countB>=countBM2 )
                            numObj = 2;
                            t2 = 5; %objects react more because they are fewer
                        end
                    end
                end

                if( numObj==4 || objOrd(3)==1 || objOrd(4)==1 )
                    tmpT = tt-tt02-tt2;
                    if( ( tmpT>0 && indR2<0 ) || indR2>=0 )
                        if(indR2<0)
                            indR2 = 20;
                            tt2 = t2-tt2p;
                            tt2p = rand(1)*(t2-t1)+t1;
                            tt2 = tt2+tt2p;
                            tt02 = tt;
                            Screen('SetMovieTimeIndex', SoundNov{2}, 0 );
                            Screen('PlayMovie',SoundNov{2},1);
                        end
                        w1(1) = sin( (indR2 * pi * 2) / 20 );
                        w1(2) = 1-w1(1);
                        indR2 = indR2-1;
                    end
                end
                
                if( numObj==4 || objOrd(3)==2 || objOrd(4)==2 )
                    tmpT = tt-tt03-tt3;
                    if( (tmpT > 0 && indR3<0) || indR3>=0 )
                        if(indR3<0)
                            indR3 = 20;
                            tt3 = t2-tt3p;
                            tt3p = rand(1)*(t2-t1)+t1;
                            tt3 = tt3+tt3p;
                            tt03 = tt;
                            Screen('SetMovieTimeIndex', SoundNov{3}, 0 );
                            Screen('PlayMovie',SoundNov{3},1);
                        end
                        w2(1) = sin( (indR3 * pi * 2) / 20 );
                        w2(2) = 1-w2(1);
                        indR3 = indR3-1;
                    end
                end

                if( numObj==4 || objOrd(3)==3 || objOrd(4)==3 )
                    tmpT = tt-tt04-tt4;
                    if( (tmpT > 0 && indR4<0) || indR4>=0 )
                        if(indR4<0)
                            indR4 = 20;
                            tt4 = t2-tt4p;
                            tt4p = rand(1)*(t2-t1)+t1;
                            tt4 = tt4+tt4p;
                            tt04 = tt;
                            Screen('SetMovieTimeIndex', SoundNov{4}, 0 );
                            Screen('PlayMovie',SoundNov{4},1);
                        end
                        w3(1) = sin( (indR4 * pi * 2) / 20 );
                        w3(2) = 1-w3(1);
                        indR4 = indR4-1;
                    end
                end

                if( numObj==4 || objOrd(3)==4 || objOrd(4)==4 )
                    tmpT = tt-tt05-tt5;
                    if( (tmpT > 0 && indR5<0) || indR5>=0 )
                        if(indR5<0)
                            indR5 = 20;
                            tt5 = t2-tt5p;
                            tt5p = rand(1)*(t2-t1)+t1;
                            tt5 = tt5+tt5p;
                            tt05 = tt;
                            Screen('SetMovieTimeIndex', SoundNov{5}, 0 );
                            Screen('PlayMovie',SoundNov{5},1);
                        end
                        w4(1) = sin( (indR5 * pi * 2) / 20 );
                        w4(2) = 1-w4(1);
                        indR5 = indR5-1;
                    end
                end
                

            end


            %stop everything and just move the central 3D shape
            if( countB>=countBM && (flagStart2 || flagStart) )
                flagStart2 = 0; % object has started turning
                if(~flagStart)
                    disp( strcat('            I am turning now! Trial=',num2str(trials) ) );


                    trials = trials+1;

                    flagStart = 1;
                    theta = 0;
                    ang = 0;
                    if( mod(indTurn, 2) == 0 )
                        indTurn = 0;
                        Pturn = randperm(2);
                    end
                    typeT = Pturn(indTurn+1);
                    indTurn = indTurn+1;
                    RFlag = 1;
                    waitframes = psychStamp-vbl+ifi;
                    %WaitSecs(tWait);

                end

                switch typeT
                    case 1 % turn left-bottom
                        if(ang>-50 && theta<30)
                            ang = ang-0.8;
                            theta = theta + 0.5;
                        else
                            flagStart = 0;
                            flagStart2 = 1;
                            waitframes = 5;
                            StillUpdate = 1;
                            %                            waitframes = waitframes+5;
                            %                            WaitSecs(5);
                            theta = 0;
                            ang = 0;
                            countBM = countBM3;
                            countB = 0;
                            
                            BFlag0 = 0;

                            %reset objects movements
                            tt02 = vbl+waitframes+ifi;
                            tt03 = tt02;
                            tt04 = tt02;
                            tt05 = tt02;
                            tt2 = tt2p;
                            tt3 = tt3p;
                            tt4 = tt4p;
                            tt5 = tt5p;
                            indR2 = -1;
                            indR3 = -1;
                            indR4 = -1;
                            indR5 = -1;
                            
                            %decide order of objects
                            objOrd = randperm(4);
                            
                        end

                    case 2 % turn right-bottom
                        if(ang<50 && theta<30)
                            ang = ang+0.8;
                            theta = theta + 0.5;
                        else
                            flagStart = 0;
                            flagStart2 = 1;
                            %WaitSecs(5);
                            theta = 0;
                            ang = 0;
                            countBM = countBM3;
                            countB = 0;
                            BFlag0 = 0;

                            waitframes = 5;
                            StillUpdate = 1;
                            %reset objects movements
                            tt02 = vbl+waitframes+ifi;
                            tt03 = tt02;
                            tt04 = tt02;
                            tt05 = tt02;
                            tt2 = tt2p;
                            tt3 = tt3p;
                            tt4 = tt4p;
                            tt5 = tt5p;
                            indR2 = -1;
                            indR3 = -1;
                            indR4 = -1;
                            indR5 = -1;

                            %decide order of objects
                            objOrd = randperm(4);

                        end

                    otherwise
                        error('Other type of turn is not applicable');
                end

            end
        end

        % Compute morphed shape for next frame, based on new weight vector:
        if( AtLeastOnce )
            moglmorpher('computeMorph', w, morphnormals);
        end
        if( indR2>=0 )
            moglmorpher1('computeMorph', w1, morphnormals1);
        end
        if( indR3>=0 )
            moglmorpher2('computeMorph', w2, morphnormals2);
        end
        if( indR4>=0 )
            moglmorpher3('computeMorph', w3, morphnormals3);
        end
        if( indR5>=0 )
            moglmorpher4('computeMorph', w4, morphnormals4);
        end

        
        %do drawing if appropriate (w's have changed or object is turning or you want to plot points)
        if( AtLeastOnce || indR2>=0 || indR3>=0 || indR4>=0 || indR5>=0 || flagStart || StillUpdate || PLOT_ELLIPSE_PNTS)
            countUp = countUp+1;
            
            if(EYETRACKER)
                UpdateColorStamp = psychStamp;
                StillUpdate = 0;
            end
            
            % Switch to OpenGL rendering for drawing of next frame:
            Screen('BeginOpenGL', win);

            % Left-eye cam is located at 3D position (-eye_halfdist,0,zz), points upright (0,1,0) and fixates
            % at the origin (0,0,0) of the worlds coordinate system:
            glLoadIdentity;
            %x = x+1;
            gluLookAt(5, 0, 0, 0, 0, 0, 0, 1, 0);

            % Clear out the depth-buffer for proper occlusion handling:
            glClear(GL.DEPTH_BUFFER_BIT);

            % Call our subfunction that does the actual drawing of the shape (see below):
            colInd = mod(countUp,ColLen+1);
            if( colInd==0 )
                colInd = 1;
            end

            vpos = drawShape( objOrd, numObj, ColArray(colInd,:), ang, theta, theta2, rotatev, dotson, normalson, IndStore );

            % Now that all drawing commands are submitted, we can do the other stuff before
            % the Flip:

            % Finish OpenGL rendering into Psychtoolbox - window and check for OpenGL errors.
            Screen('EndOpenGL', win);
            % Tell Psychtoolbox that drawing of this stim is finished, so it can optimize
            % drawing:
            Screen('DrawingFinished', win);
            

            if( PLOT_ELLIPSE_PNTS )
                glDisable(GL.LIGHTING);
                Screen('glPoint', win, [100 255 255], mx, my, 20);

                for jj=1:length(Epnts)
                    Screen('glPoint', win, [0 255 0], Epnts(jj,1), Epnts(jj,2), 2);
                end

                if ( eyeTrack(7)==0 && eyeTrack(8)==0 )
                    Screen('glPoint', win, [0 255 0], res(1)-30, 30, 25);
                elseif( (eyeTrack(7)==0 && eyeTrack(8)>0 ) || (eyeTrack(7)>0 && eyeTrack(8)==0) )
                    Screen('glPoint', win, [127 127 0], res(1)-30, 30, 25);
                else
                    Screen('glPoint', win, [255 0 0], res(1)-30, 30, 25);
                end
                %             Screen('TextSize',win, 30 );
                %             Screen('DrawText', win, num2str(count),30 , 30,[1 0 0] );

                glEnable(GL.LIGHTING);
            end



            flagScreenUpdated = 1;
        else
            flagScreenUpdated = 0;
        end
        
        % We're done for this frame:

        % Show rendered image 'waitframes' refreshes after the last time
        % the display was updated and in sync with vertical retrace:
                
        if(PLAYBACK)
            
            if( CAPTURESCREEN )
                Screen('TextSize',win, 30 );
                Screen('DrawText', win, num2str(count),30 , 30,[255 0 0] );

                now = Screen('Flip', win);

                %capture screen - save picture to hard-drive
                imgArray = Screen('GetImage', win);
                imgFileName = fullfile(outPicDir, strcat(outPicName, num2str(count),'.jpeg') );
                imwrite(imgArray,imgFileName, 'jpeg');
            else

                if( count == 1 )
                    TimeLine = TimeLine + GetSecs + ifi;
                end

                tmpIndex = [SynchIndex(count) SynchIndex(count+1)];
                ProMx = [];
                ProMy = [];
                tmpMx = [];
                tmpMy = [];

                glDisable(GL.LIGHTING);
                kk1 = tmpIndex(1);
                kk2 = tmpIndex(2);
                tmpStamp11 = EyeTrackingData(kk1,1)+EyeTrackingData(kk1,2)/1000000;
                tmpStamp22 = EyeTrackingData(kk2,1)+EyeTrackingData(kk2,2)/1000000;
                tmpTot = tmpStamp22 - tmpStamp11;
                tmpC = 255/tmpTot;
                tmptt0 = 0;
                for j=tmpIndex(1):tmpIndex(2)
                    tmpEyeSample = EyeTrackingData(j,:);
                    tmpStamp = EyeTrackingData(j,1)+EyeTrackingData(j,2)/1000000;
                    tmptt1 = (tmpStamp-tmpStamp11)*tmpC;

                    if ( tmpEyeSample(11)==0 && tmpEyeSample(12)==0 )
                        ProMx = tmpMx;
                        ProMy = tmpMy;
                        tmpMx = (tmpEyeSample(3)+tmpEyeSample(5))*res(1)/2;
                        tmpMy = (tmpEyeSample(4)+tmpEyeSample(6))*res(2)/2;
                    elseif(tmpEyeSample(11)==0 && tmpEyeSample(12)>0)
                        ProMx = tmpMx;
                        ProMy = tmpMy;
                        tmpMx = tmpEyeSample(3)*res(1);
                        tmpMy = tmpEyeSample(4)*res(2);
                    elseif(tmpEyeSample(11)>0 && tmpEyeSample(12)==0)
                        ProMx = tmpMx;
                        ProMy = tmpMy;
                        tmpMx = tmpEyeSample(5)*res(1);
                        tmpMy = tmpEyeSample(6)*res(2);
                    else
                        ProMx = [];
                        ProMy = [];
                        tmpMx = [];
                        tmpMy = [];
                    end


                    if( ~isempty(ProMx) && ~isempty(tmpMx) )
                        %disp('drawL');
                        Screen('DrawLines', win, [ProMx tmpMx; ProMy tmpMy], 2, [255-tmptt0 tmptt0 0;255-tmptt1 tmptt1 0]' );
                        %Screen('glPoint', win, [ProMx ProMy], 5, [0 255 0] );
                        %Screen('glPoint', win, [tmpMx tmpMx], 5, [255 0 0] );
                    elseif( ~isempty(tmpMx) )
                        %disp('drawP');
                        Screen('glPoint', win, [255-tmptt1 tmptt1 0], tmpMx, tmpMy, 5  );
                    end
                    
                    tmptt0 = tmptt1;

                end
                
                %if there are breaks display a second red-dot on the right
                %upper corner of the screen
                if( BreaksOut(count) )
                    Screen('glPoint', win, [255 0 0], res(1)-60, 30, 25); 
                end
                if( CalBreaks(count) )
                    Screen('glPoint', win, [255 0 0], res(1)-30, 60, 25); 
                end

                glEnable(GL.LIGHTING);

            end

            vbl = Screen( 'Flip', win, nextFrame );
            nextFrame = vbl + TimeLineR(count);

        elseif(CNTRLCOND)
            vbl = Screen( 'Flip', win, nextFrame );
            nextFrame = vbl + TimeLineR(count);
            
        else
            if( flagScreenUpdated )
                vbl = Screen('Flip', win, vbl + waitframes + ifi);
            end
        end

        %store event
        if(EYETRACKER || CNTRLCOND )
            if( flagScreenUpdated )
                FlipEvent = {'FlipEvent',vbl};
                WeightEvent = {'Weights',[w(1) w1(1) w2(1) w3(1) w4(1)]};
                ThetaEvent1 = {'Theta',theta };
                AngEvent1 = {'angle', ang};
                numObjEvent = {'numObj',numObj};
                ObjOrdEvent = {'objOrd',objOrd};
                EventList{count} = {EyeEvent, WeightEvent, ThetaEvent1, AngEvent1, FlipEvent,numObjEvent,ObjOrdEvent};
            else
                EventList{count} = {EyeEvent};
            end
        end
        
        if( waitframes==5 && ~PLAYBACK )
            if(CNTRLCOND)
                WaitSecs( TimeLineR(count) - ifi );
                TimeLineR(count+1) = 0;
            end
            BreakEvent{countM} = FindBabyEyes_v2(win, res, tmpSoundCNov{indSCN}, Epnts2, tmpAbstText);
            countM = countM+1;
            indSCN = indSCN+1;
            if(indSCN>length(tmpSoundCNov) )
                indSCN = 1;
            end
            %estimate new time for next frame
            nextFrame = 0;
            
            %reset objects movements
            flagStart = 0;
            flagStart2 = 1;
            StillUpdate = 1;
            theta = 0;
            ang = 0;
            %countB = 0;
            tt02 = vbl+waitframes+ifi;
            tt03 = tt02;
            tt04 = tt02;
            tt05 = tt02;
            tt2 = tt2p;
            tt3 = tt3p;
            tt4 = tt4p;
            tt5 = tt5p;
            indR2 = -1;
            indR3 = -1;
            indR4 = -1;
            indR5 = -1;
        end
               
        % Check for keyboard press:
        [KeyIsDown, endrt, KeyCode] = KbCheck;
        if KeyIsDown

            if ( KeyCode(quitkey)==1 )
                break;
            end

            if(~PLAYBACK)

                if ( KeyCode(sound1)==1 )

                    if( exist('SoundNov','var') && ~isempty(SoundNov) )
                        Screen('SetMovieTimeIndex', SoundNov{1}, 0 );
                        disp( strcat( 's1Time=', num2str(GetSecs) ) );
                        Screen('PlayMovie',SoundNov{1},1);
                        disp('Sound1');
                    else
                        disp('Sound1 could not play');
                    end
                    KeyIsDown=0;
                end

                if ( KeyCode(sound2)==1 )
                    if( exist('SoundNov','var') && ~isempty(SoundNov) )
                        Screen('SetMovieTimeIndex', SoundNov{2}, 0 );
                        disp( strcat( 's2Time=', num2str(GetSecs) ) );
                        Screen('PlayMovie',SoundNov{2},1);
                        disp('Sound2');
                    else
                        disp('Sound2 could not play');
                    end
                    KeyIsDown=0;
                end

                if ( KeyCode(sound3)==1 )
                    if( exist('SoundNov','var') && ~isempty(SoundNov) )
                        Screen('SetMovieTimeIndex', SoundNov{3}, 0 );
                        Screen('PlayMovie',SoundNov{3},1);
                        disp( strcat( 's3Time=', num2str(GetSecs) ) );
                        disp('Sound3');
                    else
                        disp('Sound3 could not play');
                    end
                    KeyIsDown=0;
                end

                if ( KeyCode(sound4)==1 )
                    if( exist('SoundNov','var') && ~isempty(SoundNov) )
                        Screen('SetMovieTimeIndex', SoundNov{4}, 0 );
                        disp( strcat( 's4Time=', num2str(GetSecs) ) );
                        Screen('PlayMovie',SoundNov{4},1);
                        disp('Sound4');
                    else
                        disp('Sound4 could not play');
                    end
                    KeyIsDown=0;
                end

                if( KeyCode(sound5)==1 )
                    KeyIsDown=0;
                    if( exist('SoundNov','var') && ~isempty(SoundNov) )
                        Screen('SetMovieTimeIndex', SoundNov{5}, 0 );
                        disp( strcat( 's5Time=', num2str(GetSecs) ) );
                        Screen('PlayMovie',SoundNov{5},1);
                        disp('Sound5');
                    else
                        disp('Sound5 could not play');
                    end
                end

                if( KeyCode(MouseKey)==1 )
                    %find eyes again
                    BreakEvent{countM} = FindBabyEyes(win, res, LSoundNov, tmpEpnts, tmpFixatText);
                    countM = countM+1;
                    %reset objects movements
                    flagStart = 0;
                    flagStart2 = 1;
                    StillUpdate = 1;
                    theta = 0;
                    ang = 0;
                    %countB = 0;
                    tt02 = vbl+waitframes+ifi;
                    tt03 = tt02;
                    tt04 = tt02;
                    tt05 = tt02;
                    tt2 = tt2p;
                    tt3 = tt3p;
                    tt4 = tt4p;
                    tt5 = tt5p;
                    indR2 = -1;
                    indR3 = -1;
                    indR4 = -1;
                    indR5 = -1;
                end

                if( KeyCode(CalibBut)==1 )
                    %recalibrate
                    CalibEvent{countC} = CalibrateBaby(win, res, SUBJECT, tmpEpnts, tmpFixatText, tmpCalibText, LSoundNov, tmpSoundCNov );
                    countC = countC+1;
                    %reset objects movements
                    flagStart = 0;
                    flagStart2 = 1;
                    StillUpdate = 1;
                    theta = 0;
                    ang = 0;
                    %countB = 0;
                    tt02 = vbl+waitframes+ifi;
                    tt03 = tt02;
                    tt04 = tt02;
                    tt05 = tt02;
                    tt2 = tt2p;
                    tt3 = tt3p;
                    tt4 = tt4p;
                    tt5 = tt5p;
                    indR2 = -1;
                    indR3 = -1;
                    indR4 = -1;
                    indR5 = -1;
                end

            end

        end


    end %end of WHILE

    vbl = Screen('Flip', win);

    % Calculate and display average framerate:
    fps = count / (vbl - tstart)

    %eyetracker - finish experiment
    if(EYETRACKER)

        %finalise experiment
        talk2tobii('STOP_RECORD');


        %store  events
        countFlip = 1;
        for i=1:length(EventList)
            if( length( EventList{i} ) > 1 )

                EyeEvent = EventList{i}{1};
                WeightEvent = EventList{i}{2};
                ThetaEvent1 = EventList{i}{3};
                AngEvent1 = EventList{i}{4};
                FlipEvent = EventList{i}{5};
                numObjEvent = EventList{i}{6};
                objOrdEvent = EventList{i}{7};
                objOrdtmp = objOrdEvent{2};

                weights = WeightEvent{2};
                wId = '';
                for j=1:length(weights)
                    wId = strcat( wId,',''w_', num2str(j),''',', num2str(weights(j)) );
                end

                command = strcat('talk2tobii(''EVENT'',''FLIP'',FlipEvent{2},EyeEvent{4},''EyeEventSec'',EyeEvent{2}, ''EyeEventMsec'',EyeEvent{3},''ThetaEvent'',ThetaEvent1{2} ,''AngEvent'',AngEvent1{2}', wId,',''numObj'',numObjEvent{2},''Obj1'',objOrdtmp(1),''Obj2'',objOrdtmp(2),''Obj3'',objOrdtmp(3),''Obj4'',objOrdtmp(4)',')');
                eval(command);
                TimeLineFlip(countFlip) = FlipEvent{2};
                countFlip = countFlip+1;
            else
                EyeEvent = EventList{i}{1};
                %tmp = EyeEvent{2} + EyeEvent{3}/1000000;
                talk2tobii('EVENT','NOFLIP', EyeEvent{4}, 0, 'EyeEventSec', EyeEvent{2}, 'EyeEventMsec',EyeEvent{3} );
            end
        end
        
        if( exist('BreakEvent','var') )
            for i=1:length(BreakEvent)
                Breaktmp = BreakEvent{i};
                for j=1:length(Breaktmp)
                    BRtmp = Breaktmp{j};
                    talk2tobii('EVENT','BREAK', BRtmp{4}, 0, 'EyeEventSec', BRtmp{2}, 'EyeEventMsec',BRtmp{3} );
                end
            end
        end
                
        if( exist('CalibEvent','var') )
            for i=1:length(CalibEvent)
                CalibEventtmp = CalibEvent{i};
                for j=1:length(CalibEventtmp)
                    CLtmp = CalibEventtmp{j};
                    talk2tobii('EVENT',CLtmp{1}, CLtmp{4}, 0, 'EyeEventSec', CLtmp{2}, 'EyeEventMsec',CLtmp{3} );
                end
            end
        end
        
        talk2tobii('SAVE_DATA',inputPathEyeTracking,inputPathEvents,'TRUNK');

        talk2tobii('STOP_TRACKING');
        talk2tobii('DISCONNECT');
        [status,history] = talk2tobii('GET_STATUS');

        flagDataStored = 1;
        
    end
    
    if( ~EYETRACKER && CNTRLCOND )
        countFlip = 1;
        for i=1:length(EventList)
            if( length( EventList{i} ) > 1 )

                FlipEvent = EventList{i}{5};
                TimeLineFlip(countFlip) = FlipEvent{2};
                countFlip = countFlip+1;
            end

        end
        
        TimeLineFlipD = diff(TimeLineFlip);
        plot(TimeLineR);
        hold on;
        plot(TimeLineR,'.');
        plot(TimeLineFlipD,'.r');
    end

    % Reset moglmorpher:
    moglmorpher('reset');
    moglmorpher1('reset');
    moglmorpher2('reset');
    moglmorpher3('reset');
    moglmorpher4('reset');

    % Close onscreen window and release all other ressources:
    %Screen('Flip', win);
    Screen('CloseAll');

    % Reenable Synctests after this simple demo:
    Screen('Preference','SkipSyncTests',1);


    % Well done!
    WaitSecs(2);
    clear mex;
    
    diary off;

catch

    % Reset moglmorpher:
    moglmorpher('reset');
    moglmorpher1('reset');
    moglmorpher2('reset');
    moglmorpher3('reset');
    moglmorpher4('reset');

    % Close onscreen window and release all other ressources:
    %Screen('Flip', win);
    Screen('CloseAll');
    clear Screen;

    % Reenable Synctests after this simple demo:
    Screen('Preference','SkipSyncTests',1);

    %eyetracker - finish experiment
    if(EYETRACKER)

        %finalise experiment
        talk2tobii('STOP_RECORD');


        %store  events
        countFlip = 1;
        for i=1:length(EventList)
            if( length( EventList{i} ) > 1 )

                EyeEvent = EventList{i}{1};
                WeightEvent = EventList{i}{2};
                ThetaEvent1 = EventList{i}{3};
                AngEvent1 = EventList{i}{4};
                FlipEvent = EventList{i}{5};
                numObjEvent = EventList{i}{6};
                objOrdEvent = EventList{i}{7};
                objOrdtmp = objOrdEvent{2};

                weights = WeightEvent{2};
                wId = '';
                for j=1:length(weights)
                    wId = strcat( wId,',''w_', num2str(j),''',', num2str(weights(j)) );
                end

                command = strcat('talk2tobii(''EVENT'',''FLIP'',FlipEvent{2},EyeEvent{4},''EyeEventSec'',EyeEvent{2}, ''EyeEventMsec'',EyeEvent{3},''ThetaEvent'',ThetaEvent1{2} ,''AngEvent'',AngEvent1{2}', wId,',''numObj'',numObjEvent{2},''Obj1'',objOrdtmp(1),''Obj2'',objOrdtmp(2),''Obj3'',objOrdtmp(3),''Obj4'',objOrdtmp(4)',')');
                eval(command);
                TimeLineFlip(countFlip) = FlipEvent{2};
                countFlip = countFlip+1;
            else
                EyeEvent = EventList{i}{1};
                %tmp = EyeEvent{2} + EyeEvent{3}/1000000;
                talk2tobii('EVENT','NOFLIP', EyeEvent{4}, 0, 'EyeEventSec', EyeEvent{2}, 'EyeEventMsec',EyeEvent{3} );
            end
        end
        
        if( exist('BreakEvent','var') )
            for i=1:length(BreakEvent)
                Breaktmp = BreakEvent{i};
                for j=1:length(Breaktmp)
                    BRtmp = Breaktmp{j};
                    talk2tobii('EVENT','BREAK', BRtmp{4}, 0, 'EyeEventSec', BRtmp{2}, 'EyeEventMsec',BRtmp{3} );
                end
            end
        end
                
        if( exist('CalibEvent','var') )
            for i=1:length(CalibEvent)
                CalibEventtmp = CalibEvent{i};
                for j=1:length(CalibEventtmp)
                    CLtmp = CalibEventtmp{j};
                    talk2tobii('EVENT',CLtmp{1}, CLtmp{4}, 0, 'EyeEventSec', CLtmp{2}, 'EyeEventMsec',CLtmp{3} );
                end
            end
        end
        
        talk2tobii('SAVE_DATA',inputPathEyeTracking,inputPathEvents,'TRUNK');

        talk2tobii('STOP_TRACKING');
        talk2tobii('DISCONNECT');
        [status,history] = talk2tobii('GET_STATUS');

        flagDataStored = 1;
        
    end

    diary off;
    
    psychrethrow(psychlasterror);

end


