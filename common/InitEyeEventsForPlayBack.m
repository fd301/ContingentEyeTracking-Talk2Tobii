function [TimeLine, EyeTrackingInfo, varargout] = InitEyeEventsForPlayBack(inputPathEvents, inputPathEyeTracking, FieldNames, EventNames, subjNo);
%
% Written on 12/09/2007 by Fani Deligianni

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

%create a unified time number
EyeSamplesTime = EyeEventSec(:,2) + EyeEventMsec(:,2)/1000000;
EyeTrackingTime = EyeTrackingData(:,1) + EyeTrackingData(:,2)/1000000;

% try to synchronise
EventTLine = TimeLine(event_index,1)  - StartTime;
EyeTrTLine = EyeTrackingTime - EyeTrackingTime(1);
%EyeTrTLine = EyeTrackingData(:,17) - EyeTrackingData(1,17);

lenS = length(EyeSamplesTime);
lenT = length(EyeTrTLine);
for i=1:lenS
    if( mod(i-1,500)==0 )
        disp(lenS-i);
    end
    tmpTime = EyeTrackingTime - EyeSamplesTime(i);
    tind = find (abs(tmpTime)<0.000001);
    if( isempty(tind) )
        error('InitEyeEventsForPlayBack: There is no match between EyeTracking Data and Eye Samples. Check input files');
    end
    
    if( length(tind)>1 )
        error('InitEyeEventsForPlayBack: There are multiple matches between EyeTracking Data and Eye Samples. Check input files');
    end
    
    EyeTrackingInfo(i,:) = [EyeTrackingData(tind,3:6) EyeTrackingData(tind,1:2) EyeTrackingData(tind,11:12) EyeTrackingData(tind,7:10)]; 
    IndexSamples(i) = tind;
    
    %find index sample for each flip
    tmpTime = EyeTrTLine - EventTLine(i);
    [mtind2 tind2] = min( abs(tmpTime) );
    SynchSamples(i,:) = [tind2 mtind2];
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
            tt = [tmpIS tmpIS+1];
        elseif( tmpdist(tmpIS)>=0 && tmpIS>1 ) %%point of interest is older
            tt = [tmpIS-1 tmpIS];    
        else
            error('InitEyeEventsForPlayBack: should not have arrived here');
        end
            
        if(i==1)
            BreaksOut(countB,:) = tt; 
            countB = countB+1;
        else
            tmpT = BreaksOut(end,:);
            if(tmpT(1) ~= tt(1) || tmpT(2) ~= tt(2) )
                BreaksOut(countB,:) = tt; 
                countB = countB+1;
            end
        end
    end
    BreaksOutN = zeros(length(event_index),1);
    BreaksOutN( BreaksOut(:,1),1 ) = 1;
    BreaksOut = BreaksOutN;

else
    BreaksOut = zeros(event_index,1);
end

if( exist('CALIB_START_event_array_1','var') && ~isempty(CALIB_START_event_array_1) && exist('CALIB_END_event_array_1','var') && ~isempty(CALIB_END_event_array_1) )
    TimeLineEvtmp = TimeLine(event_index,1);
    calIndSt = CALIB_START_event_array_1(:,1);
    calIndEn = CALIB_END_event_array_1(:,1);
    CalBreaks = zeros( length(event_index), 1 );
    for i=1:length(calIndSt)
        k = calIndSt(i);
        tmpTime = TimeLine(k,1);
        tmpdist = TimeLineEvtmp - tmpTime;
        [tmpP tmpIS]= min( abs(tmpdist) );
        
        k2 = calIndEn(i);
        tmpTime = TimeLine(k2,1);
        tmpdist = TimeLineEvtmp - tmpTime;
        [tmpP2 tmpIS2]= min( abs(tmpdist) );
        
        CalBreaks(tmpIS:tmpIS2) = 1;        
    end    
    
else
    CalBreaks = zeros( length(event_index), 1 );
end

%output timeline related to flip events only
TimeLine = TimeLine(event_index,1);


%output data
for i=1:lenFields
    event_array = strcat( 'event_array_', num2str(i) );
    com = sprintf ( 'varargout{i} = event_array_%s;',num2str(i) ); 
    eval(com); 
end

if (nargout>(2+lenFields))
    varargout{lenFields+1}= IndexSamples;
end

if (nargout>(2+lenFields+1))
    varargout{lenFields+2}= SynchSamples;
end

if (nargout>(2+lenFields+2))
    varargout{lenFields+3}= EyeTrackingData;
end

if (nargout>(2+lenFields+3))
    varargout{lenFields+4}= BreaksOut;
end

if (nargout>(2+lenFields+4))
    varargout{lenFields+5}= CalBreaks;
end
% figure;
% plot( SynchSamples(:,1) ,ones(length(EyeSamplesTime),1)+0.05, '.r' );
% hold on;
% plot( SynchSamples(:,1) ,ones(length(EyeSamplesTime),1)-0.05, '.r' );
% plot( SynchSamples(:,1) ,ones(length(EyeSamplesTime),1)+0.001, '.r' );
% plot( IndexSamples,ones(length(EyeSamplesTime),1), '.g' );
% for i=1:lenS-1
%     plot([IndexSamples(i) IndexSamples(i+1)], [1 1.001],'k');
% end

