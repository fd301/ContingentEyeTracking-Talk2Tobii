function greeble2 = morphGreeble(greeble,DIF, limit)

% clear all;
% close all;
% 
% DIF = 0.5;
% limit = [1 3];
% 
% file1 = './m1_12_a.obj';
% greeble = LoadOBJFile(file1);

plt = 0; %plt=1 -> plot

greeble1 = greeble{1};

vertices = greeble1.vertices';
if(plt)
    triangles = greeble1.faces'+1;
    triangles = triangles(1:end-1,:);
end

len = length(vertices);

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
    material([0.2,0.5,0.2,30])

    axis equal;
    grid off;

    plot3( vertices(:,1), vertices(:,2), vertices(:,3), '.' );
end

index1 = find( vertices(:,3)>limit(1) );
index2 = find( vertices(:,3)<limit(2) );

aa = zeros(len,1);
aa(index1) = 1;

bb = zeros(len,1);
bb(index2) = 1;

cc = logical(aa) & logical(bb);

index = find(cc);

if(plt)
    plot3( vertices(index,1), vertices(index,2), vertices(index,3), '.r' );
    plot3([0 0], [0,0], [0,max(vertices(:,3))],'k' );
end 

VerticesP = vertices(index,:);

tmp = find( VerticesP(:,1) == 0 );

if( ~isempty(tmp) )
    error('Do not divide with zero');
end

A = VerticesP(:,2)./VerticesP(:,1);
X1 = VerticesP(:,1);
Y1 = VerticesP(:,2);

X2_1 = sqrt( (X1.^2+Y1.^2+DIF)./(A.^2+1) );
X2_2 = -X2_1;

Y2_1 = X2_1.*A;
Y2_2 = X2_2.*A;

Dist = X1.^2+Y1.^2;
Dist1 = (X2_1-X1).^2+(Y2_1-Y1).^2;
Dist2 = (X2_2-X1).^2+(Y2_2-Y1).^2;
DD1 = Dist-Dist1;

X2 = X2_1;
Y2 = Y2_1;
tmpInd2 = find(DD1<0);

X2(tmpInd2) = X2_2(tmpInd2);
Y2(tmpInd2) = Y2_2(tmpInd2);

if(plt)
    plot3(X2,Y2,VerticesP(:,3),'.m')
end

verticesNew = vertices;
verticesNew(index,:) = [X2 Y2 VerticesP(:,3) ];

greeble2 = greeble1;
greeble2.vertices = verticesNew';

%greeble2{1} = greeble2;




