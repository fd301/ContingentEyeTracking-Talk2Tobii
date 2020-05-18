function [TimeLine, EyeTrackingInfo, varargout] = InitEyeEventsForCntrlCond(inputPathEvents, FieldNames, EventNames, subjNo)
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

    %find breaks
    tmpIndB = find(BreaksOut);
    tmpChB = diff( tmpIndB );
    tmpChB = cat( 1, 2, tmpChB );
    tmpEB = find( tmpChB~=1 );
    disp( strcat( 'NumofBreaks:', num2str(length(tmpEB)) ) );

else
    BreaksOut = zeros(length(event_index),1);
end

    
%find differences between fields
lenE = length(event_array_1);
lenF = length(FieldNames{1});
for j=1:lenF
    tmpstr = strcat( 'tmpProF(:,j) = diff(event_array_', num2str(j), '(:,2));' );
    eval(tmpstr);
    tmpIndF{j} = find( tmpProF(:,j)~=0 );
    tmpChF{j} = diff( tmpIndF{j} );
    tmpChF{j} = cat( 1, 2, tmpChF{j} );
    tmpEF{j} = find( tmpChF{j}~=1 );
    %count events
    numEF(j) = length(tmpEF{j});
    %find correspondent time values        
end

disp( strcat('NumofEvents:', num2str(numEF)) );

%define breaks after 
tmpindT = tmpEF{1};
tmpChFT = tmpChF{1};
tmpIndFT = tmpIndF{1};
for i=1:length(tmpindT)-1
    BreaksIndEnd(i) = tmpIndFT(tmpindT(i+1)-1);
end
BreaksIndEnd(i+1) = tmpIndFT(length(tmpChFT));


%plot events
figure;
hold on;
vectInc = 2:lenF-5;
lenFF = length(vectInc);
a = 0.1:3/lenFF:1;
b = 0.9:-3/lenFF:0;
c = zeros( 1, ceil(lenFF/3) );
ColArray = [a' b' c'; b' c' a'; c' a' b'];
countT = 0;
for j=vectInc
    countT = countT+1;
    tmpindT = tmpEF{j};
    tmpChFT = tmpChF{j};
    tmpIndFT = tmpIndF{j};
    for i=1:length(tmpindT)-1
        X = [ TimeLine( event_index( tmpIndFT(tmpindT(i)) ) ) ...
            TimeLine( event_index( tmpIndFT(tmpindT(i+1)-1) ) ) ...
            TimeLine( event_index( tmpIndFT(tmpindT(i+1)-1) ) ) ...
            TimeLine( event_index( tmpIndFT(tmpindT(i)) ) )];
        Y = [j j 0 0];
        tmpf = fill( X, Y, ColArray(countT,:) );
        set( tmpf, 'EdgeColor', ColArray(countT,:) );
        set( tmpf, 'FaceAlpha', 0.7 );
    end
    X = [ TimeLine( event_index( tmpIndFT(tmpindT(end)) ) ) ...
        TimeLine( event_index( tmpIndFT(length(tmpChFT)) ) )...
        TimeLine( event_index( tmpIndFT(length(tmpChFT)) ) )...
        TimeLine( event_index( tmpIndFT(tmpindT(end)) ) ) ];
    Y = [j j 0 0];
    tmpf = fill( X, Y, ColArray(countT,:));
    set( tmpf, 'EdgeColor', ColArray(countT,:) );
    set( tmpf, 'FaceAlpha', 0.7 );
end

%plot breaks if exist
if( exist( 'tmpIndB', 'var' ) )
    for i=1:length(tmpEB)-1
        X = [ TimeLine( event_index( tmpIndB(tmpEB(i)) ) ) ...
            TimeLine( event_index( tmpIndB(tmpEB(i+1)-1) ) ) ...
            TimeLine( event_index( tmpIndB(tmpEB(i+1)-1) ) ) ...
            TimeLine( event_index( tmpIndB(tmpEB(i)) ) )];
        Y = [-0.5 -0.5 0 0];
        tmpf = fill( X, Y, 'r' );
        set( tmpf, 'EdgeColor', 'r' );
        set( tmpf, 'FaceAlpha', 0.7 );
    end
    X = [ TimeLine( event_index( tmpIndB(tmpEB(end)) ) ) ...
        TimeLine( event_index( tmpIndB(length(tmpChB)) ) )...
        TimeLine( event_index( tmpIndB(length(tmpChB)) ) )...
        TimeLine( event_index( tmpIndB(tmpEB(end)) ) ) ];
    Y = [-0.5 -0.5 0 0];
    tmpf = fill( X, Y, 'r');
    set( tmpf, 'EdgeColor', 'r' );
    set( tmpf, 'FaceAlpha', 0.7 );
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
    varargout{lenFields+1}= BreaksIndEnd;
end


