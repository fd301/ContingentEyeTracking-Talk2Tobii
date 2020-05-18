 %analysis estimate of time proportion that baby looks at the centre

close all;
clear all;

SUBJECT = input('Test Subject number: ');

SUBJECT_PRO = input('Pro Subject number: ');

inputPathEyeTracking = strcat('./Tracking_rot_', num2str(SUBJECT), '.txt');
inputPathEvents = strcat('./events_rot_',num2str(SUBJECT),'.txt');

inputPathEyeTracking_pro = strcat('./Tracking_rot_', num2str(SUBJECT_PRO), '.txt');
inputPathEvents_pro = strcat('./events_rot_',num2str(SUBJECT_PRO),'.txt');

res = [1024 768];
Cres = res/2;


FieldNames = {'EyeEventSec','EyeEventMsec','ThetaEvent', 'AngEvent',...
    'w_1','w_2','w_3','w_4','w_5', ...
    'numObj', 'Obj1', 'Obj2', 'Obj3', 'Obj4' };
EventNames = {'FLIP','NOFLIP','BREAK','CALIB_START','CALIB_END'};

FlagDelay = 1;
[TimeLineE, ...
    EyeEventSec, EyeEventMsec, ThetaEvent, AngEvent, ...
    w_1, w_2, w_3, w_4, w_5, ...
    numObj, Obj1, Obj2, Obj3, Obj4, ...
    EyeTrackingData, newPos, IndF, BreaksOut] = ...
    InitEyeEventsForAnalysis_v02(inputPathEvents, inputPathEyeTracking, FieldNames, EventNames, SUBJECT, FlagDelay );

FlagDelay = 0;
[TimeLineEP, ...
    EyeEventSecP, EyeEventMsecP, ThetaEventP, AngEventP, ...
    wP_1, wP_2, wP_3, wP_4, wP_5, ...
    numObjP, ObjP1, ObjP2, ObjP3, ObjP4, ...
    EyeTrackingDataP, newPosP, IndFP, BreaksOutP] = ...
    InitEyeEventsForAnalysis_v02(inputPathEvents_pro, inputPathEyeTracking_pro, FieldNames, EventNames, SUBJECT_PRO, FlagDelay);

% check if the length of trials is similar
for i=1:length(BreaksOut)-1
    CHDurTr(i) = BreaksOut(i+1,3) - BreaksOut(i,4);
end

for i=1:length(BreaksOutP)-1
    CHDurTrP(i) = BreaksOutP(i+1,3) - BreaksOutP(i,4);
end

%process data of Test Subject
len = length(EyeTrackingData);

%TimeLine = EyeTrackingData(:,1) + EyeTrackingData(:,2)/1000000;
TimeLine = EyeTrackingData(:,17);
eyeTrStart = TimeLineE(1);
%TimeLine = TimeLine - TimeLine(1);
TimeLine = TimeLine - TimeLineE(1);

TimeLineR = [0; diff(TimeLine)];
BreakPnt = find(TimeLineR>0.5);

%find break pnt on events
TimeLineE = TimeLineE - TimeLineE(1);
TimeLineRE = [0; diff(TimeLineE)];
BreakPntE = find(TimeLineRE>1);


indL = find( EyeTrackingData(:,11) == 0 );
indR = find( EyeTrackingData(:,12) == 0 );

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

EyeTrSrc = ones(len,2)*(-1);
EyeTrSrc(indFBEyes,1) = ( EyeTrackingData(indFBEyes,3) + EyeTrackingData(indFBEyes,5) )*res(1)/2;
EyeTrSrc(indFBEyes,2) = ( EyeTrackingData(indFBEyes,4) + EyeTrackingData(indFBEyes,6) )*res(2)/2;
EyeTrSrc(indFLEyes,1) = EyeTrackingData(indFLEyes,3)*res(1);
EyeTrSrc(indFLEyes,2) = EyeTrackingData(indFLEyes,4)*res(2);
EyeTrSrc(indFREyes,1) = EyeTrackingData(indFREyes,5)*res(1);
EyeTrSrc(indFREyes,2) = EyeTrackingData(indFREyes,6)*res(2);

DistCEyeTrSrc = ones(len,1)*(-1);
DistCEyeTrSrc(indFAEyes) = sqrt(  ( EyeTrSrc(indFAEyes,1) - Cres(1) ).^2 + ( EyeTrSrc(indFAEyes,2) - Cres(2) ).^2  );

%process data from pro-baby
lenP = length(EyeTrackingDataP);

%TimeLineP = EyeTrackingDataP(:,1) + EyeTrackingDataP(:,2)/1000000;
TimeLineP = EyeTrackingDataP(:,17);
eyeTrStartP = TimeLineEP(1);
%TimeLineP = TimeLineP - TimeLineP(1);
TimeLineP = TimeLineP - TimeLineEP(1);

TimeLineRP = [0; diff(TimeLineP)];
BreakPntP = find(TimeLineRP>0.5);

%find break pnt on events
TimeLineEP = TimeLineEP - TimeLineEP(1);
TimeLineREP = [0; diff(TimeLineEP)];
BreakPntEP = find(TimeLineREP>1);


indLP = find( EyeTrackingDataP(:,11) == 0 );
indRP = find( EyeTrackingDataP(:,12) == 0 );

t1P = zeros(lenP,1);
t2P = zeros(lenP,1);
t1P(indLP) = 1;
t2P(indRP) = 1;

t3P = t1P & t2P;
t4P = t1P & (~t2P);
t5P = (~t1P) & t2P;
t6P = t1P | t2P;

indFBEyesP = find(t3P);
indFLEyesP = find(t4P);
indFREyesP = find(t5P);
indFAEyesP = find(t6P);

EyeTrSrcP = ones(lenP,2)*(-1);
EyeTrSrcP(indFBEyesP,1) = ( EyeTrackingDataP(indFBEyesP,3) + EyeTrackingDataP(indFBEyesP,5) )*res(1)/2;
EyeTrSrcP(indFBEyesP,2) = ( EyeTrackingDataP(indFBEyesP,4) + EyeTrackingDataP(indFBEyesP,6) )*res(2)/2;
EyeTrSrcP(indFLEyesP,1) = EyeTrackingDataP(indFLEyesP,3)*res(1);
EyeTrSrcP(indFLEyesP,2) = EyeTrackingDataP(indFLEyesP,4)*res(2);
EyeTrSrcP(indFREyesP,1) = EyeTrackingDataP(indFREyesP,5)*res(1);
EyeTrSrcP(indFREyesP,2) = EyeTrackingDataP(indFREyesP,6)*res(2);

DistCEyeTrSrcP = ones(lenP,1)*(-1);
DistCEyeTrSrcP(indFAEyesP) = sqrt(  ( EyeTrSrcP(indFAEyesP,1) - Cres(1) ).^2 + ( EyeTrSrcP(indFAEyesP,2) - Cres(2) ).^2  );

%try to get rid off breaks

BrLen = length(BreakPnt);
BrLenP = length(BreakPntP);

mm = min([BrLen BrLenP]);

st0 = TimeLine(1);
st0P = TimeLineP(1);
tconst = 0;
TimeLineN = TimeLine;
TimeLinePN = TimeLineP;
mmN = 0;
for i=1:mm
    TrialDur(i) = TimeLine( BreakPnt(i) ) - st0;
    st0 = TimeLine( BreakPnt(i)+1 );
    TrialDurP(i) = TimeLineP( BreakPntP(i) ) - st0P;
    st0P = TimeLineP( BreakPntP(i)+1 );
    
    mmM = max( [TrialDur(i) TrialDurP(i)] );
    mmN = mmN + mmM + tconst;
    
    gap = mmN - TimeLine( BreakPnt(i)+1 );
    gapP = mmN - TimeLineP( BreakPntP(i)+1 );
    if(i==mm)        
        TimeLineN( BreakPnt(i):end ) = TimeLineN( BreakPnt(i):end ) + gap; 
        TimeLinePN( BreakPntP(i):end ) = TimeLinePN( BreakPntP(i):end ) + gapP; 
    else
        TimeLineN( BreakPnt(i):BreakPnt(i+1)-1 ) = TimeLineN( BreakPnt(i):BreakPnt(i+1)-1 ) + gap; 
        TimeLinePN( BreakPntP(i):BreakPntP(i+1)-1 ) = TimeLinePN( BreakPntP(i):BreakPntP(i+1)-1 ) + gapP; 
    end
end

stE0 = TimeLineE(1);
stE0P = TimeLineEP(1);
tconst = 0;
TimeLineEN = TimeLineE;
TimeLineEPN = TimeLineEP;
mmEN = 0;
for i=1:length(BreakPntE)
    TrialDurE(i) = TimeLineE( BreakPntE(i) ) - stE0;
    stE0 = TimeLine( BreakPntE(i)+1 );
    TrialDurEP(i) = TimeLineEP( BreakPntEP(i) ) - stE0P;
    stE0P = TimeLineEP( BreakPntEP(i)+1 );
    
    mmEM = max( [TrialDurE(i) TrialDurEP(i)] );
    mmEN = mmEN + mmEM + tconst;
    
    gapE = mmEN - TimeLineE( BreakPntE(i)+1 );
    gapEP = mmEN - TimeLineEP( BreakPntEP(i)+1 );

    if( i==length(BreakPntE) )
        TimeLineEN( BreakPntE(i):end ) = TimeLineEN( BreakPntE(i):end ) + gapE; 
        TimeLineEPN( BreakPntEP(i):end ) = TimeLineEPN( BreakPntEP(i):end ) + gapEP; 
    else
        TimeLineEN( BreakPntE(i):BreakPntE(i+1)-1 ) = TimeLineEN( BreakPntE(i):BreakPntE(i+1)-1 ) + gapE;
        TimeLineEPN( BreakPntEP(i):BreakPntEP(i+1)-1 ) = TimeLineEPN( BreakPntEP(i):BreakPntEP(i+1)-1 ) + gapEP;
    end
end

figure;
hold on;
plot(TimeLineEN);
plot(TimeLineEPN,'r');

figure;
hold on;

plot( TimeLineN(indFAEyes)-TimeLineN(1), DistCEyeTrSrc(indFAEyes), '.' );
plot( TimeLinePN(indFAEyesP)-TimeLinePN(1), DistCEyeTrSrcP(indFAEyesP), 'r.' );
legend('CntrlCond','ExpCond');

figure;
hold on;

pL1 = plot( TimeLineN(indFAEyes)-TimeLineN(1), DistCEyeTrSrc(indFAEyes) );
pL2 = plot( TimeLinePN(indFAEyesP)-TimeLinePN(1), DistCEyeTrSrcP(indFAEyesP), 'r' );
legend('CntrlCond','ExpCond');


% plot( TimeLine(indFAEyes)-TimeLine(1), DistCEyeTrSrc(indFAEyes) );
% plot(DistCEyeTrSrc );
% hold on;
% %plot( TimeLineP(indFAEyesP)-TimeLineP(1), DistCEyeTrSrcP(indFAEyesP), 'r' );
% plot( DistCEyeTrSrcP, 'r' );



