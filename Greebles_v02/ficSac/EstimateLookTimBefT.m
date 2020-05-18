function [TimDurRes, DurTrials] = EstimateLookTimBefT( FixObjR, Valid, lenTr )

trials = length(lenTr);

count = 0;
for i=1:trials
%     val = Valid(i);
%     if( ~val)
%         continue;
%     end
    count = count+1;
    
    Fixs = FixObjR{i};
    TimDurS = 0;
    TimDurO = 0;
    TimDurC = 0;
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
    
    
    TimDurRes(count,:) = [TimDurC TimDurS TimDurO];
    DurTrials(count) = length(Fixs);

    
end

return;

