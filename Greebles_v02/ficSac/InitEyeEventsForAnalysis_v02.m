function [TimeLine, varargout] = InitEyeEventsForAnalysis_v02(inputPathEvents, inputPathEyeTracking, FieldNames, EventNames, subjNo, FlagDelay);
%
% Written on 21/05/2008 by Fani Deligianni

if(nargin<4)
    EventNames = {'FLIP'};
end

if(nargin<5)
    subjNo = 0;
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

%load eye tracking data
EyeTrackingData = load(inputPathEyeTracking);

%extract time of the samples for each event
lenFields = length(FieldNames);
for j=1:length(EventNames)
    if( strcmpi(EventNames{j},'FLIP') )

        outstr = '[';
        for i=1:lenFields
            event_array = strcat( 'event_array_', num2str(i) );
            if( i==lenFields )
                outstr = sprintf('%s %s] = ExtractPartEvents(Events, FieldNames, EventNames(j));',...
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
                outstr = sprintf('%s %s] = ExtractPartEvents(Events, FieldNames, EventNames(j));',...
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
lenF = length(FieldNames);
for j=1:lenF
    tmpstr = strcat( 'tmpProF(:,j) = diff(event_array_', num2str(j), '(:,2));' );
    eval(tmpstr);
    IndF{j} = find( tmpProF(:,j)~=0 );
end

% check if there are break flags and find their position in time relative to 
% flip events 
if( exist('BREAK_event_array_1','var') && ~isempty(BREAK_event_array_1) )
    TimeLineEvtmp = TimeLine(event_index,1);
    break_index = BREAK_event_array_1(:,1);
    countB = 1;
    for i=1:length(break_index)
        k = break_index(i);
        tmpTime = TimeLine(k,1);
        tmpdist = TimeLineEvtmp - tmpTime;
        [tmpP tmpIS]= min( abs(tmpdist) );
        if( tmpdist(tmpIS)<=0 && tmpIS<length(tmpdist) ) %point of interest is newer
            tt = [tmpIS tmpIS+1 tmpTime tmpTime];
        elseif( tmpdist(tmpIS)>=0 && tmpIS>1 ) %%point of interest is older
            tt = [tmpIS-1 tmpIS tmpTime tmpTime];    
        else
            error('InitEyeEventsForPlayBack: should not have arrived here');
        end
            
        if(i==1)
            BreaksOut(countB,:) = tt; 
            countB = countB+1;
        else
            tmpT = BreaksOut(end,:);
            if(tmpT(1) == tt(1) && tmpT(2) == tt(2) )
                BreaksOut(end,4) = tt(4); 
            else
                BreaksOut(countB,:) = tt; 
                countB = countB+1;
            end
        end
    end
    
    BreaksOut
    
    if( FlagDelay )
        for i=1:countB-1
            BreaksOut(i,2) = BreaksOut(i,2)+1;
            BreaksOut(i,4) = TimeLineEvtmp( BreaksOut(i,2), 1 );
        end
    else
        for i=1:countB-1
            BreaksOut(i,4) = TimeLineEvtmp( BreaksOut(i,2), 1 );
        end
    end
   

else
    BreaksOut = 0;
end



% get rid off of eyetracking data during breaks and outside presentation
% time
% try to synchronise (Start time and EyeTrackingData(1,17) should be identical values)
EventTLine = TimeLine(event_index,1);
EyeTrTLine = EyeTrackingData(:,17);

%discard any tracking data before the first flip:
tmpind = find( EyeTrTLine>=EventTLine(1) );
IndFirstTr =  tmpind(1);
EyeTrackingData = EyeTrackingData( tmpind(1):end, :);
EyeTrTLine = EyeTrackingData(:,17);

%discard breaks
if( length(BreaksOut) ==1 )
    BreaksOut = zeros( length(EyeTrTLine), 1);
else
    BreaksOutN = zeros( length(EyeTrTLine), 1);
    TimLBrkST = BreaksOut(:,3);
    TimLBrkFn = BreaksOut(:,4);
    for i=1:length(TimLBrkST)
        dist = EyeTrTLine - TimLBrkST(i);
        [tmp xx] = min( abs(dist) );
        dist = EyeTrTLine - TimLBrkFn(i);
        [tmp yy] = min( abs(dist) );
        BreaksOutN(xx:yy) = 1;
        StoreIndV(i,:) = [xx yy yy-xx+1];
    end
    %BreaksOut = BreaksOutN;
    
    % newPos are the new break indexes --after removing the breaks
    newPos = zeros( length(TimLBrkST), 1 );
    newPos(1) = StoreIndV(1,1);
    for i=2:length(TimLBrkST)
        newPos(i) = StoreIndV(i,1) - sum( StoreIndV(1:i-1,3) );
    end
end

IndTrWNBr = find(~BreaksOutN);
EyeTrackingData = EyeTrackingData(IndTrWNBr,:);

%find where each event corresponds



%output timeline related to flip events only
TimeLine = TimeLine(event_index,1);


%output data
for i=1:lenFields
    event_array = strcat( 'event_array_', num2str(i) );
    com = sprintf ( 'varargout{i} = event_array_%s;',num2str(i) ); 
    eval(com); 
end


if (nargout>=(1+lenFields+1))
    varargout{lenFields+1}= EyeTrackingData;
end

if (nargout>=(1+lenFields+2))
    varargout{lenFields+2}= newPos;
end

if (nargout>=(1+lenFields+3))
    varargout{lenFields+3}= IndF;
end

if (nargout>=(1+lenFields+4))
    varargout{lenFields+4}= BreaksOut;
end

if (nargout>=(1+lenFields+5))
    varargout{lenFields+5}= IndTrWNBr;
end

if (nargout>=(1+lenFields+6))
    varargout{lenFields+6}= IndFirstTr;
end

