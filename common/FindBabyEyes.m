function BreakEvent = FindBabyEyes(win, res, LSoundNov, tmpEpnts, tmpFixatText)

ESCAPE = KbName('Escape');
Play = KbName('P');

max_wait = 20; 
tim_interv = 0.5;

%check status of TETAPI - START_TRACKING should be on
cond_res = check_status(7, max_wait, tim_interv,1);
tmp = find(cond_res==0);
if( ~isempty(tmp) )
    error('check_status has failed');
end


Screen('SetMovieTimeIndex', LSoundNov{1}, 0 );
Screen('PlayMovie',LSoundNov{1},1);
disp('Click Escape to continue or type P to start music again');

flagNotBreak = 0;
countBreak = 1;
while ~flagNotBreak
    eyeTrack = talk2tobii('GET_SAMPLE');
    BreakEvent{countBreak} = { 'BREAK', eyeTrack(5), eyeTrack(6), GetSecs };
    countBreak = countBreak+1;

    DrawEyes(win, res, eyeTrack(9), eyeTrack(10), eyeTrack(11), eyeTrack(12), eyeTrack(8), eyeTrack(7), 1, tmpEpnts, tmpFixatText );

    [KeyIsDown, endrt, KeyCode] = KbCheck;
    if( KeyIsDown==1 && KeyCode(ESCAPE)==1 )
        flagNotBreak = 1;
        if( flagNotBreak )
            break;
        end
    end
    if( KeyIsDown==1 && KeyCode(Play)==1 ) % rewind movie and play again
        Screen('SetMovieTimeIndex', LSoundNov{1}, 0 );
        Screen('PlayMovie',LSoundNov{1},1);
    end
end

Screen('PlayMovie',LSoundNov{1},0);


