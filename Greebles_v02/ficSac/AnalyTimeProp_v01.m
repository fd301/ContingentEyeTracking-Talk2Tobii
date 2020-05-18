%analysis estimate of time proportion that baby looks at the centre

close all;
clear all;

SUBJECT=input('Test Subject number: ');

inputPathEvents = strcat('./events_rot_',num2str(SUBJECT),'.txt');
inputPathEyeTracking = strcat('./Tracking_rot_', num2str(SUBJECT), '.txt');

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

% find out when something is moving and which
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



