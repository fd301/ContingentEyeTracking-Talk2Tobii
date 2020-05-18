function objNew = sortObj(obj)
% transform all faces to triangles

%sort quad faces
objNew = obj;
if( isfield(obj,'quadfaces') )
    quadfaces = obj.quadfaces;
    [trifaces triRInd]= quad2triIndex(quadfaces);
    Faces = obj.faces;
    faces = cat( 2, Faces, trifaces );
    %faces = trifaces;
    objNew.faces = faces;
else
    return;
end

[dim,tmp] = size(quadfaces);
tmp = dim/4;
if(tmp<3)
    error('normals and texture is not provided!');
end

%sort of vertex and normal indexes of quad faces!!

Texcoords = obj.texcoords;
if( isfield(obj,'SrcTexCoords') )
    SrcTexCoords = obj.SrcTexCoords;
else
    SrcTexCoords = Texcoords;
end

for i=1:length(trifaces)
%     if( Texcoords(1, trifaces(1,i)+1) || Texcoords(1, trifaces(2,i)+1) || Texcoords(1, trifaces(1,i)+1) )
%         disp('texcoordinate is suspicious');
%     end
    Texcoords(:, trifaces(1,i)+1) = SrcTexCoords(:, triRInd(1,i)+1);
    Texcoords(:, trifaces(2,i)+1) = SrcTexCoords(:, triRInd(2,i)+1);
    Texcoords(:, trifaces(3,i)+1) = SrcTexCoords(:, triRInd(3,i)+1);
end

Normals = obj.normals;
if( isfield(obj,'SrcNormals') )
    SrcNormals = obj.SrcNormals;
else
    SrcNormals = Normals;
end

for i=1:length(trifaces)
%     if( Normals(1, trifaces(1,i)+1) || Normals(1, trifaces(2,i)+1) || Normals(1, trifaces(1,i)+1) )
%         disp('texcoordinate is suspicious');
%     end
    Normals(:, trifaces(1,i)+1) = SrcNormals(:, triRInd(4,i)+1);
    Normals(:, trifaces(2,i)+1) = SrcNormals(:, triRInd(5,i)+1);
    Normals(:, trifaces(3,i)+1) = SrcNormals(:, triRInd(6,i)+1);
end

%sort other verteces 
