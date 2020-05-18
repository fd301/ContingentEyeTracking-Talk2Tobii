function [triFacesInd, triRInd ]= quad2triIndex(quadFacesInd)

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
    
    if( k>1 )
%        triIndV(:,2*i) = [quadFacesInd(7:8,i); quadFacesInd(5,i)];
%        triIndV(:,2*i-1) = quadFacesInd(5:7,i);
        %triIndV(:,2*i) = [quadFacesInd(5,i); quadFacesInd(8:-1:7,i) ];
        %triIndV(:,2*i-1) = quadFacesInd(7:-1:5,i);
        triIndV(:,2*i) = [quadFacesInd(5,i); quadFacesInd(8:-1:7,i) ];
        triIndV(:,2*i-1) = quadFacesInd(7:-1:5,i);
    end
    
    if( k>2 )
%        triIndN(:,2*i) = [quadFacesInd(11:12,i); quadFacesInd(9,i)];
%        triIndN(:,2*i-1) = quadFacesInd(9:11,i);
        %triIndN(:,2*i) = [quadFacesInd(9,i); quadFacesInd(12:-1:11,i)];
        %triIndN(:,2*i-1) = quadFacesInd(11:-1:9,i);
        triIndN(:,2*i) = [quadFacesInd(9,i); quadFacesInd(12:-1:11,i) ];
        triIndN(:,2*i-1) = quadFacesInd(11:-1:9,i);
    end

end

if( exist('triIndV', 'var') && exist('triIndN', 'var') )
    triRInd = cat(1,triIndV,triIndN);
elseif( exist('triIndV', 'var') )
    triRInd = triIndN;
end
