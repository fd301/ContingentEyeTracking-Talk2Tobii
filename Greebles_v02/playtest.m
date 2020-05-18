function playtest( tmpobj, tmpobjSh2 )

% greeble1 = tmpobj{1};
% 
% vertices1 = greeble1.vertices';
% triangles1 = greeble1.faces'+1;
% triangles1 = triangles1(1:end-1,:);
% 
% len1 = length(vertices1);

greeble2 = tmpobj{1};

vertices2 = greeble2.vertices';
triangles2 = greeble2.faces'+1;
index1 = find( triangles2(:,1) );
index2 = find( triangles2(:,2) );
index3 = find( triangles2(:,3) );

logA1 = size(triangles2);
logA2 = logA1;
logA3 = logA2;
logA1(index1) = logical(1);
logA2(index2) = logical(1);
logA3(index3) = logical(1);

logA = logA1 & logA2 & logA3;
index = find(logA);
triangleN2 = zeros(length(index),3);
triangleN2 = triangles2(index,:);


len2 = length(vertices2);
c = {'r','g','b'};
figure;
hold on;
obj2 = trisurf( triangleN2, vertices2(:,1), vertices2(:,2), vertices2(:,3) );
set(obj2,'EdgeColor','none');
set(obj2,'FaceColor',c{3});
set(obj2,'FaceAlpha',0.3);
set(obj2,'BackFaceLighting','lit');

% obj1 = trisurf( triangles1, vertices1(:,1), vertices1(:,2), vertices1(:,3) );
% set(obj1,'EdgeColor','none');
% set(obj1,'FaceColor',c{2});
% set(obj1,'FaceAlpha',0.3);
% set(obj1,'BackFaceLighting','lit');

%%
greeble2 = tmpobjSh2{1};

vertices2 = greeble2.vertices';
triangles2 = greeble2.faces'+1;
index1 = find( triangles2(:,1) );
index2 = find( triangles2(:,2) );
index3 = find( triangles2(:,3) );

logA1 = size(triangles2);
logA2 = logA1;
logA3 = logA2;
logA1(index1) = logical(1);
logA2(index2) = logical(1);
logA3(index3) = logical(1);

logA = logA1 & logA2 & logA3;
index = find(logA);
triangleN2 = zeros(length(index),3);
triangleN2 = triangles2(index,:);


len2 = length(vertices2);
hold on;
obj2 = trisurf( triangleN2, vertices2(:,1), vertices2(:,2), vertices2(:,3) );
set(obj2,'EdgeColor','none');
set(obj2,'FaceColor',c{3});
set(obj2,'FaceAlpha',0.3);
set(obj2,'BackFaceLighting','lit');

%shading interp
lighting phong;
material([0.2,0.5,0.2,30]);

%axis equal;
grid off;
xlabel('X');
ylabel('Y');
zlabel('Z');
plot3(5,0,0,'*r');


