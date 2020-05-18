function StimulusOnsetTime=swirl(win,totTime,ifi,when0,position,flagTobii, FLAGforInfants, CalibText)
% StimulusOnsetTime=swirl(win,totTime,ifi,when0,position,flagTobii)
% This function draws a swirly pattern
% win is the window handle returned from psyhctoolbox when it iniatialises
% the screen context that it draws in
% totTime is the time in seconds that the swirling pattern lasts
% ifi is the time returned by the Screen('GetFlipInterval') command
% when0 is the time to start displaying the swirly pattern
% position is the x, y screen coordinates of where to centre the swirly
% pattern
% flagTobii is used to decide whether to use on-line feedback about
% eyetracking data
% FLAGforInfants -> friendlier for infants

if(nargin<7)
    FLAGforInfants = 0;
end

rand('state',sum(100*clock));
pos = position;

rect=Screen('Rect',win);
cx = pos(1)*rect(3);
cy = pos(2)*rect(4);

global BACKCOLOR;
BACKCOLOR = [0 0 0];


dt = totTime/100;

decr = 3;
sides=floor(rand*3)+3;
color=round(rand(3,1)*255);
color(floor(rand*3)+1)=255;
dir=floor(rand*2)*2-1;
ainc=dir*2*pi*0.016;
angle=2*pi*rand;
size=200;

time01 = 0;
time02 = 0;

when = when0;
Screen('TextSize', win,20);
boundsText = Screen('TextBounds', win, '*');
for i=1:100
    if( FLAGforInfants )
        FixDestRect = [cx-size/2 cy-size/2 cx+size/2 cy+size/2];
        Screen('DrawTexture', win, CalibText, [], FixDestRect, angle );

        if(size-decr*2<=0)
            InDFlag = 1;
        end            
        if(size+decr*2>60)
            InDFlag = 0;
        end

        switch InDFlag
            case 0
                size=size-decr*2;
            case 1
                size=size+decr*2;
            otherwise
                error('swirl: I should not have arrive here');
        end
        angle=angle+20*ainc;

    else
        RegPoly(win,sides,size,angle,color,cx,cy);
        size=round(size-decr);
        angle=angle+ainc;
    end
    Screen('DrawingFinished',win);
    %check validity field - if possible
    %if eyes not found then display message
    if(flagTobii)
        sampleTobii = talk2tobii('GETSAMPLE');
        valL = sampleTobii(7);
        valR = sampleTobii(8);

        difTime1 = sampleTobii(5)-time01;
        difTime2 = sampleTobii(6)-time02;
        time01 = sampleTobii(5);
        time02 = sampleTobii(6);
        
%         Screen('TextSize', win,20);
%         Screen('DrawText', win, '*',cx-boundsText(3)/2,cy-boundsText(4)/2,[255 255 250]);
% DEBUG        
%         if(difTime1 ~=0 || difTime2 ~=0 )
%             Screen('TextSize', win,10);
%             Screen('DrawText', win, 'NewSample!',cx,cy,[255 255 250]);
%         else
%             Screen('TextSize', win,10);
%             Screen('DrawText', win, 'NO SAMPLE!',cx,cy,[255 255 250]);
%         end
%         
%         if(valR>0 & valL>0)
%             Screen('TextSize', win,10);
%             Screen('DrawText', win, 'Eyes Not Found!',cx,cy+20,[255 250 250]);
%         elseif(valR==-1 || valL==-1)
%             Screen('TextSize', win,10);
%             Screen('DrawText', win, 'Sample have not been acquired!',cx,cy+20,[255 250 250]);
%         end
    end
    [now StimulusOnsetTime FlipTimestamp Missed Beampos]= Screen('Flip',win, when);
    when = StimulusOnsetTime+dt-ifi;    
end

return


%%
function RegPoly(win,sides,size,angle,color,cx,cy)

%cx=rect(3)/2;
%cy=rect(4)/2;
for i=1:sides
    vert(i,1)=cx+size*cos(angle+2*pi*(i-1)/sides);
    vert(i,2)=cy+size*sin(angle+2*pi*(i-1)/sides);
end
Screen('FillPoly', win, color, vert);
return
