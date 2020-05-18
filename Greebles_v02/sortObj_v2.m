function objNew = sortObj_v2(obj)
% transform all faces to triangles

%sort quad faces
objNew = obj;
if( isfield(obj,'faces') )
    info2 = length(obj.faces);
else
    info2 = 0;
end

if( isfield(obj,'quadfaces') )
    quadfaces = obj.quadfaces;
    [trifaces]= quad2triIndex_v2(quadfaces);
    Faces = obj.faces;
    faces = cat( 2, Faces, trifaces );
    %faces = trifaces;
    objNew.faces = faces;
else
    return;
end

%calculate normals 
%Normals = EstNormals( objNew.faces, objNew.vertices );
Normals = GenSmoothNormals( objNew.faces, objNew.vertices );
objNew.normals = Normals;
objNew.info2 = info2;



