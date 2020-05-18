function [FreqFixN,FixNumS] = EstFreqFixCentral( FixObjR, Valid, lenTr )

%estimate number of fixations at central object

trials = length(FixObjR);

for i=1:trials
%     val = Valid(i);
%     if( ~val)
%         continue;
%     end
    
    Fixs = FixObjR{i};
    
    %find saccades and replace
    Sacs = find(Fixs ~= 3.5);
    Fixs = Fixs(Sacs);
%     if( ~isempty(Sacs) )
%         
%         for j=1:length(Sacs)
%             count = 1;
%             tmp = Fixs( Sacs(j)-count );
%             while( tmp == 3.5  )
%                 tmp = Fixs( Sacs(j) - count );
%                 count = count+1;
%             end
%             ReplaceL(j) = tmp;
%         end
%         
%         Fixs(Sacs) = ReplaceL;
%     end
    
    %look the central object
    LookC = find( Fixs == 0 );    
    
    if( isempty(LookC) )
        FixNumSt = 0;
    else
        
        Sd = diff(LookC);
        tmp = find(Sd>1);
        if( isempty(tmp) )
            FixNumSt = 1;
        else
            FixNumSt = length(tmp)+1;
        end
        
    end

    FixNumS(i) = FixNumSt;
   
%     if( exist('ReplaceL','var') )
%         clear ReplaceL;
%     end
            
end

FreqFixN = mean(FixNumS);


return;