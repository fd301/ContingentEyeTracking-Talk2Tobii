clear all;
close all;


ExpCond = [2500 2600 2700 3800 3900 4400 4500 4600 4900 5000 6700 7100 7200 7700 8400 8300 8700 8900];
CntCond = [6900 6500 6300 6800 6400 5300 5900 6000 5700 5600 7000 7300 7400 7800 8500 8600 9000 9100];

ExpCond = [2500 2600 2700 3800 3900 4400 4600 5000 6700 7100 7200 7700 8400 8300 8700 8900];
CntCond = [6900 6500 6300 6800 6400 5300 6000 5600 7000 7300 7400 7800 8500 8600 9000 9100];
% 1->female, 0->male
Gender  = [   1    1    0    1    0    0    0    1    0    1    0    0    0    1    0    1];  

lenExp = length(ExpCond);
lenCnt = length(CntCond);

if( lenExp ~= lenCnt )
    error('Mismatch: length of experimental and cntrl condition');
end

%use only up to 10 trials
trialNum = 10;
for i=1:lenExp
    %load saccades from files
%     InputFileExp = strcat('./SacFixs2BefST_', num2str( ExpCond(i) ), '.mat');
%     InputFileCnt = strcat('./SacFixs2BefST_', num2str( CntCond(i) ), '.mat');    
    %load saccades from files - familiarisation is treated as different
    %trial
    InputFileExp = strcat('./SacFixs2BefSTF_', num2str( ExpCond(i) ), '.mat');
    InputFileCnt = strcat('./SacFixs2BefSTF_', num2str( CntCond(i) ), '.mat');    
    Exp = load(InputFileExp);
    Cnt = load(InputFileCnt);
    
    %Estimate time and where they looked first
    [TotTimLookExp, DurTrialsExp] = EstimateLookTimBefT( Exp.LookBehDFP2, Exp.ValidP, Exp.lenTrP );
    [TotTimLookCnt, DurTrialsCnt] = EstimateLookTimBefT( Cnt.LookBehDF2, Cnt.Valid, Cnt.lenTr );
    
    [FreqFixCExp, FixNumCExp] = EstFreqFixCentral( Exp.LookBehDFP2, Exp.ValidP, Exp.lenTrP );
    [FreqFixCCnt, FixNumCCnt] = EstFreqFixCentral( Cnt.LookBehDF2, Cnt.Valid, Cnt.lenTr );
    
    [FreqSacCExp(i), SacNumCExp{i}] = EstFreqSacCentral( Exp.SacLookBehFP2 );
    [FreqSacCCnt(i), SacNumCCnt{i}] = EstFreqSacCentral( Cnt.SacLookBehF2 );
    
    FixNumExp{i} = FixNumCExp;
    FixNumCnt{i} = FixNumCCnt;
    len1 = length(FixNumCExp);
    len2 = length(FixNumCCnt);
    FixNumDif{i} = FixNumCExp(1:len2) - FixNumCCnt;
    FixNumDifM(i,:) = [FreqFixCExp FreqFixCCnt];
    
    FixNumExp2(i,:) = FixNumCExp(1:trialNum+1);
    FixNumCnt2(i,:) = FixNumCCnt(1:trialNum+1);
    
    
    TotTimLookExpS(i,:) = sum( TotTimLookExp(1:trialNum,:), 2 ) ./ DurTrialsExp(1:trialNum)' ;
    TotTimLookCntS(i,:) = sum( TotTimLookCnt(1:trialNum,:), 2 ) ./ DurTrialsCnt(1:trialNum)';
    
    TotTimLookExpSTim{i} = sum( TotTimLookExp, 2 ) ./ DurTrialsExp' ;
    TotTimLookCntSTim{i} = sum( TotTimLookCnt, 2 ) ./ DurTrialsCnt';
    TotTimLookExpSTimM(i) = mean(TotTimLookExpSTim{i});
    TotTimLookCntSTimM(i) = mean(TotTimLookCntSTim{i});
    
    
    TotTimLookExpS2(i,:) = ( TotTimLookExp(1:trialNum,2)+TotTimLookExp(1:trialNum,3) ) ./ DurTrialsExp(1:trialNum)';
    TotTimLookCntS2(i,:) = ( TotTimLookCnt(1:trialNum,2)+TotTimLookCnt(1:trialNum,3) ) ./ DurTrialsCnt(1:trialNum)';
    
    TotTimLookExpS3(i,:) = TotTimLookExp(1:trialNum,1) ./ DurTrialsExp(1:trialNum)';
    TotTimLookCntS3(i,:) = TotTimLookCnt(1:trialNum,1) ./ DurTrialsCnt(1:trialNum)';
    
    figure;
    hold on;
    plot(1:trialNum, TotTimLookExpS(i,:));
    plot(1:trialNum, TotTimLookCntS(i,:),'r');
    plot(1:trialNum, TotTimLookExpS2(i,:),'--');
    plot(1:trialNum, TotTimLookCntS2(i,:),'r--');
    plot(1:trialNum, TotTimLookExpS3(i,:),'*');
    plot(1:trialNum, TotTimLookCntS3(i,:),'r*');
    legend('ExpS','CntS','ExpO','CntO','ExpC','CntC');
       
end


AverTotTimeExp = mean(TotTimLookExpS,1);
AverTotTimeCnt = mean(TotTimLookCntS,1);

AverTotTimeExp2 = mean(TotTimLookExpS2,1);
AverTotTimeCnt2 = mean(TotTimLookCntS2,1);

AverTotTimeExp3 = mean(TotTimLookExpS3,1);
AverTotTimeCnt3 = mean(TotTimLookCntS3,1);

AverTotTimeExp4 = (TotTimLookExpS3 - TotTimLookExpS2) ./ (TotTimLookExpS3 + TotTimLookExpS2);
AverTotTimeCnt4 = (TotTimLookCntS3 - TotTimLookCntS2) ./ (TotTimLookCntS3 + TotTimLookCntS2);

AverTotTimeExp5_1 = mean( AverTotTimeExp4(:,1:5), 2);
AverTotTimeExp5_2 = mean( AverTotTimeExp4(:,6:10), 2);
AverTotTimeCnt5_1 = mean( AverTotTimeCnt4(:,1:5), 2);
AverTotTimeCnt5_2 = mean( AverTotTimeCnt4(:,6:10), 2);

AverTotTimeExp6_1 = mean( TotTimLookExpS3(:,1:5), 2);
AverTotTimeExp6_2 = mean( TotTimLookExpS3(:,6:10), 2);
AverTotTimeCnt6_1 = mean( TotTimLookCntS3(:,1:5), 2);
AverTotTimeCnt6_2 = mean( TotTimLookCntS3(:,6:10), 2);


figure
hold on;
plot(AverTotTimeExp);
plot(AverTotTimeCnt,'r');
plot(AverTotTimeExp2,'--');
plot(AverTotTimeCnt2,'r--');
plot(AverTotTimeExp3,'*');
plot(AverTotTimeCnt3,'r*');

legend('ExpS','CntS','ExpO','CntO','ExpC','CntC');

%apply anova
p = anova2([AverTotTimeExp' AverTotTimeCnt']);

% ttest of the number of saccades to the central object from anywhere else
[hS, pS, statS] = ttest( FreqSacCExp - FreqSacCCnt );

