clear all;
close all;


ExpCond = [2500 2600 2700 3800 3900 4400 4500 4600 4900 5000 6700 7100 7200 7700];
CntCond = [6900 6500 6300 6800 6400 5300 5900 6000 5700 5600 7000 7300 7400 7800];

lenExp = length(ExpCond);
lenCnt = length(CntCond);

if( lenExp ~= lenCnt )
    error('Mismatch: length of experimental and cntrl condition');
end

xi = 0:1/99:1;
for i=1:lenExp
    %load saccades from files
    InputFileExp = strcat('./SacFixs2BefST_', num2str( ExpCond(i) ), '.mat');
    InputFileCnt = strcat('./SacFixs2BefST_', num2str( CntCond(i) ), '.mat');    
    Exp = load(InputFileExp);
    Cnt = load(InputFileCnt);
    
    %Estimate time and where they looked first
    [TotTimLookExp, DurTrialsExp] = EstimateLookTimBefT( Exp.LookBehDP2, Exp.ValidP, Exp.lenTrP );
    [TotTimLookCnt, DurTrialsCnt] = EstimateLookTimBefT( Cnt.LookBehD2, Cnt.Valid, Cnt.lenTr );
    
    try
        disp( mean(DurTrialsExp-DurTrialsCnt) );
    catch
        disp( DurTrialsExp );
        disp( DurTrialsCnt );
    end
    TotTimLookExpS{i} = sum( TotTimLookExp, 2 ) ./ DurTrialsExp';
    TotTimLookCntS{i} = sum( TotTimLookCnt, 2 ) ./ DurTrialsCnt';
    
    TotTimLookExpS2{i} = ( TotTimLookExp(:,2)+TotTimLookExp(:,3) ) ./ DurTrialsExp';
    TotTimLookCntS2{i} = ( TotTimLookCnt(:,2)+TotTimLookCnt(:,3) ) ./ DurTrialsCnt';
    
    TotTimLookExpS3{i} =  TotTimLookExp(:,1) ./ DurTrialsExp';
    TotTimLookCntS3{i} = TotTimLookCnt(:,1) ./ DurTrialsCnt';
    
    lenE = length(TotTimLookExp);
    lenC = length(TotTimLookCnt);
    ratio = lenC/lenE;
    figure;
    hold on;

    IntTotTimExp{i} = interp1(0:1/(lenE-1):1, TotTimLookExpS{i},xi);
    IntTotTimCnt{i} = interp1(0:1/(lenE-1):1-(lenE-lenC)/(lenE-1), TotTimLookCntS{i},0:1/99:ratio);

    IntTotTimExp2{i} = interp1(0:1/(lenE-1):1, TotTimLookExpS2{i},xi);
    IntTotTimCnt2{i} = interp1(0:1/(lenE-1):1-(lenE-lenC)/(lenE-1), TotTimLookCntS2{i},0:1/99:ratio);

    IntTotTimExp3{i} = interp1(0:1/(lenE-1):1, TotTimLookExpS3{i},xi);
    IntTotTimCnt3{i} = interp1(0:1/(lenE-1):1-(lenE-lenC)/(lenE-1), TotTimLookCntS3{i},0:1/99:ratio);
    
%      plot(0:1/(lenE-1):1, TotTimLookExpS{i});
%      plot(0:1/(lenE-1):1-(lenE-lenC)/(lenE-1), TotTimLookPCntS{i},'r');
    
    plot( xi, IntTotTimExp{i});
    plot( 0:1/99:ratio, IntTotTimCnt{i},'r');
    
    plot( xi, IntTotTimExp2{i}, '--');
    plot( 0:1/99:ratio, IntTotTimCnt2{i},'r--');
    
    plot( xi, IntTotTimExp3{i}, '*');
    plot( 0:1/99:ratio, IntTotTimCnt3{i},'r*');
       
end
legend('Exp','Cnt');

AverTotTimeExp = zeros( 1, length(xi) );
AverTotTimeCnt = zeros( 1, length(xi) );
AverTotTimeExp2 = zeros( 1, length(xi) );
AverTotTimeCnt2 = zeros( 1, length(xi) );
AverTotTimeExp3 = zeros( 1, length(xi) );
AverTotTimeCnt3 = zeros( 1, length(xi) );
count = zeros(1,length(xi));
for i=1:length(xi)
    for j=1:lenExp
        AverTotTimeExp(i) = AverTotTimeExp(i) + IntTotTimExp{j}(i);
        AverTotTimeExp2(i) = AverTotTimeExp2(i) + IntTotTimExp2{j}(i);
        AverTotTimeExp3(i) = AverTotTimeExp3(i) + IntTotTimExp3{j}(i);
        
        lenC = length(IntTotTimCnt{j});
        if(lenC>=i && ~isnan(IntTotTimCnt{j}(i)) )
            AverTotTimeCnt(i) = AverTotTimeCnt(i) + IntTotTimCnt{j}(i);
            AverTotTimeCnt2(i) = AverTotTimeCnt2(i) + IntTotTimCnt2{j}(i);
            AverTotTimeCnt3(i) = AverTotTimeCnt3(i) + IntTotTimCnt3{j}(i);
            count(i) = count(i)+1;
        else
            continue;
        end
        
    end
end
AverTotTimeExp = AverTotTimeExp / lenExp;
AverTotTimeCnt = AverTotTimeCnt ./ count;

AverTotTimeExp2 = AverTotTimeExp2 / lenExp;
AverTotTimeCnt2 = AverTotTimeCnt2 ./ count;

AverTotTimeExp3 = AverTotTimeExp3 / lenExp;
AverTotTimeCnt3 = AverTotTimeCnt3 ./ count;

figure
hold on;
plot(xi, AverTotTimeExp);
plot(xi, AverTotTimeCnt,'r');
plot(xi, AverTotTimeExp2,'--');
plot(xi, AverTotTimeCnt2,'r--');
plot(xi, AverTotTimeExp3,'*');
plot(xi, AverTotTimeCnt3,'r*');
legend('ExpS','CntS','ExpO','CntO','ExpC','CntC');


% %perform statistics for first look
% x = x1./(x1+x2) - x2./(x1+x2);
% y = y1./(y1+y2) - y2./(y1+y2);
% [h, Pt] = ttest(x,y);
% disp( strcat('PairedTest-first look:',num2str(Pt) ) );
% [h1, Pt1] = ttest(x);
% disp( strcat('t-TestExpS:',num2str(Pt1) ) );
% [h2, Pt2] = ttest(y);
% disp( strcat('t-TestExpO:',num2str(Pt2) ) );

