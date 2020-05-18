clear all;
close all;


ExpCond = [2500 2600 2700 3800 3900 4400 4500 4600 4900 5000 6700 7100 7200 7700 8400 8300 8700 8900];
CntCond = [6900 6500 6300 6800 6400 5300 5900 6000 5700 5600 7000 7300 7400 7800 8500 8600 9000 9100];

% ExpCond = [2500 2600 2700 3800 3900 4400 4600 5000 6700 7100 7200 7700 8400 8300 8700 8900];
% CntCond = [6900 6500 6300 6800 6400 5300 6000 5600 7000 7300 7400 7800 8500 8600 9000 9100];
% % 1->female, 0->male
% Gender  = [   1    1    0    1    0    0    0    1    0    1    0    0    0    1    0    1];  

lenExp = length(ExpCond);
lenCnt = length(CntCond);

if( lenExp ~= lenCnt )
    error('Mismatch: length of experimental and cntrl condition');
end

numTrExp = 0;
numTrCnt = 0;
for i=1:lenExp
    %load saccades from files
    InputFileExp = strcat('../SacFixs2BefSTF_', num2str( ExpCond(i) ), '.mat');
    InputFileCnt = strcat('../SacFixs2BefSTF_', num2str( CntCond(i) ), '.mat');    
    Exp = load(InputFileExp);
    Cnt = load(InputFileCnt);
    
    %Find when babies look: Central Object->somewhere else->Central Object
    %and count the duration of the time looking: somwehere else
    [trials1,trialsM1] = EstimateLookElseTim_v01( Exp.LookBehDFP2, Exp.ValidP );
    [trials2,trialsM2] = EstimateLookElseTim_v01( Cnt.LookBehDF2, Cnt.Valid ); 
    trialsM1 = trialsM1(2:end);
    trialsM2 = trialsM2(2:end);
    aver1(i) = mean(trialsM1(find(trialsM1~=-1    )   ) );
    aver2(i) = mean(trialsM2(find(trialsM2~=-1    )   ) );
    
    disp(ExpCond(i));
    disp(trialsM1);
    disp(CntCond(i));
    disp(trialsM2);
    
end

