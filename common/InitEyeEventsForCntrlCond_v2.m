function [TimeLine, varargout] = InitEyeEventsForCntrlCond_v2(inputPathEvents, FieldNames, EventNames, subjNo)
%
% Written on 27/04/2008 by Fani Deligianni

if(nargin<3)
    EventNames = {'FLIP'};
end

if(nargin<4)
    subjNo = 0;
    warning('subject number assumed 0.');
end

flagNoDuplicates = 1;

%load events either from a pre-processed mat file or directly from the txt
%file
filename = fullfile( pwd, strcat('eventsP_',num2str(subjNo),'.mat' ) );

if( exist(filename,'file') )
    load(filename);
    Events = EventsN;
    TimeLine = TimeLineN;
    disp('InitEyeEventsForPlayBack: events loaded from mat file.');
else
    disp('InitEyeEventsForPlayBack: .mat events file does not exist.');
    disp('Events will be loaded from text file... usually takes several minutes');

    %load events
    [StartTime TimeLine Events] = ReadEvents( inputPathEvents );

    %check for duplicates
    if( flagNoDuplicates )
        [TimeLineN EventsN] = CheckForDuplicates(TimeLine,Events);
        
        %save event-loaded data to a file so next time is quicker to load
        save( filename, 'StartTime', 'TimeLineN', 'EventsN');
        Events = EventsN;
        TimeLine = TimeLineN;
    end
end

%extract time of the samples for each event
for j=1:length(EventNames)
    tmpFieldNames = FieldNames{j};
    lenFields = length(tmpFieldNames);

    if( strcmpi(EventNames{j},'FLIP') )

        outstr = '[';
        for i=1:lenFields
            event_array = strcat( 'event_array_', num2str(i) );
            if( i==lenFields )
                outstr = sprintf('%s %s] = ExtractPartEvents(Events, tmpFieldNames, EventNames(j));',...
                    outstr, event_array);
            else
                outstr = sprintf('%s %s,',outstr, event_array);
            end
        end

        eval(outstr);
        
    else
        
        outstr = '[';
        for i=1:lenFields
            event_array = strcat( EventNames{j},'_event_array_', num2str(i) );
            if( i==lenFields )
                outstr = sprintf('%s %s] = ExtractPartEvents(Events, tmpFieldNames, EventNames(j));',...
                    outstr, event_array);
            else
                outstr = sprintf('%s %s,',outstr, event_array);
            end
        end

        eval(outstr);
    end
end

%assume that the first two output vectors correspond to; 'EyeEventSec' and
%'EyeEventMsec'
EyeEventSec = event_array_1;
EyeEventMsec = event_array_2;
event_index = event_array_1(:,1);
    
%find differences between fields
lenE = length(event_array_1);
lenF = length(FieldNames{1});
for j=1:lenF
    tmpstr = strcat( 'tmpProF(:,j) = diff(event_array_', num2str(j), '(:,2));' );
    eval(tmpstr);
    IndF{j} = find( tmpProF(:,j)~=0 );
    tmpChF{j} = diff( IndF{j} );
    tmpChF{j} = cat( 1, 2, tmpChF{j} );
    tmpEF{j} = find( tmpChF{j}~=1 );
    %count events
    numEF(j) = length(tmpEF{j});

    %define breaks after
    tmpindT = tmpEF{j};
    tmpChFT = tmpChF{j};
    tmpIndFT = IndF{j};
    for i=1:length(tmpindT)-1
        BreaksInd(i,2*j-1:j*2) = [tmpIndFT(tmpindT(i)) tmpIndFT(tmpindT(i+1)-1)];
    end
    if(length(tmpindT)==1)
        i=0;
    end
    %if a field remains constant thought out the experiment
    if( isempty( IndF{j} ) )
        BreaksInd(i+1,2*j-1:j*2) = [1 1];
    else
        BreaksInd(i+1,2*j-1:j*2) = [tmpIndFT(tmpindT(i+1)) tmpIndFT(length(tmpChFT))];
    end
end

disp( strcat('NumofEvents:', num2str(numEF)) );


%output timeline related to flip events only
TimeLine = TimeLine(event_index,1);


%output data
for i=1:lenFields
    event_array = strcat( 'event_array_', num2str(i) );
    com = sprintf ( 'varargout{i} = event_array_%s;',num2str(i) ); 
    eval(com); 
end

if (nargout>(1+lenFields))
    varargout{lenFields+1} = BreaksInd;
end

if (nargout>(2+lenFields))
    varargout{lenFields+2} = numEF;
end
if(nargout>(3+lenFields))
    varargout{lenFields+3} = IndF;
end

