function displayQuality( points, quality, win, res )

%left eye -- data used for calibration
Lindex = find( quality(:,5)==1 );

%right eye -- data used fro calibration
Rindex = find( quality(:,8)==1 );


Lm = min(res);
La = 40;
Lb = Lm/2-La;

LRect = [La La Lb Lb];

Ra = La + res(1)/2;
Rb = Ra + (Lm/2-2*La);
RRect = [Ra La Rb La+(Rb-Ra)];


Screen('FrameRect', win, [0 0 255], LRect, 5);

Screen('FrameRect', win, [0 0 255], RRect, 5);

LCPnts = points .* (Lb-La);
Screen('DrawDots', win, LCPnts', 2, [0 255 0], [La La]);

RCPnts = points .* (Rb-Ra);
Screen('DrawDots', win, RCPnts', 2, [0 255 0], [Ra La]);

%Draw lines
if( ~isempty(Lindex) )
    for i=1:length(Lindex)
        k = Lindex(i);
        Screen('DrawLines', win, [quality(k,1) quality(k,2); quality(k,3) quality(k,4)]'.* (Lb-La),  [], [255 0 0],  [La La] );
    end
end

if( ~isempty(Rindex) )
    for i=1:length(Rindex)
        k = Rindex(i);
        Screen('DrawLines', win, [quality(k,1) quality(k,2); quality(k,6) quality(k,7)]'.* (Lb-La),  [], [255 0 0],  [Ra La] );
    end
end

Screen('FLIP',win);

