clear all;
close all;


%ExpCond = [2500 2600 2700 3800 3900 4400 4500 4600 4900 5000 6700 7100 7200 7700 8400 8300 8700 8900];
%CntCond = [6900 6500 6300 6800 6400 5300 5900 6000 5700 5600 7000 7300 7400 7800 8500 8600 9000 9100];

ExpCond = [2500 2600 2700 3800 3900 4400 4600 5000 6700 7100 7200 7700 8400 8300 8700 8900];
CntCond = [6900 6500 6300 6800 6400 5300 6000 5600 7000 7300 7400 7800 8500 8600 9000 9100];
% 1->female, 0->male
Gender  = [   1    1    0    1    0    0    0    1    0    1    0    0    0    1    0    1];  

lenExp = length(ExpCond);
lenCnt = length(CntCond);

if( lenExp ~= lenCnt )
    error('Mismatch: length of experimental and cntrl condition');
end

numTrExp = 0;
numTrCnt = 0;
for i=1:lenExp
    %load saccades from files
    InputFileExp = strcat('./SacFixs_', num2str( ExpCond(i) ), '.mat');
    InputFileCnt = strcat('./SacFixs_', num2str( CntCond(i) ), '.mat');    
    Exp = load(InputFileExp);
    Cnt = load(InputFileCnt);
    
    %Estimate time and where they looked first
    Validtmp = ones(1,length(Exp.ValidP));
%    [ExpFirstEN, ExpTotTimResN, ExpFirstE, ExpTimDurRes] = EstimateLookTim( Exp.FixObjRP, Exp.ValidP, Exp.lenTrP );
    [ExpFirstEN, ExpTotTimResN, ExpFirstE, ExpTimDurRes] = EstimateLookTim( Exp.FixObjRP, Validtmp, Exp.lenTrP );
    [CntFirstEN, CntTotTimResN, CntFirstE, CntTimDurRes] = EstimateLookTim( Cnt.FixObjR, Cnt.Valid, Cnt.lenTr );

    %estimate time to any of the objects on the screen
    [TotTimLookExp, DurTrialsExp] = EstimateLookTim_v02( Exp.LookBehDP, Exp.ValidP, Exp.lenTrP );
    [TotTimLookCnt, DurTrialsCnt] = EstimateLookTim_v02( Cnt.LookBehD, Cnt.Valid, Cnt.lenTr );
    TotTimLookExpSTim{i} = sum( TotTimLookExp, 2 ) ./ DurTrialsExp';
    TotTimLookCntSTim{i} = sum( TotTimLookCnt, 2 ) ./ DurTrialsCnt';
    TotTimLookExpSTimM(i) = mean(TotTimLookExpSTim{i});
    TotTimLookCntSTimM(i) = mean(TotTimLookCntSTim{i});

    %frequency of fixation to the same or the opposite object
    [ExpFreqFixN, ExpFixNumS, ExpFixNumO] = EstFreqFix( Exp.FixObjRP, Exp.ValidP, Exp.lenTrP );
    [CntFreqFixN, CntFixNumS, CntFixNumO] = EstFreqFix( Cnt.FixObjR, Cnt.Valid, Cnt.lenTr );
    
    
    x1(i) = ExpFirstEN(1);
    x2(i) = ExpFirstEN(2);
    y1(i) = CntFirstEN(1);
    y2(i) = CntFirstEN(2);
    disp( strcat( num2str(ExpCond(i)),':', num2str( x1(i) ), ', ', num2str( x2(i) ) ) );
    disp(Exp.ValidP);
    disp( strcat( num2str(CntCond(i)),':', num2str( y1(i)), ', ', num2str( y2(i) ) ) );
    disp(Cnt.Valid);
    
    x1Tim(i) = ExpTotTimResN(1);
    x2Tim(i) = ExpTotTimResN(2);
    y1Tim(i) = CntTotTimResN(1);
    y2Tim(i) = CntTotTimResN(2);
    
    x1FrF(i) = ExpFreqFixN(1);
    x2FrF(i) = ExpFreqFixN(2);
    y1FrF(i) = CntFreqFixN(1);
    y2FrF(i) = CntFreqFixN(2);
    
    %check number of trials
    numTrExp(i) = length(Exp.ValidP);
    numTrCnt(i) = length(Cnt.Valid);
    %check number of valid Trials
    numTrVExp(i) = length( find(Exp.ValidP) );
    numTrVCnt(i) = length( find(Cnt.Valid) );
end

%perform statistics for first look
x = x1./(x1+x2) - x2./(x1+x2);
y = y1./(y1+y2) - y2./(y1+y2);
[h, Pt, Ci, Stats] = ttest(x,y);
disp( strcat('PairedTest-first look:',num2str(Pt) ) );
disp(Stats);
[h1, Pt1, Ci1, Stats1] = ttest(x);
disp( strcat('t-TestExpS:',num2str(Pt1) ) );
disp(Stats1);
[h2, Pt2, Ci2, Stats2] = ttest(y);
disp( strcat('t-TestCntS:',num2str(Pt2) ) );
disp(Stats2);

%perform statistics for the time duration
xTim = x1Tim./(x1Tim+x2Tim) - x2Tim./(x1Tim+x2Tim);
yTim = y1Tim./(y1Tim+y2Tim) - y2Tim./(y1Tim+y2Tim);
[hTim, PtTim, CiTim, StatsTim] = ttest(xTim,yTim);
disp( strcat('PairedTest-time duration:',num2str(PtTim) ) );
disp(StatsTim);
[hTim1, PtTim1, CiTim1, StatsTim1] = ttest(xTim);
disp( strcat('t-TestExpS:',num2str(PtTim1) ) );
disp(StatsTim1);
[hTim2, PtTim2, CiTim2, StatsTim2] = ttest(yTim);
disp( strcat('t-TestCntS:',num2str(PtTim2) ) );
disp(StatsTim2);

%perform statistics for the frequency of fixation
xFrF = x1FrF./(x1FrF+x2FrF) - x2FrF./(x1FrF+x2FrF);
yFrF = y1FrF./(y1FrF+y2FrF) - y2FrF./(y1FrF+y2FrF);
[hFrF, PtFrF, CiFr, StatsFr] = ttest(xFrF,yFrF);
disp( strcat('PairedTest-frequency of saccades:',num2str(PtFrF) ) );
disp(StatsFr);
[hFrF1, PtFrF1, CiFr1, StatsFr1] = ttest(xFrF);
disp( strcat('t-TestExpS:',num2str(PtFrF1) ) );
disp(StatsFr1);
[hFrF2, PtFrF2, CiFr2, StatsFr2] = ttest(yFrF);
disp( strcat('t-TestCntS:',num2str(PtFrF2) ) );
disp(StatsFr2);



