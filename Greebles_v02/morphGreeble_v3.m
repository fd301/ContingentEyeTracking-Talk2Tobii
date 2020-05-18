function [greeble2, IndStore ]= morphGreeble_v3(greeble,DIF, K)

% clear all;
% close all;
% 
% DIF = 1.0;
% 
 %file1 = './m1_12_a.obj';
 %greeble = LoadOBJFile(file1);
 
%  vpos = vpos(:,1);
%  count = 1;
%  for i=1:length(vpos)
%      aa = vpos{i};
%      if(~isempty(aa) )
%          vposnew(count,:) = aa(1,:);
%          count = count+1;
%      end
%  end

% K=1; %branch in xMP and yMP point

plt = 0; %plt=1 -> plot


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

    plot3( vertices(:,1), vertices(:,2), vertices(:,3), '.' );
    plot3([0 0], [0,0], [min(vertices(:,3)),max(vertices(:,3))],'k' );
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
    IndStore(i,:) = [tmpInd, vertices(tmpInd,:)];
    if(plt)
        plot3([vertices(tmpInd,1) 0], [vertices(tmpInd,2) 0], [vertices(tmpInd,3) vertices(tmpInd,3)-1.2],'k' );
    end
end
[m,tmpi] = max(vertices(:,3));
IndStore(i+1,:) = [tmpi, vertices(tmpi,:)];
[m,tmpi] = min(vertices(:,3));
IndStore(i+2,:) = [tmpi, vertices(tmpi,:)];
if(plt)
    plot3( vertices(IndStore(:,1),1), vertices(IndStore(:,1),2), vertices(IndStore(:,1),3),'pc' );
end

% if(plt)
%     plot3( vertices(Ind,1), vertices(Ind,2), vertices(Ind,3), '*k' );
% end

[dist, NewPnts, NewPntsR] = distance3DPntFromLine( vertices, vertices(Ind(K),:), [0 0 vertices(Ind(K),3)-1.2] );

handInd = find(dist<0.8);
% handInd2 = find( vertices(:,1)<xMP(K)-0.3 );
% tmpind1 = zeros(length(vertices),1);
% tmpind1(handInd1) = 1;
% tmpind2 = zeros(length(vertices),1);
% tmpind2(handInd2) = 1;
% tmpind = logical(tmpind1) & logical(tmpind2);
% handInd = find(tmpind);

if(plt)
    plot3( NewPntsR(:,1), NewPntsR(:,2), NewPntsR(:,3), '.m' );
    plot3( vertices(handInd,1), vertices(handInd,2), vertices(handInd,3), '*y' );
end


newVertices = vertices;
newVertices(handInd,3) = newVertices(handInd,3)+DIF;

greeble2 = greeble1;
greeble2.vertices = newVertices';


