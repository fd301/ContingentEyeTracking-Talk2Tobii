function [where1, latency1,durTimSac, FinRes] = firstLook2Objs(LookBehD, LookBehT)
% first look to any of the two objects
% how long first saccade lasted

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
   
    NonZ = find( trialD );
    if( isempty(NonZ) ) %baby always look at the centre!!
        warning(strcat( 'trial:',num2str(i),'-- baby was looking to the centre!') );
        where1(i) = 0;
        latency1(i) = nan;
        durTimSac(i) = nan;
        continue;
    end
    
    numSamples = count-1;
    
    LookSame = find( trialD == 2 ); %looking at the same object
    flagS = isempty(LookSame);
    if( ~flagS )
        LookSameF = LookSame(1);
    end
    
    LookOpp = find( trialD == -1 ); %looking opposite object
    flagO = isempty(LookOpp);
    if( ~flagO  )
        LookOppF = LookOpp(1);
    end
    
    if( ~flagS && flagO ) %looked only the same object
        where1(i) = 2;
        latency1(i) = LookSame(1)/numSamples;
        tmpD = diff(LookSame);
        tt = find(tmpD>1);
        if( ~isempty(tt) )
           durTimSac(i) = ( LookSame(tt(1)+1) - LookSame(1) ) / numSamples; 
        else
            durTimSac(i) = ( LookSame(end) - LookSame(1) ) / numSamples;
        end
    elseif( flagS && ~flagO ) %looked only opposite object
        where1(i) = -1;
        latency1(i) = LookOpp(1)/numSamples;        
        tmpD = diff(LookOpp);
        tt = find(tmpD>1);
        if( ~isempty(tt) )
           durTimSac(i) = ( LookOpp(tt(1)+1) - LookOpp(1) ) / numSamples; 
        else
            durTimSac(i) = ( LookOpp(end) - LookOpp(1) ) / numSamples;
        end
    elseif( ~flagS && ~flagO ) %looked both objects
        if( LookSame(1) < LookOpp(1) ) %looked the same first
            where1(i) = 2;
            latency1(i) = LookSame(1)/numSamples;
            tmpD = diff(LookSame);
            tt = find(tmpD>1);
            if( ~isempty(tt) )
                durTimSac(i) = ( LookSame(tt(1)+1) - LookSame(1) ) / numSamples;
            else
                durTimSac(i) = ( LookSame(end) - LookSame(1) ) / numSamples;
            end
        else %looked the opposite first
            where1(i) = -1;
            latency1(i) = LookOpp(1)/numSamples;
            tmpD = diff(LookOpp);
            tt = find(tmpD>1);
            if( ~isempty(tt) )
                durTimSac(i) = ( LookOpp(tt(1)+1) - LookOpp(1) ) / numSamples;
            else
                durTimSac(i) = ( LookOpp(end) - LookOpp(1) ) / numSamples;
            end
        end
    else % it hasn't looked any of the objects??
        warning(strcat( 'trial:',num2str(i),'-- baby has not looked any of the objects!') );
        where1(i) = -2;
        latency1(i) = nan;
        durTimSac(i) = nan;
    end
    
end

% cound how many times they looked the same and how many time they looked
% the opposite
countS = 0;
countO = 0;
countC = 0;
countE = 0;
latS = 0;
latO = 0;
durTS = 0;
durTO = 0;
for i=1:length(where1)
    
    if( where1(i) == 2 )
        countS = countS+1;
        latS = latS+latency1(i);
        durTS = durTS + durTimSac(i);
    elseif( where1(i) == -1 )
        countO = countO+1;
        latO = latO+latency1(i);
        durTO = durTO + durTimSac(i);
    elseif( where1(i) == 0 )
        countC = countC+1;
    else
        countE = countE+1;
    end
    
end

if( countS )
    latS = latS/countS;
    durTS = durTS/countS;
end
if( countO )
    latO = latO/countO;
    durTO = durTO/countO;
end
FinRes = [countS countO countC countE latS latO durTS durTO];

return;
