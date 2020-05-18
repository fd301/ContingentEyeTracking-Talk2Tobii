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

ConstEyeNF = -100;

ElpsCnst1 = 334.82/2;
ElpsCnst2 = 394.19/2;

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


%% Baby --- Control Condition
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

BreaksOut(:,3:4) = BreaksOut(:,3:4) - eyeTrStart;

%try to find when interactive respond starts and when finishes
InterResp = IndF{5};
IntRTable(1,:) = [InterResp(1) 0];
count = 1;
for i=1:length(InterResp)-1
    if( InterResp(i+1)-InterResp(i) ~=1 )
        IntRTable(count,2) = InterResp(i); 
        IntRTable(count+1,:) = [InterResp(i+1) 0];
        count = count+1;
    end
end
IntRTable(end,2) = InterResp(end);
%find event times
for i=1:length(IntRTable)
    IntRTimes(i,:) = [ TimeLineE(IntRTable(i,1)+1) TimeLineE(IntRTable(i,2)+1) ];
    if(i>4)
        NumBr(i) = floor( (i-5)/3 );
    else
        NumBr(i) = 0;
    end
end
IntRTimesN = IntRTimes;

%estimate where the baby look on the screen based on any eye data available
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

EyeTrSrc = ones(len,2)*ConstEyeNF;
EyeTrSrc(indFBEyes,1) = ( EyeTrackingData(indFBEyes,3) + EyeTrackingData(indFBEyes,5) )*res(1)/2;
EyeTrSrc(indFBEyes,2) = ( EyeTrackingData(indFBEyes,4) + EyeTrackingData(indFBEyes,6) )*res(2)/2;
EyeTrSrc(indFLEyes,1) = EyeTrackingData(indFLEyes,3)*res(1);
EyeTrSrc(indFLEyes,2) = EyeTrackingData(indFLEyes,4)*res(2);
EyeTrSrc(indFREyes,1) = EyeTrackingData(indFREyes,5)*res(1);
EyeTrSrc(indFREyes,2) = EyeTrackingData(indFREyes,6)*res(2);

DistCEyeTrSrc = ones(len,1)*ConstEyeNF;
DistCEyeTrSrc(indFAEyes) = sqrt(  ( EyeTrSrc(indFAEyes,1) - Cres(1) ).^2 + ( EyeTrSrc(indFAEyes,2) - Cres(2) ).^2  );


%% Pro-Baby --- Experimental Condition
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

BreaksOutP(:,3:4) = BreaksOutP(:,3:4) - eyeTrStartP;

%try to find when interactive respond starts and when finishes
InterRespP = IndFP{5};
IntRTableP(1,:) = [InterRespP(1) 0];
count = 1;
for i=1:length(InterRespP)-1
    if( InterRespP(i+1)-InterRespP(i) ~=1 )
        IntRTableP(count,2) = InterRespP(i); 
        IntRTableP(count+1,:) = [InterRespP(i+1) 0];
        count = count+1;
    end
end
IntRTableP(end,2) = InterRespP(end);
%find event times
for i=1:length(IntRTable)
    IntRTimesP(i,:) = [ TimeLineEP(IntRTableP(i,1)+1) TimeLineEP(IntRTableP(i,2)+1) ];
    if(i>4)
        NumBrP(i) = floor( (i-5)/3 );
    else
        NumBrP(i) = 0;
    end
end
IntRTimesPN = IntRTimesP;

%estimate where the baby look on the screen based on any eye data available
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

EyeTrSrcP = ones(lenP,2)*ConstEyeNF;
EyeTrSrcP(indFBEyesP,1) = ( EyeTrackingDataP(indFBEyesP,3) + EyeTrackingDataP(indFBEyesP,5) )*res(1)/2;
EyeTrSrcP(indFBEyesP,2) = ( EyeTrackingDataP(indFBEyesP,4) + EyeTrackingDataP(indFBEyesP,6) )*res(2)/2;
EyeTrSrcP(indFLEyesP,1) = EyeTrackingDataP(indFLEyesP,3)*res(1);
EyeTrSrcP(indFLEyesP,2) = EyeTrackingDataP(indFLEyesP,4)*res(2);
EyeTrSrcP(indFREyesP,1) = EyeTrackingDataP(indFREyesP,5)*res(1);
EyeTrSrcP(indFREyesP,2) = EyeTrackingDataP(indFREyesP,6)*res(2);

DistCEyeTrSrcP = ones(lenP,1)*ConstEyeNF;
DistCEyeTrSrcP(indFAEyesP) = sqrt(  ( EyeTrSrcP(indFAEyesP,1) - Cres(1) ).^2 + ( EyeTrSrcP(indFAEyesP,2) - Cres(2) ).^2  );

%try to get rid off breaks

BrLen = length(BreakPnt);
BrLenP = length(BreakPntP);

mm = min([BrLen BrLenP]);

st0 = TimeLine(1);
st0P = TimeLineP(1);
tconst = 5;
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
    
    gap(i) = mmN - TimeLine( BreakPnt(i)+1 );
    gapP(i) = mmN - TimeLineP( BreakPntP(i)+1 );
    if(i==mm)        
        TimeLineN( BreakPnt(i):end ) = TimeLineN( BreakPnt(i):end ) + gap(i); 
        TimeLinePN( BreakPntP(i):end ) = TimeLinePN( BreakPntP(i):end ) + gapP(i); 
    else
        TimeLineN( BreakPnt(i):BreakPnt(i+1)-1 ) = TimeLineN( BreakPnt(i):BreakPnt(i+1)-1 ) + gap(i); 
        TimeLinePN( BreakPntP(i):BreakPntP(i+1)-1 ) = TimeLinePN( BreakPntP(i):BreakPntP(i+1)-1 ) + gapP(i); 
    end
end

for i=1:length(IntRTimes)
    if( NumBr(i) )
        IntRTimesN(i,:) = IntRTimesN(i,:) + gap( NumBr(i) ); 
    end
end

for i=1:length(IntRTimesP)
    if( NumBrP(i) )
        IntRTimesPN(i,:) = IntRTimesPN(i,:) + gapP( NumBrP(i) ); 
    end
end


stE0 = TimeLineE(1);
stE0P = TimeLineEP(1);
tconst = 5;
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

%%%%%%%%%%%%%%%%%%
% estimate number of samples at each trial and compare
ind1 = 1;
for i=1:length(BreakPnt)
    ind2 = BreakPnt(i);

    ts1 = zeros(len,1);
    ts2 = zeros(len,1);
    tind1 = find( indFAEyes>=ind1 );
    tind2 = find( indFAEyes<ind2 );
    ts1(tind1) = 1;
    ts2(tind2) = 1;
    ts = ts1 & ts2;
    tind = find(ts); %these are the indexes of the segment that either eye has found
    tmp = find( DistCEyeTrSrc(tind)<ElpsCnst1 );
    numPntFix1(i) = length(tmp);
    tmp = find( DistCEyeTrSrc(tind)<ElpsCnst2 );
    numPntFix2(i) = length(tmp);
    lenTrials(i) = ind2-ind1;
    lenEyesNF(i) = lenTrials(i) - length(tind);

    ind1 = ind2+1;
end

ind1 = 1;
for i=1:length(BreakPntP)
    ind2 = BreakPntP(i);

    ts1P = zeros(lenP,1);
    ts2P = zeros(lenP,1);
    tind1P = find( indFAEyesP>ind1 );
    tind2P = find( indFAEyesP<ind2 );
    ts1P(tind1P) = 1;
    ts2P(tind2P) = 1;
    tsP = ts1P & ts2P;
    tindP = find(tsP); %these are the indexes of the segment that either eye has found
    tmp = find( DistCEyeTrSrcP(tindP)<ElpsCnst1 );
    numPntFixP1(i) = length(tmp);
    tmp = find( DistCEyeTrSrcP(tindP)<ElpsCnst2 );
    numPntFixP2(i) = length(tmp);
    lenTrialsP(i) = ind2-ind1;
    lenEyesNFP(i) = lenTrialsP(i) - length(tindP);

    ind1 = ind2+1;
end

figure
hold on;
plot(numPntFix1./lenTrials);
plot(numPntFixP1./lenTrialsP,'r');
plot(lenEyesNF./lenTrials,'c--');
plot(lenEyesNFP./lenTrialsP,'m--');
legend( strcat( 'CntrlCond: ',num2str(SUBJECT) ), strcat('ExpCond: ',num2str(SUBJECT_PRO) ), 'EyesNFCNTRL', 'EyesNFEXP' );
plot(numPntFix2./lenTrials,'--');
plot(numPntFixP2./lenTrialsP,'r--');
grid on;

%%%%%%%%%%%%%%%%%
%plot again and split familiarisation and trials to two parts:
% end of familiarisation:
endFam = IndF{10};
% 3D object turns
theta = IndF{3};
turn = diff(theta);
tmp = find(turn>10);
stTurn = [tmp; length(theta)];
%find timing in event timeline
endFamT = TimeLineE(endFam);
stTurnT = TimeLineE( theta(stTurn) );
allTimInt = [endFamT; stTurnT];
%find closest eyetracking sample for each event
for i=1:length(allTimInt)
    tmpDist = abs( TimeLine - allTimInt(i) );
    [tmp indM] = min(tmpDist);
    TLEv(i) = indM;
end

AllBreaks = [TLEv'; BreakPnt];
AllBreaks = sort(AllBreaks);

%estimate number of eyetracking samples for each interval
ind1 = 1;
for i=1:length(AllBreaks)
    ind2 = AllBreaks(i);

    ts1 = zeros(len,1);
    ts2 = zeros(len,1);
    tind1 = find( indFAEyes>=ind1 );
    tind2 = find( indFAEyes<ind2 );
    ts1(tind1) = 1;
    ts2(tind2) = 1;
    ts = ts1 & ts2;
    tind = find(ts); %these are the indexes of the segment that either eye has found
    tmp = find( DistCEyeTrSrc(tind)<ElpsCnst1 );
    numPntAFix1(i) = length(tmp);
    tmp = find( DistCEyeTrSrc(tind)<ElpsCnst2 );
    numPntAFix2(i) = length(tmp);
    lenTrialsA(i) = ind2-ind1;
    lenEyesNFA(i) = lenTrialsA(i) - length(tind);

    ind1 = ind2+1;
end

%do the same for exp subject
endFamP = IndFP{10};
% 3D object turns
thetaP = IndFP{3};
turnP = diff(thetaP);
tmp = find(turnP>10);
stTurnP = [tmp; length(thetaP)];
%find timing in event timeline
endFamTP = TimeLineEP(endFamP);
stTurnTP = TimeLineEP( thetaP(stTurnP) );
allTimIntP = [endFamTP; stTurnTP];
%find closest eyetracking sample for each event
for i=1:length(allTimIntP)
    tmpDist = abs( TimeLineP - allTimIntP(i) );
    [tmp indMP] = min(tmpDist);
    TLEvP(i) = indMP;
end

AllBreaksP = [TLEvP'; BreakPntP];
AllBreaksP = sort(AllBreaksP);

%estimate number of eyetracking samples for each interval
ind1 = 1;
for i=1:length(AllBreaksP)
    ind2 = AllBreaksP(i);

    ts1P = zeros(lenP,1);
    ts2P = zeros(lenP,1);
    tind1P = find( indFAEyesP>ind1 );
    tind2P = find( indFAEyesP<ind2 );
    ts1P(tind1P) = 1;
    ts2P(tind2P) = 1;
    tsP = ts1P & ts2P;
    tindP = find(tsP); %these are the indexes of the segment that either eye has found
    tmp = find( DistCEyeTrSrcP(tindP)<ElpsCnst1 );
    numPntAFixP1(i) = length(tmp);
    tmp = find( DistCEyeTrSrcP(tindP)<ElpsCnst2 );
    numPntAFixP2(i) = length(tmp);
    lenTrialsAP(i) = ind2-ind1;
    lenEyesNFAP(i) = lenTrialsAP(i) - length(tindP);

    ind1 = ind2+1;
end

figure
hold on;

plot( 0:0.5:(length(AllBreaks)-1)/2, numPntAFix1./lenTrialsA );
plot( 0:0.5:(length(AllBreaksP)-1)/2, numPntAFixP1./lenTrialsAP,'r');
plot( 0:0.5:(length(AllBreaks)-1)/2, lenEyesNFA./lenTrialsA,'c--');
plot( 0:0.5:(length(AllBreaksP)-1)/2, lenEyesNFAP./lenTrialsAP,'m--');
legend( strcat( 'CntrlCond: ',num2str(SUBJECT) ), strcat('ExpCond: ',num2str(SUBJECT_PRO) ), 'EyesNFCNTRL', 'EyesNFEXP' );
plot( 0:0.5:(length(AllBreaks)-1)/2, numPntAFix2./lenTrialsA,'--');
plot( 0:0.5:(length(AllBreaksP)-1)/2, numPntAFixP2./lenTrialsAP,'r--');
grid on;

for i=0:length(BreakPnt)
    tcolor = [0.8 0.8 0.8];
    xx = [i+0.5 i+1 i+1 i+0.5];
    limY = ylim;
    yy = [limY(1) limY(1) limY(2)  limY(2)];
    tt = fill( xx, yy, tcolor);
    set(tt,'FaceAlpha',0.4);
    set(tt,'EdgeAlpha',0);
end


%%%%%%%%%%%%%%%%%%

% figure;
% hold on;
% plot(TimeLineEN);
% plot(TimeLineEPN,'r');

figure;
hold on;

plot( TimeLineN, DistCEyeTrSrc, '.' );
plot( TimeLinePN, DistCEyeTrSrcP, 'r.' );
legend('CntrlCond','ExpCond');
for i=1:length(IntRTimesN)
    plot([IntRTimesN(i,1) IntRTimesN(i,1) IntRTimesN(i,2) IntRTimesN(i,2)], [0 1000 1000 0], 'k');
end
grid on;
xx = xlim;
plot(xx, [334.82/2 334.82/2], 'k--');
plot(xx, [394.19/2 394.19/2], 'k--');
diag = sqrt( (res(1)/2)^2 + (res(2)/2)^2 );
plot(xx, [diag diag], 'k--');
plot(xx, [res(1)/2 res(1)/2], 'k--');
plot(xx, [res(2)/2 res(2)/2], 'k--');

figure;
hold on;

pL1 = plot( TimeLineN, DistCEyeTrSrc );
pL2 = plot( TimeLinePN, DistCEyeTrSrcP, 'r' );
legend('CntrlCond','ExpCond');
for i=1:length(IntRTimesN)
    plot([IntRTimesN(i,1) IntRTimesN(i,1) IntRTimesN(i,2) IntRTimesN(i,2)], [0 1000 1000 0], 'k');
end
grid on;
xx = xlim;
plot(xx, [334.82/2 334.82/2], 'k--');
plot(xx, [394.19/2 394.19/2], 'k--');
diag = sqrt( (res(1)/2)^2 + (res(2)/2)^2 );
plot(xx, [diag diag], 'k--');
plot(xx, [res(1)/2 res(1)/2], 'k--');
plot(xx, [res(2)/2 res(2)/2], 'k--');

% plot( TimeLine(indFAEyes)-TimeLine(1), DistCEyeTrSrc(indFAEyes) );
% plot(DistCEyeTrSrc );
% hold on;
% %plot( TimeLineP(indFAEyesP)-TimeLineP(1), DistCEyeTrSrcP(indFAEyesP), 'r' );
% plot( DistCEyeTrSrcP, 'r' );



