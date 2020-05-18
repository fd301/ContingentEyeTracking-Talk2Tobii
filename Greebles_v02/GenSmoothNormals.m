function Normals = GenSmoothNormals(triangles, vertices )

% estimate facet normals
FNormals = EstNormals(triangles, vertices);

% generate smooth  
angle1 = 180-20;
cos_angle1 = cos(angle1*pi/180);

angle = 360;
cos_angle = cos(angle*pi/180);

triangles = triangles+1;
numT = length(triangles);
numV = length(vertices);

% for every triangle, create an array for each vertex in it
Nodes = cell(1,numV);
for i=1:numT
    tr = triangles(:,i);
    for j=1:3
        tmpA = Nodes{ tr(j) };
        %tmpL = length( tmpA );
        tmpA = [tmpA i];
        Nodes{ tr(j) } = tmpA;
    end
    
end


%calculate the average normal for each vertex
for i=1:numV
    % calculate an average normal of this vertex by averaging the facet
    % normals of every triangle this vertex is in.
    % only average if the dot product of the angle between the two facet
    % normals is greater than the cosine of the threshold angle -- or, said
    % another way, the angle between the two facet normals is less than the
    % threshold angle
    node = Nodes{i};
    aver = zeros(3,1);
    avg = 0;
    for j=1:length(node)-1
        FN1 = FNormals( :, node(j) );
        FN2 = FNormals( :, node(j+1) );
        D = dot(FN1,FN2);
        if( D > cos_angle )
            aver = aver + FNormals( triangles( :, node(j) ) );
            avg = 1;            
%         elseif(D > abs(cos_angle1) )
%             aver = aver - FNormals( triangles( :, node(j) ) );
         end
    end
    
    if(avg)
        % normalise the averaged normal
        aver = aver./sqrt( aver(1)^2 + aver(2)^2 + aver(3)^2 );
        n(:,i) = aver;
    else
        if( ~isempty(node) )
            n(:,i) = FNormals( :, node(1) ); 
        else
            n(:,i) = [0 0 0]';
        end
    end

    Normals = n;



end
