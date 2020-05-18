function finRes = FixSacFinalRes(FixObjR, Valid, LenTr )

numTrials = length(FixObjR);
numTrV = numTrials;
FirstLookS = 0;
FirstLookO = 0;
for i=1:numTrials
    if( ~Valid(i) )
        numTrV = numTrV-1;
        continue;
    end
    
    trialR = FixObjR{i};
    DurFix = trialR(:,2)-trialR(:,1)+1;
    lenA = LenTr(i);
    DurFixN1 = DurFix/lenA;
    
    
    
end



