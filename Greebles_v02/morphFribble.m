function fribble2 = morphFribble(fribble)

plt = 0; %plt=1 -> plot

greeble2 = fribble{1};

vertices2 = greeble2.vertices';
triangles2 = greeble2.faces'+1;
index1 = find( triangles2(:,1) );
index2 = find( triangles2(:,2) );
index3 = find( triangles2(:,3) );

logA1 = size(triangles2);
logA2 = logA1;
logA3 = logA2;
logA1(index1) = true;
logA2(index2) = true;
logA3(index3) = true;

logA = logA1 & logA2 & logA3;
index = find(logA);
triangleN2 = triangles2(index,:);


if( plt )
    obj2 = trisurf( triangleN2, vertices2(:,1), vertices2(:,2), vertices2(:,3) );
    set(obj2,'EdgeColor','none');
    set(obj2,'FaceColor',c{3});
    set(obj2,'FaceAlpha',0.3);
    set(obj2,'BackFaceLighting','lit');
end

vertices2(triangleN2(1),:) =  vertices2(1,:) + [0.1 0.1 0.1];
fribble2 = greeble2;
fribble2.vertices = vertices2';



