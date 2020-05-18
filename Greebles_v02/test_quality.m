%test display quality
clear all;
close all;

load('quality_Calibration_300.mat');

[win , winRect] = Screen('OpenWindow', 0 );
try
    points = [0.2 0.2;...
        0.8 0.2;
        0.5 0.5;
        0.2 0.8;
        0.8 0.8];
    res = winRect(3:4);
    displayQuality( points, quality, win, res );

    pause;

    Screen('CloseAll');
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);

end
