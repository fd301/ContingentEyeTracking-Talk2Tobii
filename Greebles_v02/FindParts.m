function [indParts,PartVert] = FindParts(fribble)

greeble2 = fribble{1};
info = greeble2.info;
info2 = greeble2.info2;
triangleN2 = greeble2.faces'+1;
vertices2 = greeble2.vertices';


%find different parts of the 3D object
trParts = find( info(:,2) == 3 );
quParts = find( info(:,2) == 4 );
count = 1;
st = 0;
if( ~isempty(trParts) )
    for i =1:length(trParts)-1
        indParts(count,1) = info( trParts(i),1 );
        indParts(count,2) = info( trParts(i+1),1 ) -1;
        count = count+1;
    end
    indParts(count,1) = info( trParts(end), 1 );
    indParts(count,2) = info2-1;   
    count = count+1;
    st = info2-1;
end

if( ~isempty(quParts) )
    for i=1:length(quParts)-1
        indParts(count,1) = st+2*info( quParts(i),1 ) -1;
        indParts(count,2) = st+2*( info( quParts(i+1),1 ) -1 );
        count = count+1;        
    end
    indParts(count,1) = st+2*info( quParts(end),1 ) -1;
    indParts(count,2) = length(triangleN2);   
end
if( exist('indParts','var') )
    PartLen = size(indParts);
else
    PartLen = 0;
    indParts = [];
end

%find the vertices that correspond to the triangles
for i=1:PartLen
    t = indParts(i,:);
    tmpVert = [];
    for j=t(1):t(2)
        tmpVert(3*j-2,:) = vertices2(triangleN2(j,1), :);
        tmpVert(3*j-1,:) = vertices2(triangleN2(j,2), :);
        tmpVert(3*j,:) = vertices2(triangleN2(j,3), :);
    end
    PartVert{i} = tmpVert;
end

if( ~exist('PartVert','var') )
    PartVert = [];
end


