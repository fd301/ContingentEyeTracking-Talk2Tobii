function [triFacesInd, triRInd ]= quad2triIndex_v2(quadFacesInd)

[dim, len] = size(quadFacesInd);

k = dim/4;

triFacesInd = zeros(3,len*2);
for i=1:len
%    triFacesInd(:,2*i) = [quadFacesInd(3:4,i); quadFacesInd(1,i)];
%    triFacesInd(:,2*i-1) = quadFacesInd(1:3,i);
    %triFacesInd(:,2*i) = [quadFacesInd(1,i); quadFacesInd(4:-1:3,i) ];
    %triFacesInd(:,2*i-1) = quadFacesInd(3:-1:1,i);
    triFacesInd(:,2*i) = [quadFacesInd(1,i); quadFacesInd(4:-1:3,i)];
    triFacesInd(:,2*i-1) = quadFacesInd(3:-1:1,i);
    
end

if( exist('triIndV', 'var') && exist('triIndN', 'var') )
    triRInd = cat(1,triIndV,triIndN);
elseif( exist('triIndV', 'var') )
    triRInd = triIndN;
else 
    triRInd = [];
end
