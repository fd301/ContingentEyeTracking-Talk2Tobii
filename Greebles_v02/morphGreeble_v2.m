function greeble2 = morphGreeble_v2(greeble,DIF);

% clear all;
% close all;
% 
% DIF = 1.0;
% 
% file1 = './m1_12_a.obj';
% greeble = LoadOBJFile(file1);

plt = 1; %plt=1 -> plot

K=3; %third branch in xMP and yMP point

greeble1 = greeble{1};

vertices = greeble1.vertices';
if(plt)
    triangles = greeble1.faces'+1;
    triangles = triangles(1:end-1,:);
end

len = length(vertices);

%find dist from z-axis
D = vertices(:,1).^2+vertices(:,2).^2;

if(plt)
    c = {'r','g','b'};
    count = 1;
    figure;
    hold on;

    obj = trisurf( triangles, vertices(:,1), vertices(:,2), vertices(:,3) );
    set(obj,'EdgeColor','none');
    set(obj,'FaceColor',c{2});
    set(obj,'FaceAlpha',0.3);
    set(obj,'BackFaceLighting','lit');

    %shading interp
    lighting phong;
    material([0.2,0.5,0.2,30]);

    axis equal;
    grid off;

%    plot3( vertices(:,1), vertices(:,2), vertices(:,3), '.' );
    plot3([0 0], [0,0], [0,max(vertices(:,3))],'k' );
end

%[xMP,yMP] = ginput;

xMP = [-3.3293 -0.0845 2.3468 3.3264]';
yMP = [-0.0433 -3.6554 -1.8974 -0.1307]';

if( ~exist('xMP') || ~exist('yMP') )
    [xMP,yMP] = ginput;
end

for i=1:length(xMP)
    tmpDistX = ( vertices(:,1)-xMP(i) ).^2;
    tmpDistY = ( vertices(:,2)-yMP(i) ).^2;
    tmp = tmpDistX+tmpDistY;
    [m, tmpInd] = min(tmp);
    Ind(i) = tmpInd;
    if(plt)
        plot3([vertices(tmpInd,1) 0], [vertices(tmpInd,2) 0], [vertices(tmpInd,3) vertices(tmpInd,3)-1.2],'k' );
    end
end

if(plt)
    plot3( vertices(Ind,1), vertices(Ind,2), vertices(Ind,3), '*k' );
end

[dist, NewPnts, NewPntsR] = distance3DPntFromLine( vertices, vertices(Ind(K),:), [0 0 vertices(Ind(K),3)-1.2] );

handInd1 = find(dist<0.8);
handInd2 = find( vertices(:,1)<xMP(K)-0.3 );
tmpind1 = zeros(length(vertices),1);
tmpind1(handInd1) = 1;
tmpind2 = zeros(length(vertices),1);
tmpind2(handInd2) = 1;
tmpind = logical(tmpind1) & logical(tmpind2);
handInd = find(tmpind);

if(plt)
    plot3( NewPntsR(:,1), NewPntsR(:,2), NewPntsR(:,3), '.m' );
    plot3( vertices(handInd,1), vertices(handInd,2), vertices(handInd,3), '*y' );
end

x1 = NewPntsR(handInd,1);
y1 = NewPntsR(handInd,2);
z1 = NewPntsR(handInd,3);
x2 = vertices(handInd,1);
y2 = vertices(handInd,2);
z2 = vertices(handInd,3);

t3 = DIF./sqrt( (x2-x1).^2 + (y2-y1).^2 + (z2-z1).^2 );
t3n = -t3;
x3 = x1+(x2-x1).*t3;
y3 = y1+(y2-y1).*t3;
z3 = z1+(z2-z1).*t3;
x3n = x1+(x2-x1).*t3n;
y3n = y1+(y2-y1).*t3n;
z3n = z1+(z2-z1).*t3n;

Dt = sqrt( (x2-x3).^2 + (y2-y3).^2 + (z2-z3).^2 );
ind = find( Dt>DIF );
x3(ind) = x3n(ind);
y3(ind) = y3n(ind);
z3(ind) = z3n(ind);

if(plt)
    plot3( x3, y3, z3, '.r' );
    for i=1:length(x3)
        plot3( [x3(i) vertices(handInd(i),1)], [y3(i) vertices(handInd(i),2)], [z3(i) vertices(handInd(i),3)], 'k' );
    end
end

newVertices = vertices;
newVertices(handInd,:) = [x3 y3 z3];

greeble2 = greeble1;
greeble2.vertices = newVertices';

plot3( newVertices(:,1), newVertices(:,2), newVertices(:,3), '.' );

