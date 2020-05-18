function [FreqFixN,FixNumS, FixNumO] = EstFreqFix( FixObjR, Valid, lenTr )

trials = length(lenTr);

TrNumV = 1;
for i=1:trials
    val = Valid(i);
    if( ~val)
        continue;
    end
    
    Fixs = FixObjR{i};
    
    %look the same obj
    LookS = find( Fixs(:,3) == 2 );
    %look the opposite obj
    LookO = find( Fixs(:,3) == -1 );
    
    
    if( isempty(LookS) )
        FixNumSt = 0;
    else
        
        Sd = diff(LookS);
        tmp = find(Sd>1);
        if( isempty(tmp) )
            FixNumSt = 1;
        else
            FixNumSt = length(tmp)+1;
        end
        
    end
    
    if( isempty(LookO) )
        FixNumOt = 0;
    else
        
        Od = diff(LookO);
        tmp = find(Od>1);
        if( isempty(tmp) )
            FixNumOt = 1;
        else
            FixNumOt = length(tmp)+1;
        end
        
    end
    
    if( ~isempty(LookS) || ~isempty(LookO) )
        FixNumS(TrNumV) = FixNumSt;
        FixNumO(TrNumV) = FixNumOt;
        TrNumV = TrNumV+1;
    end
    
end

FreqFixN = [(FixNumS./(FixNumS+FixNumO))' (FixNumO./(FixNumS+FixNumO))'];
FreqFixN = mean(FreqFixN,1);


return;