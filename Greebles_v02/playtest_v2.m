function playtest_v2( varargin )

count = nargin;

c = {'r','g','b'};
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
    obj2 = trisurf( triangleN2, vertices2(:,1), vertices2(:,2), vertices2(:,3) );
%     set(obj2,'EdgeColor','none');
%     set(obj2,'FaceColor',c{3});
%     set(obj2,'FaceAlpha',0.3);
%     set(obj2,'BackFaceLighting','lit');
    
%     if( isfield(greeble2,'quadfaces') )
%         quadFaces = greeble2.quadfaces'+1;
%         obj3 = tetramesh(quadFaces,vertices2);
%     end
end


%shading interp
lighting phong;
material([0.2,0.5,0.2,30]);

%axis equal;
grid off;
xlabel('X');
ylabel('Y');
zlabel('Z');
plot3([5 0],[0 0],[0 0],'*r');


