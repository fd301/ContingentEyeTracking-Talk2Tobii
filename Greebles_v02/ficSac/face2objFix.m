function [FixObjR, lenTr ]= face2objFix(LookBehD, LookBehT)
% How many face to object saccades etc
% estimate number of trials

[lenSacResp, trials] = size(LookBehD);

%Duration of how long do they look in each trial at each object
for i=1:trials
    count = 1;
    count2 = 1;
    trialD = [];
    for j=1:lenSacResp
        if( isempty(LookBehD{j,i}) )
            continue;
        end
        trialD(count) = LookBehD{j,i};
        count = count+1;
    end
    lenTr(i) = count-1;
    %ignore nan's -- perhaps these are saccades
    
    LookC = find(trialD==0);            %looking at the central object
    flagC = isempty(LookC);
    if( ~flagC )
        tc = diff(LookC);
        tcf = find(tc>2);
        if( isempty(tcf) ) %there are no gaps
            FixObj(count2,:) = [LookC(1) LookC(end) 0];
            count2 = count2+1;
        else
            init = LookC(1);
            for mm=1:length(tcf)
                fin = LookC( tcf(mm) );
                FixObj(count2,:) = [init fin 0];
                count2 = count2+1;
                init = LookC( tcf(mm)+1 );
            end
            fin = LookC(end);
            FixObj(count2,:) = [init fin 0];
            count2 = count2+1;
        end
    
    end

    LookC1 = find( trialD==1 );         %looking at the central object's hand
    flagC1 = isempty(LookC1);
    if( ~flagC1 )
        tc = diff(LookC1);
        tcf = find(tc>2);
        if( isempty(tcf) ) %there are no gaps
            FixObj(count2,:) = [LookC1(1) LookC1(end) 1];
            count2 = count2+1;
        else
            init = LookC1(1);
            for mm=1:length(tcf)
                fin = LookC1( tcf(mm) );
                FixObj(count2,:) = [init fin 1];
                count2 = count2+1;
                init = LookC1( tcf(mm)+1 );
            end
            fin = LookC1(end);
            FixObj(count2,:) = [init fin 1];
            count2 = count2+1;
        end
    
    end
    
    LookS = find( trialD == 2 );     %looking at the same object
    flagS = isempty(LookS);
    if( ~flagS )
        tc = diff(LookS);
        tcf = find(tc>2);
        if( isempty(tcf) ) %there are no gaps
            FixObj(count2,:) = [LookS(1) LookS(end) 2];
            count2 = count2+1;
        else
            init = LookS(1);
            for mm=1:length(tcf)
                fin = LookS( tcf(mm) );
                FixObj(count2,:) = [init fin 2];
                count2 = count2+1;
                init = LookS( tcf(mm)+1 );
            end
            fin = LookS(end);
            FixObj(count2,:) = [init fin 2];
            count2 = count2+1;
        end
    
    end
    
    LookO = find( trialD == -1 );     %looking opposite object
    flagO = isempty(LookO);
    if( ~flagO )
        tc = diff(LookO);
        tcf = find(tc>2);
        if( isempty(tcf) ) %there are no gaps
            FixObj(count2,:) = [LookO(1) LookO(end) -1];
            count2 = count2+1;
        else
            init = LookO(1);
            for mm=1:length(tcf)
                fin = LookO( tcf(mm) );
                FixObj(count2,:) = [init fin -1];
                count2 = count2+1;
                init = LookO( tcf(mm)+1 );
            end
            fin = LookO(end);
            FixObj(count2,:) = [init fin -1];
            count2 = count2+1;
        end
    
    end
    
    LookE = find( trialD == -2 );       %looking else
    flagE = isempty(LookE);
    if( ~flagE )
        tc = diff(LookE);
        tcf = find(tc>2);
        if( isempty(tcf) ) %there are no gaps
            FixObj(count2,:) = [LookE(1) LookE(end) -2];
            count2 = count2+1;
        else
            init = LookE(1);
            for mm=1:length(tcf)
                fin = LookE( tcf(mm) );
                FixObj(count2,:) = [init fin -2];
                count2 = count2+1;
                init = LookE( tcf(mm)+1 );
            end
            fin = LookE(end);
            FixObj(count2,:) = [init fin -2];
            count2 = count2+1;
        end
    
    end
    
    LookN = find( trialD == 3 );        %eyes have not found
    flagN = isempty(LookN);
    if( ~flagN )
        tc = diff(LookN);
        tcf = find(tc>2);
        if( isempty(tcf) ) %there are no gaps
            FixObj(count2,:) = [LookN(1) LookN(end) 3];
            count2 = count2+1;
        else
            init = LookN(1);
            for mm=1:length(tcf)
                fin = LookN( tcf(mm) );
                FixObj(count2,:) = [init fin 3];
                count2 = count2+1;
                init = LookN( tcf(mm)+1 );
            end
            fin = LookN(end);
            FixObj(count2,:) = [init fin 3];
            count2 = count2+1;
        end
    
    end
    
    [tmp, ind] = sort( FixObj(:,1) );
    FixObjR{i} = FixObj(ind,:);
    FixObj = [];
    
end


