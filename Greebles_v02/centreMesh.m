function objNew = centreMesh(obj,cntr,new_centre,scale)

vertices = obj.vertices';

if(nargin>2)
    cx = new_centre(1);
    cy = new_centre(2);
    cz = new_centre(3);
end

if(cntr == 3 && nargin<4 )
    error('Arguments do not match.');    
end


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

% [M,I] = max([dX,dY,dZ]);
% Sc = M;

Sc = 300*scale;
newvertices(:,1) = vertices(:,1)/Sc;
newvertices(:,2) = vertices(:,2)/Sc;
newvertices(:,3) = vertices(:,3)/Sc;

minX = min( newvertices(:,1) );
minY = min( newvertices(:,2) );
minZ = min( newvertices(:,3) );
maxX = max( newvertices(:,1) );
maxY = max( newvertices(:,2) );
maxZ = max( newvertices(:,3) );

%estimate centre of mass
aveX = mean( newvertices(:,1) );
aveY = mean( newvertices(:,2) );
aveZ = mean( newvertices(:,3) );


switch(cntr)
    case 0          % 
        aveZ = minZ + (maxZ - minZ)/2;
        newvertices(:,3) = newvertices(:,3) - aveZ;

    case 1          % just centred
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

objNew = obj;
objNew.vertices = newvertices';


