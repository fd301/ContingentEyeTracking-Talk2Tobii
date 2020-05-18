%analysis estimate of time proportion that baby looks at the centre

close all;
clear all;

SUBJECT=input('Test Subject number: ');

SUBJECT_PRO=input('Pro Subject number: ');

%inputPathEvents = strcat('./events_rot_',num2str(SUBJECT),'.txt');
inputPathEyeTracking = strcat('./Tracking_rot_', num2str(SUBJECT), '.txt');
inputPathEyeTracking_pro = strcat('./Tracking_rot_', num2str(SUBJECT_PRO), '.txt');

inputPathEvents = strcat('./events_rot_',num2str(SUBJECT),'.txt');

res = [1024 768];
Cres = res/2;


FieldNames = {'EyeEventSec','EyeEventMsec','ThetaEvent', 'AngEvent',...
    'w_1','w_2','w_3','w_4','w_5', ...
    'numObj', 'Obj1', 'Obj2', 'Obj3', 'Obj4' };
EventNames = {'FLIP','NOFLIP','BREAK','CALIB_START','CALIB_END'};

[TimeLine, EyeTrackingInfo, varargout] = InitEyeEventsForAnalysis(inputPathEvents, inputPathEyeTracking, FieldNames, EventNames, SUBJECT);


eyeTrackData = load(inputPathEyeTracking);
disp('DataLoaded ... Test Subject');

eyeTrackDataP = load(inputPathEyeTracking_pro);
disp('DataLoaded ... Pro Subject');


%process data of Test Subject
len = length(eyeTrackData);

TimeLine = eyeTrackData(:,1) + eyeTrackData(:,2)/1000000;

indL = find( eyeTrackData(:,11) == 0 );
indR = find( eyeTrackData(:,12) == 0 );

t1 = zeros(len,1);
t2 = zeros(len,1);
t1(indL) = 1;
t2(indR) = 1;

t3 = t1 & t2;
t4 = t1 & (~t2);
t5 = (~t1) & t2;
t6 = t1 | t2;

indFBEyes = find(t3);
indFLEyes = find(t4);
indFREyes = find(t5);
indFAEyes = find(t6);

EyeTrSrc = zeros(len,2);
EyeTrSrc(indFBEyes,1) = ( eyeTrackData(indFBEyes,3) + eyeTrackData(indFBEyes,5) )*res(1)/2;
EyeTrSrc(indFBEyes,2) = ( eyeTrackData(indFBEyes,4) + eyeTrackData(indFBEyes,6) )*res(2)/2;
EyeTrSrc(indFLEyes,1) = eyeTrackData(indFLEyes,3)*res(1);
EyeTrSrc(indFLEyes,2) = eyeTrackData(indFLEyes,4)*res(2);
EyeTrSrc(indFREyes,1) = eyeTrackData(indFREyes,5)*res(1);
EyeTrSrc(indFREyes,2) = eyeTrackData(indFREyes,6)*res(2);

DistCEyeTrSrc = sqrt(  ( EyeTrSrc(:,1) - Cres(1) ).^2 + ( EyeTrSrc(:,2) - Cres(2) ).^2  );
plot( TimeLine(indFAEyes)-TimeLine(1), DistCEyeTrSrc(indFAEyes) );
hold on;

clear EyeTrSrc indFBEyes indFLEyes indFAEyes t1 t2 t3 t4 t5 t6 indL indR; 
%process data of Pro Subject
eyeTrackData = eyeTrackDataP;

len = length(eyeTrackData);

TimeLine = eyeTrackData(:,1) + eyeTrackData(:,2)/1000000;

indL = find( eyeTrackData(:,11) == 0 );
indR = find( eyeTrackData(:,12) == 0 );

t1 = zeros(len,1);
t2 = zeros(len,1);
t1(indL) = 1;
t2(indR) = 1;

t3 = t1 & t2;
t4 = t1 & (~t2);
t5 = (~t1) & t2;
t6 = t1 | t2;

indFBEyes = find(t3);
indFLEyes = find(t4);
indFREyes = find(t5);
indFAEyes = find(t6);

EyeTrSrc = zeros(len,2);
EyeTrSrc(indFBEyes,1) = ( eyeTrackData(indFBEyes,3) + eyeTrackData(indFBEyes,5) )*res(1)/2;
EyeTrSrc(indFBEyes,2) = ( eyeTrackData(indFBEyes,4) + eyeTrackData(indFBEyes,6) )*res(2)/2;
EyeTrSrc(indFLEyes,1) = eyeTrackData(indFLEyes,3)*res(1);
EyeTrSrc(indFLEyes,2) = eyeTrackData(indFLEyes,4)*res(2);
EyeTrSrc(indFREyes,1) = eyeTrackData(indFREyes,5)*res(1);
EyeTrSrc(indFREyes,2) = eyeTrackData(indFREyes,6)*res(2);

DistCEyeTrSrc = sqrt(  ( EyeTrSrc(:,1) - Cres(1) ).^2 + ( EyeTrSrc(:,2) - Cres(2) ).^2  );
plot( TimeLine(indFAEyes)-TimeLine(1), DistCEyeTrSrc(indFAEyes), 'r' );

