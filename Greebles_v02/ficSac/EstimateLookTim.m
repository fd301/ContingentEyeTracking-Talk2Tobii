function [FirstEN, TotTimResN,FirstE, TimDurRes] = EstimateLookTim( FixObjR, Valid, lenTr )

trials = length(lenTr);

TrNumV = 1;
for i=1:trials
    val = Valid(i);
    if( ~val)
        continue;
    end
    
    Fixs = FixObjR{i};
    TimDurS = 0;
    TimDurO = 0;
    FirstS = 0;
    FirstO = 0;
    %Looking the same Obj
    Same = find( Fixs(:,3) == 2 );    
    if( ~isempty(Same) )        
        for j=1:length(Same)
            TimDurS = TimDurS + Fixs( Same(j),2 ) - Fixs( Same(j),1 ) + 1;
        end
        
        FirstS = Same(1);        
    end
    
    Opp = find( Fixs(:,3) == -1 );
    if( ~isempty(Opp) )        
        for j=1:length(Opp)
            TimDurO = TimDurO + Fixs( Opp(j),2 ) - Fixs( Opp(j),1 ) + 1;
        end
        
        FirstO = Opp(1);        
    end
    
    if( TimDurS || TimDurO )
        TimDurRes(TrNumV,:) = [ TimDurS TimDurO ];
        
        if( FirstO && FirstS )
            [mm, Indm] = min([FirstS FirstO]);
            if( Indm == 1 )
                FirstE(TrNumV,:) = [1 0];
            else
                FirstE(TrNumV,:) = [0 1];
            end
        elseif( FirstO )
            FirstE(TrNumV,:) = [0 1];
        elseif( FirstS )
            FirstE(TrNumV,:) = [1 0];
        else
            error('EstimateLookTim: Unknown error.');
        end
        
        TrNumV = TrNumV+1;
        
    end
    
end

TotTim = TimDurRes(:,1)+TimDurRes(:,2);
TotTimRes = [ TimDurRes(:,1)./TotTim TimDurRes(:,2)./TotTim ];
TotTimResN = mean(TotTimRes,1); %mean looking time persentage for each trial
FirstEN = sum(FirstE,1);

return;