function [StartTime TimeLine Events] = ReadEvents( inputpath )
% [TimeLine Events Details] = ReadEvents( inputpath )
% 
% This function reads a text file with the Events from an eye tracking
% experiment and stores them the time informaiton in the TimeLine Array and
% the rest of the information, including the name of the event in a array
% of structures: Events
% Empty lines and lines starting with '#' are ignored.
%
% inputpath -> filename of a text file that contains the event fields
% stored during eyetracking
%
% TimeLine -> An n-by-2 array that contain the time information (timestamp1
% in msec, duration ). n are the number of events.
%
% Events -> A structure that contains the NAME of the event and the rest
% fields are stored in a cell called DETAILS
% 
% Written on 07/06/2007 by Fani Deligianni


fid = fopen(inputpath, 'r');

StartTime(1) = -1;

row = 0;
ind = 1;
countS = 1; %count start times
while ( feof(fid) == 0 )
    row = row +1;
    
    if( mod(row,5000)==0 )
        disp( strcat('ReadEvents-Line: ',num2str(row) ) );
    end

    %read next line
    tline = fgetl(fid);
    %ignore lines starting with '##'
    if( isempty(tline) || strcmp(tline(1:2),'##') ) 
        continue;
    end
    
    if( strcmp(tline(1),'#') ) 
        if(strcmp(tline(1:6),'#START') )
            StartTimetmp = strtok(tline(8:end));
            StartTime(countS) = str2double(StartTimetmp);
            countS = countS+1;
            continue;
        else
            continue;
        end
    end

    %read name of event
    rem = tline;
    [tok,rem] = strtok(rem);
    if( isempty(tok) )
        continue;       
    end
    Events(ind).Name = tok;

    %read two fields of timestamp
    [tok,rem] = strtok(rem);
    time1 = str2num(tok);
    if( isempty(time1) )
        fprintf('Error in line %d: time stamp1 not found. \n',row);
        error('File Format is wrong');
    end
    
    [tok,rem] = strtok(rem);
    duration = str2num(tok);
    if( isempty(duration) )
        fprintf('Error in line %d: duration not found. \n',row);
        error('File Format is wrong');
    end
    
    TimeLine(ind,:) = [time1 duration];
    
    
    count1 = 1;
    details = {};
    while(~isempty(rem))
        [tok,rem] = strtok(rem);
        if( isempty(tok) )
            continue;
        end
        details{count1} = tok;
        count1 = count1+1;
    end
    Events(ind).Details = details;
    
    test = mod(length(details),2);
    if(test)
        warning('Count of event detail are not even!');
    end
    
    ind = ind+1;
    

end

fclose(fid);

