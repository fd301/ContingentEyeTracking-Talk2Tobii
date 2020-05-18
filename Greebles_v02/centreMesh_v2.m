function objNew = centreMesh_v2(obj,cntr,new_centre, PartNum)

if(nargin>3)
    tmpObj{1} = obj;
    [indParts,PartVert] = FindParts(tmpObj);
    vertices = PartVert{PartNum};
else
    vertices = obj.vertices';
end


if(nargin>2)
    cx = new_centre(1);
    cy = new_centre(2);
    cz = new_centre(3);
end

if(cntr == 3 && nargin<4 )
    error('Arguments do not match.');    
end

% 1->plot
plt = 0;

%remove vertices that are equal to zero
vertLog = vertices(:,1) | vertices(:,2) | vertices(:,3);
NonZer = find(vertLog);
vertices = vertices(NonZer,:);

aver = mean( abs(vertices), 1 );
aver = mean(aver);
aver1 = mean( abs(vertices), 2 );
outlayer = find( aver1 < 1.3*aver );

if(plt)
    figure;
    plot3( vertices(outlayer,1), vertices(outlayer,2), vertices(outlayer,3), '.' );
end

vertices = vertices(outlayer,:);

% aveX = minX + (maxX - minX)/2;
% aveY = minY + (maxY - minY)/2;
% aveZ = minZ + (maxZ - minZ)/2;

minX = min( vertices(:,1) );
minY = min( vertices(:,2) );
minZ = min( vertices(:,3) );
maxX = max( vertices(:,1) );
maxY = max( vertices(:,2) );
maxZ = max( vertices(:,3) );

%scale 
dX = maxX - minX;
dY = maxY - minY;
dZ = maxZ - minZ;

[M,I] = max( abs( [dX,dY,dZ] ) );
Sc = M*2;

%Sc = 300*scale;
%estimate centre of mass
aveX = mean( vertices(:,1)/Sc );
aveY = mean( vertices(:,2)/Sc );
aveZ = mean( vertices(:,3)/Sc );

vertices = obj.vertices';
newvertices(:,1) = vertices(:,1)/Sc;
newvertices(:,2) = vertices(:,2)/Sc;
newvertices(:,3) = vertices(:,3)/Sc;


switch(cntr)
    case 0          % 
        minX = minX/Sc;
        minY = minY/Sc;
        minZ = minZ/Sc;
        maxX = maxX/Sc;
        maxY = maxY/Sc;
        maxZ = maxZ/Sc;
        aveZ = minZ + (maxZ - minZ)/2;
        newvertices(:,3) = newvertices(:,3) - aveZ;

    case 1          % just centred around 0
        newvertices(:,1) = newvertices(:,1) - aveX;
        newvertices(:,2) = newvertices(:,2) - aveY;
        newvertices(:,3) = newvertices(:,3) - aveZ;

    case 2          % centre around a point
        newvertices(:,1) = newvertices(:,1) - aveX;
        newvertices(:,2) = newvertices(:,2) - aveY;
        newvertices(:,3) = newvertices(:,3) - aveZ;
        
        newvertices(:,1) = newvertices(:,1) + cx;
        newvertices(:,2) = newvertices(:,2) + cy;
        newvertices(:,3) = newvertices(:,3) + cz;
        
    otherwise
        error('cntrl-argument is not supported');
end

% estimate normals
figure;
triangleN2 = obj.faces'+1;
obj2 = trisurf( triangleN2, newvertices(:,1), newvertices(:,2), newvertices(:,3) );
MNormals = get(obj2,'VertexNormals');

%normalise normals
tmpN1 = sqrt( MNormals(:,1).^2 + MNormals(:,2).^2 + MNormals(:,3).^2 );
MNormalsN = MNormals./[tmpN1 tmpN1 tmpN1];
MNormalsN = MNormalsN';


objNew = obj;
objNew.vertices = newvertices';
objNew.normals = MNormalsN;


