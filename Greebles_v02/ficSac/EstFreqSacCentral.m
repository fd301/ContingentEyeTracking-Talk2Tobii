function [FreqSacC, SacNumC] = EstFreqSacCentral( SacLookBeh )

%estimate number of fixations at central object

trials = length(SacLookBeh);

for i=1:trials
%     val = Valid(i);
%     if( ~val)
%         continue;
%     end
    
    Sacs = SacLookBeh{i};
    
    if( isempty(Sacs) )
        SacNumC(i) = 0;
        continue;
    end
    
    if( i == 18 )
       tt = 18;
    end
    
    %look the central object
    LookE = find( Sacs(:,1) ~= 0 );
    LookC = find( Sacs(:,2) == 0 );    
        
    if( isempty(LookE) || isempty(LookC) )
        SacNumSt = 0;
    else
        
        len = length(Sacs);
        tmpE = zeros(1,len);
        tmpC = zeros(1,len);
        tmpE(LookE) = 1;
        tmpC(LookC) = 1;
        
        tmpS2C = tmpE & tmpC;
        
        SacNumSt = length( find(tmpS2C) );
                
        
    end

    SacNumC(i) = SacNumSt;
            
end

FreqSacC = mean(SacNumC);


return;