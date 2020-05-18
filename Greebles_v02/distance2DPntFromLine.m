function [dist, pntInt, pntReal ] = distance2DPntFromLine(pnt, pnt1, pnt2)

x = pnt(:,1);
y = pnt(:,2);
x1 = pnt1(1);
y1 = pnt1(2);
x2 = pnt2(1);
y2 = pnt2(2);

A = x - x1;
B = y - y1;

C = x2 - x1;
D = y2 - y1;

dot = A .* C + B .* D;
len_sq = C .* C + D .* D;
param = dot ./ len_sq;

xx = x1 + param .* C;
yy = y1 + param .* D;

pntReal = [xx yy];

tmpInd = find(param<0);
xx(tmpInd) = x1;
yy(tmpInd) = y1;

tmpInd = find(param>1);
xx(tmpInd) = x2;
yy(tmpInd) = y2;

pntInt = [xx yy];

dist = sqrt( (x-xx).^2 + (y-yy).^2 );


