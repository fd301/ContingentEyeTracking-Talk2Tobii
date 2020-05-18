%analysis estimate of time proportion that baby looks at the centre
close all;
clear all;

%SUBJECT = input('Test Subject number: ');

%SUBJECT_PRO = input('Pro Subject number: ');

%6-month old infants
%ExpCond = [5100 5200 5400 5500 9300 9400 9500 9600 9800 9900 10000 10200 10300 10400 10500];
%There was a problem with 5500 and 9900
ExpCond = [ 10000 10200 10300 10400 10500];


for mm=1:length(ExpCond)
    SUBJECT_PRO = ExpCond(mm);

    outPutfileP = strcat('./SacFixs_', num2str(SUBJECT_PRO), '.mat');

    %before 5sec
    outPutfileP2 = strcat('./SacFixs2BefT_', num2str(SUBJECT_PRO), '.mat');
    %before start turning
    outPutfileP3 = strcat('./SacFixs2BefST_', num2str(SUBJECT_PRO), '.mat');
    %before start turning (familiarisation is encoded separately)
    outPutfileP4 = strcat('./SacFixs2BefSTF_', num2str(SUBJECT_PRO), '.mat');


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


    FlagDelay = 0;
    [TimeLineEP, ...
        EyeEventSecP, EyeEventMsecP, ThetaEventP, AngEventP, ...
        wP_1, wP_2, wP_3, wP_4, wP_5, ...
        numObjP, ObjP1, ObjP2, ObjP3, ObjP4, ...
        EyeTrackingDataP, newPosP, IndFP, BreaksOutP, IndTrWNBrP, IndFirstTrP] = ...
        InitEyeEventsForAnalysis_v02(inputPathEvents_pro, inputPathEyeTracking_pro, FieldNames, EventNames, SUBJECT_PRO, FlagDelay);

    % check if the length of trials is similar
    for i=1:length(BreaksOutP)-1
        CHDurTrP(i) = BreaksOutP(i+1,3) - BreaksOutP(i,4);
    end



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
    [FixObjRP,lenTrP] = face2objFix(LookBehDP, LookBehTP);

    %store frequency of saccades details during the last 5sec of each trial
    save(outPutfileP, 'FixObjRP','ValidP','lenTrP','LookBehDP','LookBehTP', 'SacLookBehP');

    %fixations and saccades during trial up to turning
    %save(outPutfileP2, 'LookBehDP2', 'LookBehTP2', 'ValidP','lenTrP' );

    
    %save the saccades&fixations for both familiarisation and trials before
    %turning point
    %save(outPutfileP3, 'LookBehDP2', 'LookBehTP2','ValidP','lenTrP' );

    
    %save the saccades&fixations for both familiarisation and trials before
    %turning point (familiarisatin is encoded as separate trial)
    save(outPutfileP4, 'LookBehDFP2', 'LookBehTFP2', 'SacLookBehFP2', 'ValidP','lenTrP' );
    
end
