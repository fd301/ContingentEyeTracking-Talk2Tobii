function [TrialRes, TrialRes1, TrialResMean] = EstimateTimDur(LookBehD, LookBehT )



% estimate number of trials
[tmprow, trials] = size(LookBehD);
lenSacResp = length(LookBehT);

%Duration of how long do they look in each trial at each object
for i=1:trials
    count = 1;
    for j=1:lenSacResp
        if( isempty(LookBehD{j,i}) )
            continue;
        end
        trialD(count) = LookBehD{j,i};
        count = count+1;
    end
    
    LookElse = find( trialD == -2 );    %looking else
    if( isempty(LookElse) )
        LookElseN = 0;
    else
        LookElseN = length(LookElse);
    end
    
    LookOpp = find( trialD == -1 );     %looking opposite direction
    if( isempty(LookOpp) )
        LookOppN = 0;
    else
        LookOppN = length(LookOpp);
    end
    
    LookCen = find( trialD == 0 );      %looking to the central object
    if( isempty(LookCen) )
        LookCenN = 0;
    else
        LookCenN = length(LookCen);
    end
    
    LookHand = find( trialD == 1 );     %looking to the rotating hand of the central object
    if( isempty(LookHand) )
        LookHandN = 0;
    else
        LookHandN = length(LookHand);
    end

    LookSame = find( trialD == 1 );     %looking to the same direction
    if( isempty(LookSame) )
        LookSameN = 0;
    else
        LookSameN = length(LookSame);
    end

    EyesNotF = find( trialD == 3 );     %eyes not found
    if( isempty(EyesNotF) )
        EyesNotFN = 0;
    else
        EyesNotFN = length(EyesNotF);
    end
    
    NonDet = find( trialD == 3.5 );     %non specified saccade or fixation
    if( isempty(NonDet) )
        NonDetN = 0;
    else
        NonDetN = length(NonDet);
    end
    
    TrialRes(i,:) = [ count-1 LookSameN LookOppN LookElseN LookCenN LookHandN NonDetN EyesNotFN ];
    clear trialD;
end
for i=1:7
    TrialRes1(:,i) = TrialRes(:,i+1) ./ TrialRes(:,1);
end
TrialResMean = mean(TrialRes1, 1);

