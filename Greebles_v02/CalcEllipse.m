function pnts = CalcEllipse( C, a, b, pnt1, pnt2, steps, flag  )
% C -> centre
% a -> semimajor axis
% b -> semiminor axis
% pnt1, pnt2 -> foci points: angle should be defined based on these points
% steps -> number of points


if(nargin<7)
    flag = 0;
end

x = C(1);
y = C(2);

%estimate angle
dx = abs( pnt1(1)-pnt2(1) );
dy = abs( pnt1(2)-pnt2(2) );
if( dx < 10)
    angle = 90;
elseif (dy < 10)
    angle = 0;
else
    dd = dy/dx;
    angle = atan(dd); %angle in radians
    angle = angle * 180/pi; %angle in degrees
end

if(flag)
    angle = angle + 90;
end

beta = -angle / (180 *pi);
sinbeta = sin(beta);
cosbeta = cos(beta);

count = 1;
for i=0:360/steps:360
    alpha = i / 180 * pi;
    sinalpha = sin(alpha);
    cosalpha = cos(alpha);

    X(count) = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
    Y(count) = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);
    count = count+1;
end

pnts = [X' Y'];


