function [ trial, trialM ] = EstimateLookElseTim_v01( LookBehDF, Valid )
%find CO->ELSE->CO measure time else


trials = length(LookBehDF);
Valid = cat(2,1, Valid );

count = 0;
for i=1:trials
    val = Valid(i);
    if( ~val)
        continue;
    end
    count = count+1;
        
    FixS = LookBehDF{i};
    trialLen = length(FixS);
    
    %Looking the central Obj
    Central = find( FixS == 0 );    
    if(  isempty(Central) ) %baby hasn't look central object        
        continue;    %continue to next trial
    end
    
   gaps = find(diff(Central)>1);
   if( isempty(gaps) ) %there are no gaps
       continue; %looked the central only
   end
   
   %check what the gaps consists of
   lenG = length(gaps);
   countN = 1;
   NumLookE = [];
   for j=1:lenG
       g = gaps(j);
       
       bord1 = Central(g)+1;
       bord2 = Central(g+1)-1;
       
       FV = FixS(bord1:bord2);
       len = length(bord1:bord2);
       tmp1 = find(FV==3.5);
       if( ~isempty(tmp1) )
           tmpL1 = length(tmp1);
           if( tmpL1==len ) %continue
               continue;
           end
       else
           tmpL1 = 0;
       end
       
       tmp2 = find(FV==3);
       if( ~isempty(tmp2) )
           tmpL2 = length(tmp2);
           if( tmpL2>2 )
               %eyes not found
               %don't count this interval
               continue;
           end
       else
           tmpL2 = 0;
       end
       
       %gap is because baby looked somewhere else:
       %count interval
       NumLookE(countN) =( len-tmpL1-tmpL2);
       countN = countN+1;
   end
   
   if( ~isempty(NumLookE) )
       trialM(count) = mean(NumLookE);
   else
       trialM(count) = -1;
   end
   
   trial{count} = NumLookE;
       
end

return;

