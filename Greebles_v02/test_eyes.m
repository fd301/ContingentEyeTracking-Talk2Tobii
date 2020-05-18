clear all
close all;
%hostName = '169.254.6.97'; %T120
hostName = '193.61.45.213'; %1750
port = 4455;
max_wait = 20;
tim_interv = 0.5;

GetSecs

[win , winRect] = Screen('OpenWindow', 1, 0 );

talk2tobii('CONNECT',hostName, port);

%check status of TETAPI
cond_res = check_status(2, max_wait, tim_interv,1);
tmp = find(cond_res==0);
if( ~isempty(tmp) )
    error('check_status has failed');
end


talk2tobii('START_TRACKING');
pause(1);

%check status of TETAPI
cond_res = check_status(7, max_wait, tim_interv,1);
tmp = find(cond_res==0);
if( ~isempty(tmp) )
    error('check_status has failed');
end
pause(1);

for i=1:20000
    h1(i) = GetSecs;
    eyeTrack(i,:) = talk2tobii('GET_SAMPLE');
    h2(i) = GetSecs;
    if( mod(i,1000)==0 )
        pause(0.1);
        disp(i);
    end
end



talk2tobii('STOP_TRACKING');
talk2tobii('DISCONNECT');

clear Screen;