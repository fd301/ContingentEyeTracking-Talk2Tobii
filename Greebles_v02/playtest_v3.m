function playtest_v3( varargin )

count = nargin;

c = {'r','b','b'};
figure;
hold on;

for i=1:count
    greeble2 = varargin{i}{1};
    
    vertices2 = greeble2.vertices';
    triangles2 = greeble2.faces'+1;
    index1 = find( triangles2(:,1) );
    index2 = find( triangles2(:,2) );
    index3 = find( triangles2(:,3) );

    logA1 = zeros(1,length(triangles2));
    logA2 = logA1;
    logA3 = logA2;
    logA1(index1) = true;
    logA2(index2) = true;
    logA3(index3) = true;

    logA = logA1 & logA2 & logA3;
    index = find(logA);
    triangleN2 = zeros(length(index),3);
    triangleN2 = triangles2(index,:);


    len2 = length(vertices2);
    switch(i)
        case {1,2}
            obj2 = trisurf( triangleN2, vertices2(:,1), vertices2(:,2), vertices2(:,3) );
        case {3,4}
            obj2 = trisurf( triangleN2, vertices2(:,1)-0.7, vertices2(:,2)+0.7, vertices2(:,3)+0.5 );
        case {5,6}
            obj2 = trisurf( triangleN2, vertices2(:,1)-0.7, vertices2(:,2)-0.7, vertices2(:,3)+0.5 );
        case {7,8}
            obj2 = trisurf( triangleN2, vertices2(:,1)+0.7, vertices2(:,2)-0.7, vertices2(:,3)-0.5 );
        case {9,10}
            obj2 = trisurf( triangleN2, vertices2(:,1)+0.7, vertices2(:,2)+0.7, vertices2(:,3)-0.5 );
    end
    
    if( mod(i,2)==0 )
        set(obj2,'EdgeColor','none');
%         set(obj2,'EdgeColor',c{3});
%         set(obj2,'EdgeAlpha',0.5);
        set(obj2,'FaceAlpha',0.3);
        set(obj2,'FaceColor',c{3});
    else
        set(obj2,'EdgeColor','none');
        set(obj2,'FaceColor',c{1});        
        set(obj2,'FaceAlpha',0.3);
    end
    
    
%    set(obj2,'BackFaceLighting','lit');
    

%    shading interp
    lighting phong;
    
    if( isfield(greeble2,'quadfaces') )
        quadFaces = greeble2.quadfaces'+1;
    switch(i)
        case {1,2}
            obj3 = tetramesh(quadFaces,[vertices2(:,1) vertices2(:,2) vertices2(:,3)]);
        case {3,4}
            obj3 = tetramesh(quadFaces,[vertices2(:,1)-0.7 vertices2(:,2)+0.7 vertices2(:,3)+0.5]);
        case {5,6}
            obj3 = tetramesh(quadFaces,[vertices2(:,1)-0.7 vertices2(:,2)-0.7 vertices2(:,3)+0.5]);
        case {7,8}
            obj3 = tetramesh(quadFaces,[vertices2(:,1)+0.7 vertices2(:,2)-0.7 vertices2(:,3)-0.5]);
        case {9,10}
            obj3 = tetramesh(quadFaces,[vertices2(:,1)+0.7 vertices2(:,2)+0.7 vertices2(:,3)-0.5]);
    end
        %obj3 = tetramesh(quadFaces,vertices2);
        if( mod(i,2)==0)
            set(obj2,'EdgeColor','none');
%             set(obj2,'EdgeColor',c{3});
%             set(obj2,'EdgeAlpha',0.5);
            set(obj3,'FaceAlpha',0.3);
        else
            set(obj3,'EdgeColor','none');
            set(obj3,'FaceColor',c{1});
            set(obj3,'FaceAlpha',0.3);
        end
    end
end


%material([0.2,0.5,0.2,30]);

axis equal;
grid off;
axis off;
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
%plot3([5 0],[0 0],[0 0],'*r');


