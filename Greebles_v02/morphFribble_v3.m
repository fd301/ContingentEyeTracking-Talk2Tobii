function fribble2 = morphFribble_v2(fribble, partArray, kindDef)

plt = 1; %plt=1 -> plot

greeble2 = fribble{1};

vertices2 = greeble2.vertices';
triangleN2 = greeble2.faces'+1;

info = greeble2.info;
info2 = greeble2.info2;
% index1 = find( triangles2(:,1) );
% index2 = find( triangles2(:,2) );
% index3 = find( triangles2(:,3) );
% 
% logA1 = size(triangles2);
% logA2 = logA1;
% logA3 = logA2;
% logA1(index1) = true;
% logA2(index2) = true;
% logA3(index3) = true;
% 
% logA = logA1 & logA2 & logA3;
% index = find(logA);
% triangleN2 = triangleN2(index,:);


%find different parts of the 3D object
[indParts,PartVert] = FindParts(fribble);
PartLen = size(indParts);


if( plt )
    figure;
    c = {'r','g','b'};
    cc = {'r.','g.','b.','c*','m*','y*','rh','gp','bp'};
    obj2 = trisurf( triangleN2, vertices2(:,1), vertices2(:,2), vertices2(:,3) );
    set(obj2,'EdgeColor','none');
    set(obj2,'FaceColor',c{2});
    set(obj2,'FaceAlpha',0.3);
    set(obj2,'BackFaceLighting','lit');
    
    %get normals from matlab
    MNormals = get(obj2,'VertexNormals');
    
    %normalise normals
    tmpN1 = sqrt( MNormals(:,1).^2 + MNormals(:,2).^2 + MNormals(:,3).^2 );
    MNormalsN = MNormals./[tmpN1 tmpN1 tmpN1];
    MNormalsN = MNormalsN';
    
    %Check for NaN
    flagNan = isnan(MNormalsN);
    flagIndex = find( flagNan(1,:) );
    MNormalsN(:,flagIndex) = 0;


    %shading interp
    lighting phong;
    material([0.2,0.5,0.2,30]);

    axis equal;
    grid off;
    hold on;
    
    ci = 1;
    for i=1:PartLen
        tmpVert = PartVert{i};
        if(ci>length(cc) )
            ci = 1;
        end
        plot3( tmpVert(:,1)+rand(1)/100, tmpVert(:,2), tmpVert(:,3)+rand(1)/100, cc{ci} );
        ci = ci+1;
    end

    plot3([0 0], [min(vertices2(:,2)),max(vertices2(:,2))], [0,0], 'k' );
end

%the tale is the green 'g.' -- 2nd (use also 1st and 3rd)

verticesN = vertices2;
if( isempty(partArray) )
    partArray = 1:length(indParts);
end

for i=1:length(partArray)
    if( length(indParts)<partArray(i) )
        warning('part has been ignored1');
        break;
    end

    t = indParts(partArray(i),:);
    j = t(1):t(end);
    
    switch(kindDef)
        case 1,
            Rot = makehgtform('yrotate',0.174);
            Rot = Rot(1:3,1:3);
            verticesN( triangleN2(j,:),: ) = verticesN( triangleN2(j,:),: ) * Rot';
        case 2,
            Rot = makehgtform('yrotate',0.174);
            Rot1 = makehgtform('xrotate',0.0574);
            Rot = Rot*Rot1;
            Rot = Rot(1:3,1:3);
            verticesN( triangleN2(j,:),: ) = verticesN( triangleN2(j,:),: ) * Rot';
        case 3,
            Rot = makehgtform('yrotate',0.174);
            Rot = Rot(1:3,1:3);
            verticesN( triangleN2(j,:),: ) = verticesN( triangleN2(j,:),: ) * Rot'*1.05;
        case 4,
            Rot = makehgtform('yrotate',0.174);
            Rot1 = makehgtform('xrotate',0.1574);
            Rot = Rot*Rot1;
            Rot = Rot(1:3,1:3);
            verticesN( triangleN2(j,:),: ) = verticesN( triangleN2(j,:),: ) * Rot'*0.95;
        case 5,
            verticesN( triangleN2(j,:),: ) = verticesN( triangleN2(j,:),: ) * 0.95;            
        case 6,
            lentmp = size( verticesN( triangleN2(j,:),: ) );
            tmp = rand(lentmp(1),3);
            tmp = tmp .*(1.2-0.8) + 0.8;
            verticesN( triangleN2(j,:),: ) = verticesN( triangleN2(j,:),: ) .* tmp;     
        case 7,
            verticesN( triangleN2(j,:),2 ) = verticesN( triangleN2(j,:),2 ) + verticesN( triangleN2(j,:),2 ) * 0.1;     
            verticesN( triangleN2(j,:),1 ) = verticesN( triangleN2(j,:),1 ) - verticesN( triangleN2(j,:),2 ) * 0.1;     
        otherwise,
            Rot = makehgtform('yrotate',0.174);
            Rot = Rot(1:3,1:3);
            verticesN( triangleN2(j,:),: ) = verticesN( triangleN2(j,:),: ) * Rot';
    end
end
%vertices2(triangleN2(1),:) =  vertices2(1,:) + [0.1 0.1 0.1];
%vertices2(1,:) =  vertices2(1,:) + [0.1 0.1 0.1];
fribble2 = greeble2;
fribble2.vertices = verticesN';
fribble2.normals = MNormalsN;



