function Normals = EstNormals(triangles, vertices )

numT = length(triangles);

aver = mean(vertices,2);

triangles = triangles+1;
for i=1:numT
    u = vertices( :, triangles(2,i) ) - vertices( :, triangles(1,i) );
    v = vertices( :, triangles(3,i) ) - vertices( :, triangles(1,i) );
    
    tmp = cross(u,v);
    n(:,i) = tmp/sqrt( tmp(1)*tmp(1) + tmp(2)*tmp(2) + tmp(3)*tmp(3) );
        
end

Normals = n;

return;


