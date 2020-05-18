function [TimDurRes, DurTrials] = EstimateLookTim_v02( FixObjR, Valid, lenTr )

trials = length(lenTr);

count = 0;
countN = 1;
for i=1:trials
    val = Valid(i);
    if( ~val)
        continue;
    end
    count = count+1;
    
    FixS = FixObjR(:,i);
    for j=1:length(FixS)
        tmp = FixS{j};
        if( ~isempty(tmp) )
            Fixs(countN) = tmp;
            countN = countN+1;
        end
    end
    TimDurS = 0;
    TimDurO = 0;
    TimDurC = 0;
    TimDurH = 0;
    TimTot = 0;
    
    %Looking the same Obj
    Same = find( Fixs == 2 );    
    if( ~isempty(Same) )        
        TimDurS = length(Same);       
    end
    
    %Looking the opposite obj
    Opp = find( Fixs == -1 );
    if( ~isempty(Opp) )        
        TimDurO = length(Opp);        
    end
    
    %Looking the central object
    Cen = find( Fixs == 0 );
    if( ~isempty(Cen) )        
        TimDurC = length(Cen);        
    end
    
    %Looking t the hand of the central object
    Hand = find( Fixs == 1 );
    if( ~isempty(Cen) )        
        TimDurH = length(Hand);        
    end
    
    TimDurRes(count,:) = [TimDurC+TimDurH TimDurS TimDurO];
    DurTrials(count) = length(Fixs);
    
    clear Fixs;

    
end

return;

