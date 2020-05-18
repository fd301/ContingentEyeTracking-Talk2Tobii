function [dist, pntInt, pntReal ] = distance3DPntFromLine(pnt, pnt1, pnt2);

x = pnt(:,1);
y = pnt(:,2);
z = pnt(:,3);
x1 = pnt1(1);
y1 = pnt1(2);
z1 = pnt1(3);
x2 = pnt2(1);
y2 = pnt2(2);
z2 = pnt2(3);

A = x - x1;
B = y - y1;
Z = z - z1;

C = x2 - x1;
D = y2 - y1;
E = z2 - z1;

dot = A .* C + B .* D + Z .* E;
len_sq = C .* C + D .* D + E .* E;
param = dot ./ len_sq;

xx = x1 + param .* C;
yy = y1 + param .* D;
zz = z1 + param .* E;

pntReal = [xx yy zz];

tmpInd = find(param<0);
xx(tmpInd) = x1;
yy(tmpInd) = y1;
zz(tmpInd) = z1;

tmpInd = find(param>1);
xx(tmpInd) = x2;
yy(tmpInd) = y2;
zz(tmpInd) = z2;

pntInt = [xx yy zz];

dist = sqrt( (x-xx).^2 + (y-yy).^2 + (z-zz).^2 );


