function varargout = ExtractPartEvents(Events, FieldNames, EventNames)
% varargout = ExtractPartEvents(Events, FieldNames)
%
% This function extract the values of particular events tagged with the
% FieldNames
% Events is the output of the function ReadEvents
% FieldNames is a cell with the names of the events that will be extracted
%
% Written on 11/09/2007 by Fani Deligianni

len = length(FieldNames);

if( nargin>2 ) % to choose which name events you would like to access
    lenEN = length(EventNames);
    flag = 0;
else %if no events are specified extract all available information
    lenEN = 0;
    flag = 1;
end

for k=1:len

    count = 1;
    numValue = [];
    for i=1:length(Events)
        %check event name
        eventN = Events(i).Name;
        
        for mm=1:lenEN
            if( strcmpi(eventN,EventNames{mm}) )
                flag = 1;
                break;
            else
                flag = 0;
            end
        end
        
        if( ~flag )
            continue;
        end
        
        event = Events(i).Details;
        numFields = length( event );

        for j=1:numFields/2

            if( strcmpi( event{2*j-1}, FieldNames{k} ) )
                numValue(count,:) = [i str2num( event{2*j} )];
                count = count+1;
                continue;
            end
            
        end

    end
    
    varargout{k} = numValue; 

end

