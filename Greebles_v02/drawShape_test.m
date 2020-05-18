% drawShape does the actual drawing:
function vpos = drawShape( objOrd, numObj, color, ang, theta, theta2, rotatev, dotson, normalson, IndStore, gltextarget3,gltexid3,gltextarget1,gltexid1)
% GL needs to be defined as "global" in each subfunction that
% executes OpenGL commands:
global GL
global win

if( nargin<11 )
    textureon=0;
else
    textureon=1;
end

% Backup modelview matrix:
glPushMatrix;

% Setup rotation around axis:
%glRotated(theta,rotatev(1),rotatev(2),rotatev(3));
%glRotated(ang,0,0,1);
glRotated(180,0,1,0);

% Scale object by a factor of a:
a=1.0;
glScalef(a,a,a);

glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 0.3 0.3 0.3 0.9 ]);
glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ color(1) color(2) color(3) 0.9 ]);



glPushMatrix;

glRotated(ang,0,1,0);
glRotated(5+theta,0,0,1);
glTranslated(0,-0.15,0);

moglmorpher('render');

glPopMatrix;

if(numObj>2)
    glPushMatrix;
    glTranslated(0,0.4,1.0);

    if(textureon)
        glEnable(gltextarget1);
        glBindTexture(gltextarget1, gltexid1);
        glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
    end

    switch objOrd(1)
        case 1
            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1.0 1.0 0.0 .9 ]);
            moglmorpher1('render');
        case 2
            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1.0 1.0 0.0 .9 ]);
%            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .1 .7 .9 0.9 ]);
            moglmorpher1('render');
        case 3
            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .9 .1 .1 0.8 ]);
            moglmorpher3('render');
        case 4
            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .9 .1 .9 0.9 ]);
            moglmorpher4('render');
        otherwise
            error('drawShape: there is no object with this id');
    end
    
    if(textureon)
        glDisable(gltextarget1);
    end
    glPopMatrix;
end

if(numObj>2)
    glPushMatrix;
    glTranslated(0,0.4,-1);

    switch objOrd(2)
        case 1
            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1.0 1.0 0.0 .9 ]);
            moglmorpher1('render');
        case 2
            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1.0 1.0 0.0 .9 ]);
%            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .1 .7 .9 0.9 ]);
            moglmorpher2('render');
        case 3
            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .9 .1 .1 0.8 ]);
            moglmorpher3('render');
        case 4
            glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .9 .1 .9 0.9 ]);
            moglmorpher4('render');
        otherwise
            error('drawShape: there is no object with this id');
    end
    glPopMatrix;
end

glPushMatrix;
glTranslated(0,-0.8,-1.0);
if(textureon)
    glEnable(gltextarget3);
    glBindTexture(gltextarget3, gltexid3);
    glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
end

switch objOrd(3)
    case 1
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1.0 1.0 0.0 .9 ]);
        moglmorpher1('render');
    case 2
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1.0 1.0 0.0 .9 ]);
        %glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .1 .7 .9 0.9 ]);
        moglmorpher2('render');
    case 3
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .9 .1 .1 0.8 ]);
        moglmorpher3('render');
    case 4
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .9 .1 .9 0.9 ]);
        moglmorpher4('render');
    otherwise
        error('drawShape: there is no object with this id');
end
if(textureon)
    glDisable(gltextarget3);
end
% glPopMatrix;
% 
% 
% glPushMatrix;
% glTranslated(0,-0.8,1.0);
switch objOrd(4)
    case 1
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1.0 1.0 0.0 .2 ]);
        moglmorpher1('render');
    case 2
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1.0 1.0 0.0 .2 ]);
        %glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .1 .7 .9 0.9 ]);
        moglmorpher2('render');
    case 3
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .9 .1 .1 0.8 ]);
        moglmorpher3('render');
    case 4
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .9 .1 .9 0.9 ]);
        moglmorpher4('render');
    otherwise
        error('drawShape: there is no object with this id');
end
glPopMatrix;


% Some extra visualizsation code for normals, mesh and vertices:
if (dotson == 1 | dotson == 3)
    % Draw some dot-markers at positions of vertices:
    % We disable lighting for this purpose:
    glDisable(GL.LIGHTING);
    % From all polygons, only their defining vertices are drawn:
    glPolygonMode(GL.FRONT_AND_BACK, GL.POINT);

    % Ask morpher to rerender the last shape:
    moglmorpher('render');
    moglmorpher1('render');
    moglmorpher2('render');
    moglmorpher3('render');
    moglmorpher4('render');

    % Reset settings for shape rendering:
    glPolygonMode(GL.FRONT_AND_BACK, GL.FILL);
    glEnable(GL.LIGHTING);
end;

if (dotson == 2)
    % Draw connecting lines to visualize the underlying geometry:
    % We disable lighting for this purpose:
    glDisable(GL.LIGHTING);
    % From all polygons, only their connecting outlines are drawn:
    glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);


    % Ask morpher to rerender the last shape:
    moglmorpher('render');
    moglmorpher1('render');
    moglmorpher2('render');
    moglmorpher3('render');
    moglmorpher4('render');

    % Reset settings for shape rendering:
    glPolygonMode(GL.FRONT_AND_BACK, GL.FILL);
    glEnable(GL.LIGHTING);
end;

if (normalson > 0)
    % Draw surface normal vectors on top of object:
    glDisable(GL.LIGHTING);
    % Green is a nice color for this:
    glColor3f(0,1,0);

    % Ask morpher to render the normal vectors of last shape:
    moglmorpher('renderNormals', normalson);
    moglmorpher1('renderNormals', normalson);
    moglmorpher2('render');
    moglmorpher3('render');
    moglmorpher4('render');

    % Reset settings for shape rendering:
    glEnable(GL.LIGHTING);
    glColor3f(0,0,1);
end;

if (dotson == 3 | dotson == 4)
    % Compute and retrieve projected screen-space vertex positions:
    vpos = moglmorpher('getVertexPositions', win);
    vpos1 = moglmorpher1('getVertexPositions', win);

    % Plot the projected 2D points into a Matlab figure window:
    vpos(:,2)=RectHeight(Screen('Rect', win)) - vpos(:,2);
    plot(vpos(:,1), vpos(:,2), '.');
    vpos1(:,2)=RectHeight(Screen('Rect', win)) - vpos1(:,2);
    plot(vpos1(:,1), vpos1(:,2), '.');
    drawnow;
end;

for i=1:length(IndStore)
    vpos(i,:) = moglmorpher('getVertexPositions', win, IndStore(i),IndStore(i));
    %vpos1(i,:) = moglmorpher1('getVertexPositions', win, IndStore(i),IndStore(i));
end

% Restore modelview matrix:
glPopMatrix;

if( ~exist('vpos','var') )
    vpos = [];
end

% Done, return to main-function:
return;
