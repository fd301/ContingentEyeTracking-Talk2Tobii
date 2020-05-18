function [where1, latency1] = firstLook2Objects(LookBehD, LookBehT)
% first look to any of the two objects

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
        continue;
    end
    
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
    
    
    
end
