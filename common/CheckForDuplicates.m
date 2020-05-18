function [TimeLineN EventsN] = CheckForDuplicates(TimeLine,Events)
%delete duplicates

len1 = length(TimeLine);
len2 = length(Events);

if( len1~=len2 )
    error('CheckForDuplicates has failed because length of TimeLine is different than Events');
end

count = 1;
i = 0;
while(i<len1)
    i = i+1;
    tmpEvents = Events(i);
    TimeLineN(count,:) = TimeLine(i,:);
    EventsN(count) = tmpEvents;
    count = count+1;
    
    if( mod(i,2000)==0 )
        disp( strcat('CheckForDuplicates-Line: ',num2str(i)) );
    end

    for j=i+1:len1
        tmplen1 = length( tmpEvents.Details );
        tmplen2 = length( Events(j).Details );

        if(tmplen1 == tmplen2 )
            tmp = strcmp( tmpEvents.Details, Events(j).Details );
            tmpind = find(tmp==0);
            if( isempty(tmpind) && strcmp( tmpEvents.Name, Events(j).Name ) )
                %exclude this sample
                i = i+1;
            else
                break;
            end

        else
            break;
        end
    end

end


