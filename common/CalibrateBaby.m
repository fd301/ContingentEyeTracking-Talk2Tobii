function CalbEvent = CalibrateBaby(win, res, subjNum, Epnts, FixatText, CalibText, LSoundNov, SoundCNov )

lenS = length(SoundCNov);
lenC = length( CalibText );

ESCAPE = KbName('Escape');
Play = KbName('P');

max_wait = 20; 
tim_interv = 0.5;
FLAGforInfants = 1;
if( FLAGforInfants )
    pos = [0.2 0.2;...
        0.8 0.2;
        0.5 0.5;
        0.2 0.8;
        0.8 0.8];
else
    pos = [0.2 0.2;...
        0.5 0.2;
        0.8 0.2;
        0.2 0.5;
        0.5 0.5;
        0.8 0.5;
        0.2 0.8;
        0.5 0.8;
        0.8 0.8];
end
numpoints = length(pos);

ifi = Screen('GetFlipInterval',win,100);

calib_not_suc = 1;
while calib_not_suc

    BreakEvent = FindBabyEyes(win, res, LSoundNov, Epnts, FixatText);
    
    talk2tobii('STOP_TRACKING');
    %% start calibration
    %display stimulus in the four corners of the screen
    totTime = 3;        % swirl total display time during calibration

    talk2tobii('START_CALIBRATION',pos,0,'./calibrFileTest.txt');
    %% It is wrong to try to check the status here because the
    %% eyetracker waits for an 'ADD_CALIBRATION_POINT' and 'DREW_POINT'.

    %check for the three flags first
    %check status of TETAPI
    cond_res = check_status([ 2 4 5], max_wait, tim_interv,[1 1 1]);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        disp(cond_res);
        error('check_status has failed');
    end

    for i=1:numpoints
        position = pos(i,:);
        %            disp(position);
        when0 = GetSecs()+ifi;

        talk2tobii('ADD_CALIBRATION_POINT');
        if( FLAGforInfants )
            k = mod(i,lenS)+1;
            if(k>1)
                Screen('PlayMovie',SoundCNov{k-1},0);
            end
            Screen('SetMovieTimeIndex', SoundCNov{k}, 0 );
            Screen('PlayMovie',SoundCNov{k},1);
            indexC = mod(i,lenC)+1;
            CalibTextTmp = CalibText(indexC);
        end
        StimulusOnsetTime=swirl(win,totTime,ifi,when0,position,1, FLAGforInfants, CalibTextTmp);
        WaitSecs(0.5);
        talk2tobii('DREW_POINT');
    end

    cond_res = check_status(11, 20, 1, 1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed- CALIBRATION');
    end

    %save quality of calibration
    quality = talk2tobii('CALIBRATION_ANALYSIS');
    filenameC = strcat('quality_Calibration_',num2str(subjNum),'.mat');
    indC = 2;
    while ( exist(filenameC,'file') )
        filenameC = strcat('quality_Calibration_',num2str(subjNum),'_',num2str(indC),'.mat');
        indC = indC+1;
    end
    save( filenameC, 'quality' );
    
    %display calibration results
    if(length(quality)>1)
        displayQuality( pos, quality, win, res);
    else
        disp('calibration does not have any data');
    end
    %choose if you want to redo the calibration
    %disp('Press space to resume calibration or q to exit calibration and continue tracking');
    tt= input('press "C" and "ENTER" to resume calibration or any other key to continue\n','s');
    if( strcmpi(tt,'C') )
        calib_not_suc = 1;
    else
        calib_not_suc = 0;
    end

    talk2tobii('START_TRACKING');

end
disp('EndOfCalibration');

%check status of TETAPI
cond_res = check_status(7, max_wait, tim_interv,1);
tmp = find(cond_res==0);
if( ~isempty(tmp) )
    error('check_status has failed');
end

tmpEvent = BreakEvent{1};
CalbEvent{1} = { 'CALIB_START',tmpEvent{2},tmpEvent{3},tmpEvent{4} };
eyeTrack = talk2tobii('GET_SAMPLE');
tmp = GetSecs;
CalbEvent{2} = { 'CALIB_END',eyeTrack(5), eyeTrack(6), tmp };




