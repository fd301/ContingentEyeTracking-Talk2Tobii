%analysis estimate of time proportion that baby looks at the centre
close all;
clear all;

%SUBJECT = input('Test Subject number: ');

%SUBJECT_PRO = input('Pro Subject number: ');

%8-month old infants
ExpCond = [2500 2600 2700 3800 3900 4400 4500 4600 4900 5000 6700 7100 7200 7700 8400 8300 8700 8900];
CntCond = [6900 6500 6300 6800 6400 5300 5900 6000 5700 5600 7000 7300 7400 7800 8500 8600 9000 9100];

%ExpCond = [ 8900 ];
%CntCond = [ 9100 ];

for mm=1:length(ExpCond)
    SUBJECT = CntCond(mm);
    SUBJECT_PRO = ExpCond(mm);

    outPutfile = strcat('./SacFixs_', num2str(SUBJECT), '.mat');
    outPutfileP = strcat('./SacFixs_', num2str(SUBJECT_PRO), '.mat');

    %before 5sec
    outPutfile2 = strcat('./SacFixs2BefT_', num2str(SUBJECT), '.mat');
    outPutfileP2 = strcat('./SacFixs2BefT_', num2str(SUBJECT_PRO), '.mat');
    %before start turning
    outPutfile3 = strcat('./SacFixs2BefST_', num2str(SUBJECT), '.mat');
    outPutfileP3 = strcat('./SacFixs2BefST_', num2str(SUBJECT_PRO), '.mat');
    %before start turning (familiarisation is encoded separately)
    outPutfile4 = strcat('./SacFixs2BefSTF_', num2str(SUBJECT), '.mat');
    outPutfileP4 = strcat('./SacFixs2BefSTF_', num2str(SUBJECT_PRO), '.mat');

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


    %%

    FlagDelay = 0;
    [TimeLineE, ...
        EyeEventSec, EyeEventMsec, ThetaEvent, AngEvent, ...
        w_1, w_2, w_3, w_4, w_5, ...
        numObj, Obj1, Obj2, Obj3, Obj4, ...
        EyeTrackingData, newPos, IndF, BreaksOut, IndTrWNBr, IndFirstTr] = ...
        InitEyeEventsForAnalysis_v02(inputPathEvents, inputPathEyeTracking, FieldNames, EventNames, SUBJECT, FlagDelay );

    FlagDelay = 0;
    [TimeLineEP, ...
        EyeEventSecP, EyeEventMsecP, ThetaEventP, AngEventP, ...
        wP_1, wP_2, wP_3, wP_4, wP_5, ...
        numObjP, ObjP1, ObjP2, ObjP3, ObjP4, ...
        EyeTrackingDataP, newPosP, IndFP, BreaksOutP, IndTrWNBrP, IndFirstTrP] = ...
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


    %% load data for ROI analysis -- estimate fixations and saccades
    FixSacS = orgFixSac_v2( inputPathEyeTracking, res );
    FixSacS = FixSacS(IndFirstTr:end);
    FixSacS = FixSacS(IndTrWNBr);
    [LookBehT, LookBehD, Valid, SacLookBeh ] = Extract5secRespond( FixSacS, res, IndF, TimeLine, TimeLineE, AngEvent, BreakPnt );


    %find fixations and saccades during trial up to turning.
    %[LookBehT2, LookBehD2] = ExtractTrialBefTurnRespond( FixSacS, res, IndF, TimeLine, TimeLineE,AngEvent, BreakPnt );

    %find fixations and saccades during trialS: up to turning (familiarisation is included as separate trial)
    [LookBehTF2, LookBehDF2, SacLookBehF2] = ExtractTrialBefTurnRespond_Fam( FixSacS, res, IndF, TimeLine, TimeLineE,AngEvent, BreakPnt );

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


    FixSacSP = orgFixSac_v2( inputPathEyeTracking_pro, res );
    FixSacSP = FixSacSP(IndFirstTrP:end);
    FixSacSP = FixSacSP(IndTrWNBrP);
    [LookBehTP, LookBehDP, ValidP, SacLookBehP ] = Extract5secRespond( FixSacSP, res, IndFP, TimeLineP, TimeLineEP, AngEventP, BreakPntP );

    %find fixations and saccades during trial up to turning.
    %[LookBehTP2, LookBehDP2] = ExtractTrialBefTurnRespond( FixSacSP, res, IndFP, TimeLineP, TimeLineEP, AngEventP, BreakPntP );
    %find fixations and saccades during trialS: up to turning (familiarisation is included as separate trial)
    [LookBehTFP2, LookBehDFP2, SacLookBehFP2] = ExtractTrialBefTurnRespond_Fam( FixSacSP, res, IndFP, TimeLineP, TimeLineEP, AngEventP, BreakPntP );

    
    % How many face to object saccades etc
    [FixObjR,lenTr] = face2objFix(LookBehD, LookBehT);
    [FixObjRP,lenTrP] = face2objFix(LookBehDP, LookBehTP);

    %store frequency of saccades details during the last 5sec of each trial
    save(outPutfile, 'FixObjR','Valid','lenTr','LookBehD','LookBehT', 'SacLookBeh');
    save(outPutfileP, 'FixObjRP','ValidP','lenTrP','LookBehDP','LookBehTP', 'SacLookBehP');

    %fixations and saccades during trial up to turning
    %save(outPutfile2, 'LookBehD2', 'LookBehT2', 'Valid','lenTr' );
    %save(outPutfileP2, 'LookBehDP2', 'LookBehTP2', 'ValidP','lenTrP' );

    
    %save the saccades&fixations for both familiarisation and trials before
    %turning point
    %save(outPutfile3, 'LookBehD2', 'LookBehT2','Valid','lenTr' );
    %save(outPutfileP3, 'LookBehDP2', 'LookBehTP2','ValidP','lenTrP' );

    
    %save the saccades&fixations for both familiarisation and trials before
    %turning point (familiarisatin is encoded as separate trial)
    save(outPutfile4, 'LookBehDF2', 'LookBehTF2', 'SacLookBehF2', 'Valid','lenTr' );
    save(outPutfileP4, 'LookBehDFP2', 'LookBehTFP2', 'SacLookBehFP2', 'ValidP','lenTrP' );
    
end
%% estimate number of trials
[tmprow, trials] = size(LookBehD);
lenSacResp = length(LookBehT);


figure;
hold on;
constInt = 2;
b = 0;
a = 0;
numZeros = 260;
if(numZeros < lenSacResp )
    warning('AnalyROI: Some of the data are ignored!');
end

for i=1:trials
    trialD = ones(1,numZeros)*(-10);
    for j=1:lenSacResp
        if( isempty(LookBehD{j,i}) )
            continue;
        end
        trialD(j) = LookBehD{j,i};
    end
    %plot( (i-1)*numZeros:i*numZeros-1, trialD,'b' );
    plot( (i-1)*numZeros:i*numZeros-1, trialD, '.b' );

end


lenSacRespP = length(LookBehTP);
if(numZeros < lenSacRespP )
    warning('AnalyROI: Some of the data are ignored!');
end

[tmprow, trialsP] = size(LookBehDP);
for i=1:trialsP
    trialDP = ones(1,numZeros)*(-10);
    for j=1:lenSacRespP
        if( isempty(LookBehDP{j,i}) )
            continue;
        end
        trialDP(j) = LookBehDP{j,i};
    end
    %plot( (i-1)*numZeros:i*numZeros-1, trialDP,'r' );
    plot( (i-1)*numZeros:i*numZeros-1, trialDP, '.r' );

end

legend(strcat( 'CntrlCond: ',num2str(SUBJECT) ), strcat( 'ExpCond: ',num2str(SUBJECT_PRO) ), 'Location','NorthEastOutside');

axC = axis;
for i=1:trials
    plot( [i*numZeros-1 i*numZeros-1], [axC(3) axC(4)], 'k' );
end
