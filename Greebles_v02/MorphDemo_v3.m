function vpos = MorphDemo_v3(textureon, dotson, normalson, stereomode, usefastoffscreenwindows)
% function MorphDemo([textureon][, dotson][, normalson][, stereomode][, usefastoffscreenwindows])
% MorphDemo -- Demonstrates use of "moglmorpher" for fast morphing
% and rendering of 3D shapes. See "help moglmorpher" for info on
% moglmorphers purpose and capabilities.
%
% This demo will load two morpheable shapes from OBJ files and then
% morph them continously into each other, using a simple sine-function
% to define the timecourse of the morph.
%
% Control keys and their meaning:
% 'a' == Zoom out by moving object away from viewer.
% 'z' == Zoom in by moving object close to viewer.
% 'k' and 'l' == Rotate object around axis.
% 'q' == Quit demo.
%
% Options:
%
% textureon = If set to 1, the objects will be textured, otherwise they will be
% just shaded without a texture. Defaults to zero.
%
% dotson = If set to 0 (default), just show surface. If set to 1, some dots are
% plotted to visualize the vertices of the underlying mesh. If set to 2, the
% mesh itself is superimposed onto the shape. If set to 3 or 4, then the projected
% vertex 2D coordinates are also visualized in a standard Matlab figure window.
%
% normalson = If set to 1, then the surface normal vectors will get visualized as
% small green lines on the surface.
%
% stereomode = n. For n>0 this activates stereoscopic rendering - The shape is
% rendered from two slightly different viewpoints and one of Psychtoolbox's
% built-in stereo display algorithms is used to present the 3D stimulus. This
% is very preliminary so it doesn't work that well yet.
% 
% usefastoffscreenwindows = If set to 0 (default), work on any graphics
% card. If you have recent hardware, set it to 1. That will enable support
% for fast offscreen windows - and a much faster implementation of shape
% morphing.
%
% This demo and the morpheable OBJ shapes were contributed by
% Dr. Quoc C. Vuong, MPI for Biological Cybernetics, Tuebingen, Germany.
morphnormals = 1;
global win;

% Is the script running in OpenGL Psychtoolbox?
AssertOpenGL;

% Should per pixel lighting via OpenGL shading language be used? This doesnt work
% well yet.
perpixellighting = 0

% Some default settings for rendering flags:
if nargin < 1 | isempty(textureon)
    textureon = 0;  % turn texture mapping on (1) or off (0) -- only sphere and face has textures
end
textureon

if nargin < 2 | isempty(dotson)
    dotson = 0;     % turn reference dots: off(0), on (1) or show reference lines (2)
end
dotson

if nargin < 3 | isempty(normalson)
    normalson = 0;     % turn reference dots: off(0), on (1) or show reference lines (2)
end
normalson

if nargin < 4 | isempty(stereomode)
    stereomode = 0;
end;
stereomode

if nargin < 5 | isempty(usefastoffscreenwindows)
    usefastoffscreenwindows = 0;
end
usefastoffscreenwindows

% Response keys: Mapping of keycodes to keynames.
closer = KbName('a');
farther = KbName('z');
quitkey = KbName('q');
rotateleft = KbName('l');
rotateright = KbName('k');

%eyetracker: record or playback-capture screen
EYETRACKER = 1;
PLAYBACK = 0;
CAPTURESCREEN = 0;
PLOT_ELLIPSE_PNTS = 0;
inputPathEvents = './events_rot.txt';
inputPathEyeTracking = './Tracking_rot.txt';
DataFile = './EllipsePoints_rot.mat';
outPicDir = './picts_rot';
outPicName = 'pict_';
%hostName = '193.61.24.97';
%hostName = '193.61.24.48';
hostName = '169.254.6.97'; %T120-B08
%hostName = '193.61.45.213';
port = 4455;
if( PLAYBACK && EYETRACKER)
    EYETRACKER = 0;
    warning('PLAYBACK is on, eyetracking has been disabled.');
end

if(PLAYBACK)
    FieldNames = {'EyeEventSec','EyeEventMsec','ThetaEvent',...
                  'w_1','w_2','w_3','w_4','w_5','w_6','w_7','w_8'};
    [TimeLine, EyeTrackingInfo, ...
     EyeEventSec, EyeEventMsec, ThetaEvent...
     w_1, w_2, w_3, w_4, w_5, w_6, w_7, w_8, ...
     IndexSamples] = ...
        InitEyeEventsForPlayBack(inputPathEvents, inputPathEyeTracking,FieldNames);
    EyeEventSec = EyeEventSec(:,2);
    EyeEventMsec = EyeEventMsec(:,2);
    ThetaEvent = ThetaEvent(:,2);
    w_1 = w_1(:,2);
    w_2 = w_2(:,2);
    w_3 = w_3(:,2);
    w_4 = w_4(:,2);
    w_5 = w_5(:,2);
    w_6 = w_6(:,2);
    w_7 = w_7(:,2);
    w_8 = w_8(:,2);
    
        
    lenPlayBack = length(EyeEventSec);
    
    %load other data
    EllipsePnts = load(DataFile);
end

% Load OBJs. This will define topology and use of texcoords and normals:
% One can call LoadOBJFile() multiple times for loading multiple objects.
file1 = './m1_12_a.obj';
tmpobj = LoadOBJFile(file1);

tmpobj{1} = centreMesh(tmpobj{1},0);
IndStore = ConfigGreeble(tmpobj);
DIF = -1;
zz = IndStore(5,4);
dzz = zz*2/3;
limit1 = [-zz -zz+dzz];
limit2 = [-zz+dzz -zz+2*dzz];
limit3 = [-zz+2*dzz zz];
tmpobj_1 = morphGreeble(tmpobj,DIF,limit1);
tmpobj_2 = morphGreeble(tmpobj,DIF,limit2);
tmpobj_3 = morphGreeble(tmpobj,DIF,limit3);

tmpobj_11 = morphGreeble_v3(tmpobj,0.3,1);
tmpobj_12 = morphGreeble_v3(tmpobj,0.3,2);
tmpobj_13 = morphGreeble_v3(tmpobj,0.3,3);
tmpobj_14 = morphGreeble_v3(tmpobj,0.3,4);

objs = { tmpobj{1} tmpobj_11 tmpobj_12 tmpobj_13 tmpobj_14 tmpobj_3 tmpobj_2 tmpobj_1 };

for i=1:length(objs)
    objs{i}.texcoords = objs{i}.vertices;
end
%bjs{1}.texcoords = objs{1}.vertices;
%objs{2}.texcoords = objs{2}.normals;
%objs{3}.texcoords = objs{3}.normals;
% [dim1,dim2] = size( objs{2}.vertices );
% tmp = ( [ones(dim1,1).*(1:dim1)']*[ones(1,dim2).*(1:dim2)] )/10000;
% tmp1 = randperm(dim2);
% tmp( :, tmp1(1:dim2-50) ) = 0;
% objs{2}.vertices = objs{2}.vertices + tmp;



% Find the screen to use for display:
screenid=max(Screen('Screens'));

% Disable Synctests for this simple demo:
Screen('Preference','SkipSyncTests',1);

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper. We need to do this before the first call
% to any OpenGL function:
InitializeMatlabOpenGL(0,1);

% Open a double-buffered full-screen window: Everything is left at default
% settings, except stereomode:
if dotson~=3 & dotson~=4
    rect = [];
    %rect = [0 0 500 500];
else
    rect = [0 0 500 500];
end;

try

    if usefastoffscreenwindows
        [win , winRect] = Screen('OpenWindow', screenid, 0, rect, [], [], stereomode, [], kPsychNeedFastOffscreenWindows);
    else
        [win , winRect] = Screen('OpenWindow', screenid, 0, rect, [], [], stereomode);
    end
    res = winRect(3:4);

    %initialise & calibrate eyetracker
    if(EYETRACKER)
        errorCode = TobiiInit(hostName, port, win, res);
        if( errorCode )
            EYETRACKER = 0;
        end
    end


    % Setup texture mapping if wanted:
    if ( textureon==1 )
        % Load and create face texture in Psychtoolbox:
        texname = [basepath 'TeapotTexture.jpg'];
        texture = imread(texname);
        texid = Screen('MakeTexture', win, texture);

        % Retrieve a standard OpenGL texture handle and target from Psychtoolbox for use with MOGL:
        [gltexid gltextarget] = Screen('GetOpenGLTexture', win, texid);

        % Swap (u,v) <-> (v,u) to account for the transposed images read via Matlab imread():
        texcoords(2,:) = objs{1}.texcoords(1,:);
        texcoords(1,:) = 1 - objs{1}.texcoords(2,:);

        % Which texture type is provided to us by Psychtoolbox?
        if gltextarget == GL.TEXTURE_2D
            % Nothing to do for GL_TEXTURE_2D textures...
        else
            % Rectangle texture: We need to rescale our texcoords as they are made for
            % power-of-two textures, not rectangle textures:
            texcoords(1,:) = texcoords(1,:) * size(texture,1);
            texcoords(2,:) = texcoords(2,:) * size(texture,2);
        end;
    end

    % Reset moglmorpher:
    moglmorpher('reset');

    % Add the OBJS to moglmorpher for use as morph-shapes:
    for i=1:size(objs,2)
        if ( textureon==1 )
            objs{i}.texcoords = texcoords; % Add modified texture coords.
        end
        meshid(i) = moglmorpher('addMesh', objs{i});
    end

    % Output count of morph shapes:
    count = moglmorpher('getMeshCount')

    % Setup the OpenGL rendering context of the onscreen window for use by
    % OpenGL wrapper. After this command, all following OpenGL commands will
    % draw into the onscreen window 'win':
    Screen('BeginOpenGL', win);

    if perpixellighting==1
        % Load a GLSL shader for per-pixel lighting, built a GLSL program out of it...
        shaderpath = [PsychtoolboxRoot '/PsychDemos/OpenGL4MatlabDemos/GLSLDemoShaders/'];
        glsl=LoadGLSLProgramFromFiles([shaderpath 'Pointlightshader'],1);
        % ...and activate the shader program:
        glUseProgram(glsl);
    end;

    if ( textureon==1 )
        % Setup texture mapping for our face texture:
        glBindTexture(gltextarget, gltexid);
        glEnable(gltextarget);

        % Choose texture application function: It shall modulate the light
        % reflection properties of the the objects surface:
        glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
    end

    % Get the aspect ratio of the screen, we need to correct for non-square
    % pixels if we want undistorted displays of 3D objects:
    ar=winRect(4)/winRect(3);

    % Turn on OpenGL local lighting model: The lighting model supported by
    % OpenGL is a local Phong model with Gouraud shading.
    glEnable(GL.LIGHTING);

    % Enable the first local light source GL.LIGHT_0. Each OpenGL
    % implementation is guaranteed to support at least 8 light sources.
    glEnable(GL.LIGHT0);

    % Enable proper occlusion handling via depth tests:
    glEnable(GL.DEPTH_TEST);

    % Define the light reflection properties by setting up reflection
    % coefficients for ambient, diffuse and specular reflection:
    glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 0.5 0.5 0.5 0.5 ]);
    glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ .5 .7 .9 0.1 ]);
    glMaterialfv(GL.FRONT_AND_BACK,GL.SPECULAR, [ 0.2 0.2 0.2 0.5 ]);
    glMaterialfv(GL.FRONT_AND_BACK,GL.SHININESS,12);

    % Make sure that surface normals are always normalized to unit-length,
    % regardless what happens to them during morphing. This is important for
    % correct lighting calculations:
    glEnable(GL.NORMALIZE);

    % Set projection matrix: This defines a perspective projection,
    % corresponding to the model of a pin-hole camera - which is a good
    % approximation of the human eye and of standard real world cameras --
    % well, the best aproximation one can do with 3 lines of code ;-)
    glMatrixMode(GL.PROJECTION);
    glLoadIdentity;

    % Field of view is +/- 25 degrees from line of sight. Objects close than
    % 0.1 distance units or farther away than 200 distance units get clipped
    % away, aspect ratio is adapted to the monitors aspect ratio:
    gluPerspective(25.0,1/ar,0.1,200.0);

    % Setup modelview matrix: This defines the position, orientation and
    % looking direction of the virtual camera:
    glMatrixMode(GL.MODELVIEW);
    glLoadIdentity;

    % Setup position of lightsource wrt. origin of world:
    % Pointlightsource at (20 , 20, 20)...
    glLightfv(GL.LIGHT0,GL.POSITION,[ 20 20 20 0 ]);

    % Setup emission properties of the light source:

    % Emits white (1,1,1,1) diffuse light:
    glLightfv(GL.LIGHT0,GL.DIFFUSE, [ 1 1 1 0.5 ]);

    % Emits white (1,1,1,1) specular light:
    glLightfv(GL.LIGHT0,GL.SPECULAR, [ 1 1 1 1 ]);

    % There's also some weak ambient light present:
    glLightfv(GL.LIGHT0,GL.AMBIENT, [ 0.1 0.1 0.1 1 ]);

    % Set size of points for drawing of reference dots
    glPointSize(3.0);
    glColor3f(0,0,1);

    % Set thickness of reference lines:
    glLineWidth(2.0);

    % Add z-offset to reference lines, so they do not get occluded by surface:
    glPolygonOffset(0, -5);
    glEnable(GL.POLYGON_OFFSET_LINE);

    % Initialize amount and direction of rotation for our slowly spinning,
    % morphing objects:
    theta=-90;
    rotatev=[ 1 0 0 ];

    % Initialize morph vector:
    w=zeros(1,length(objs));
    w(1) = 1;

    % Setup initial z-distance of objects:
    zz = 10.0;

    ang = 0.0;      % Initial rotation angle

    % Half eye separation in length units for quick & dirty stereoscopic
    % rendering. Our way of stereo is not correct, but it makes for a
    % nice demo. Figuring out proper values is not too difficult, but
    % left as an exercise to the reader.
    eye_halfdist=2;

    % Finish OpenGL setup and check for OpenGL errors:
    Screen('EndOpenGL', win);

    % Compute initial morphed shape for next frame, based on initial weights:
    moglmorpher('computeMorph', w, morphnormals);

    if( EYETRACKER )
        weights = w;
        angle_theta = theta;
    end

    % Retrieve duration of a single monitor flip interval: Needed for smooth
    % animation.
    ifi = Screen('GetFlipInterval', win);

    % Initially sync us to the VBL:
    vbl=Screen('Flip', win);

    % Some stats...
    tstart=vbl;
    framecount = 0;
    waitframes = 1;

    % Animation loop: Run until key press or one minute has elapsed...
    t = GetSecs;
    count = 0;
    
    %SetMouse(10,10,win);
    while ((GetSecs - t) < 1000)

        count = count+1;

        % Switch to OpenGL rendering for drawing of next frame:
        Screen('BeginOpenGL', win);

        % Left-eye cam is located at 3D position (-eye_halfdist,0,zz), points upright (0,1,0) and fixates
        % at the origin (0,0,0) of the worlds coordinate system:
        glLoadIdentity;
        %x = x+1;
        gluLookAt(5, 0, 0, 0, 0, 0, 0, 1, 0);
        %fprintf('%d %d\n',x,y);

        % Draw into image buffer for left eye:
        Screen('EndOpenGL', win);
        Screen('BeginOpenGL', win);

        % Clear out the depth-buffer for proper occlusion handling:
        glClear(GL.DEPTH_BUFFER_BIT);

        % Call our subfunction that does the actual drawing of the shape (see below):
        vpos = drawShape(ang, theta, rotatev, dotson, normalson, IndStore);

        % Finish OpenGL rendering into Psychtoolbox - window and check for OpenGL errors.
        Screen('EndOpenGL', win);

        % Tell Psychtoolbox that drawing of this stim is finished, so it can optimize
        % drawing:
        Screen('DrawingFinished', win);

        % Now that all drawing commands are submitted, we can do the other stuff before
        % the Flip:

        % Calculate rotation angle of object for next frame:
        % ang = ang + 1;
        rotatev = [1 0 0];
        %     rotatev=rotatev+0.0001*[ sin((pi/180)*theta) sin((pi/180)*2*theta) sin((pi/180)*theta/5) ];
        %     rotatev=rotatev/sqrt(sum(rotatev.^2));


        % morphing depends on eyetracking data
        if( EYETRACKER )
            eyeTrack = talk2tobii('GET_SAMPLE');
            mx = (eyeTrack(1)+eyeTrack(3))*res(1)/2;
            my = (eyeTrack(2)+eyeTrack(4))*res(2)/2;
            EyeEvent = {'EyeEvent',eyeTrack(5),eyeTrack(6)};
        elseif(PLAYBACK)
            if( count > lenPlayBack )
                break;
            end
            eyeTrack = EyeTrackingInfo(count,:);
            mx = (eyeTrack(1)+eyeTrack(3))*res(1)/2;
            my = (eyeTrack(2)+eyeTrack(4))*res(2)/2;
        else
            [mx,my,buttons] = GetMouse(win);
            %fprintf('%d %d\n',mx,my);
        end

        if( PLAYBACK )
            tmp_w_8 = 1 - w_1(count) - w_2(count) - w_3(count) - w_4(count) - w_5(count) - w_6(count) - w_7(count);
            w = [w_1(count) w_2(count) w_3(count) w_4(count) w_5(count) w_6(count) w_7(count) tmp_w_8];
            Epnts = EllipsePnts.DataPnt{count}{1};
            Bpnts = EllipsePnts.DataPnt{count}{2};
            theta = ThetaEvent(count);            
        else
            [w, Epnts, Bpnts] = findMorphAreas(vpos, mx, my, framecount);
            theta=mod(theta+0.1, 360);
        end
        % Compute morphed shape for next frame, based on new weight vector:
        moglmorpher('computeMorph', w, morphnormals);

        % Check for keyboard press:
        [KeyIsDown, endrt, KeyCode] = KbCheck;
        if KeyIsDown
            if ( KeyIsDown==1 & KeyCode(closer)==1 )
                zz=zz-0.1;
                KeyIsDown=0;
            end

            if ( KeyIsDown==1 & KeyCode(farther)==1 )
                zz=zz+0.1;
                KeyIsDown=0;
            end

            if ( KeyIsDown==1 & KeyCode(rotateright)==1 )
                ang=ang+1.0;
                KeyIsDown=0;
            end

            if ( KeyIsDown==1 & KeyCode(rotateleft)==1 )
                ang=ang-1.0;
                KeyIsDown=0;
            end

            if ( KeyIsDown==1 & KeyCode(quitkey)==1 )
                break;
            end
        end

        % Update frame animation counter:
        framecount = framecount + 1;

        glDisable(GL.LIGHTING);
        glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);
        glEnable(GL.LIGHTING);


        % We're done for this frame:

        % Show rendered image 'waitframes' refreshes after the last time
        % the display was updated and in sync with vertical retrace:
        if( PLOT_ELLIPSE_PNTS )
            glDisable(GL.LIGHTING);
            Screen('glPoint', win, [100 255 255], mx, my, 5);
            vv = vpos;
            for ii=1:length(vv)
                if(~isempty(vv(ii)))
                    Screen('glPoint', win, [255 0 0], vv(ii,1), vv(ii,2), 2);
                end
            end

            for ii=1:length(Epnts)
                for jj=1:length(Epnts{ii})
                    Screen('glPoint', win, [0 255 0], Epnts{ii}(jj,1), Epnts{ii}(jj,2), 2);
                end
            end

            for ii=1:length(Bpnts)
                for jj=1:length(Bpnts{ii})
                    Screen('glPoint', win, [0 0 255], Bpnts{ii}(jj,1), Bpnts{ii}(jj,2), 2);
                end
            end

            glEnable(GL.LIGHTING);
        end
        
        if(PLAYBACK)
            
            if( CAPTURESCREEN )
%                 Screen('TextSize',win, 30 );
%                 Screen('DrawText', win, num2str(count),30 , 30,[0 0 0] );
                
                now = Screen('Flip', win);

                %capture screen - save picture to hard-drive
                imgArray = Screen('GetImage', win);
                imgFileName = fullfile(outPicDir, strcat(outPicName, num2str(count),'.jpeg') );
                imwrite(imgArray,imgFileName, 'jpeg');
            else
                vbl = Screen( 'Flip', win, TimeLine(count,1) );
            end
            
        else
            vbl = Screen('Flip', win, vbl + (waitframes - 0.9) * ifi);
        end
        
        %Screen('Flip', win, 0, 0, 2);
        if(EYETRACKER)            
            FlipEvent = {'FlipEvent',vbl};
            angle_theta = theta;
            weights = w;
            WeightEvent = {'Weights',weights};
            ThetaEvent = {'Theta',angle_theta};
            EventList{count} = {EyeEvent, WeightEvent, ThetaEvent, FlipEvent};
            
            DataPnt{count} = {Epnts Bpnts};
        end


    end

    vbl = Screen('Flip', win);

    % Calculate and display average framerate:
    fps = framecount / (vbl - tstart)

    %eyetracker - finish experiment
    if(EYETRACKER)
        
        %store  events
        for i=1:length(EventList)
            
            EyeEvent = EventList{i}{1};
            WeightEvent = EventList{i}{2};
            ThetaEvent = EventList{i}{3};
            FlipEvent = EventList{i}{4};
            
            weights = WeightEvent{2};
            wId = '';
            for i=1:length(weights)
                wId = strcat( wId,',''w_', num2str(i),''',', num2str(weights(i)) );
            end
            
            command = strcat('talk2tobii(''EVENT'',''FLIP'',FlipEvent{2},0,''EyeEventSec'',EyeEvent{2}, ''EyeEventMsec'',EyeEvent{3},''ThetaEvent'',ThetaEvent{2} ',wId,')');
            eval(command);
        end
        %finalise experiment
        talk2tobii('STOP_RECORD');
        talk2tobii('STOP_TRACKING');
        talk2tobii('SAVE_DATA',inputPathEyeTracking,inputPathEvents,'TRUNK');
        talk2tobii('DISCONNECT');
        [status,history] = talk2tobii('GET_STATUS');
        
        %save additional info to mat file
        save(DataFile,'DataPnt');

    end
    
    % Reset moglmorpher:
    moglmorpher('reset');

    % Close onscreen window and release all other ressources:
    %Screen('Flip', win);
    Screen('CloseAll');

    % Reenable Synctests after this simple demo:
    Screen('Preference','SkipSyncTests',1);


    % Well done!
    WaitSecs(2);
    clear mex;

catch

    % Reset moglmorpher:
    moglmorpher('reset');

    % Close onscreen window and release all other ressources:
    %Screen('Flip', win);
    Screen('CloseAll');
    clear Screen;

    % Reenable Synctests after this simple demo:
    Screen('Preference','SkipSyncTests',1);

    if( EYETRACKER )
        talk2tobii('STOP_RECORD');
        talk2tobii('STOP_TRACKING');
        talk2tobii('DISCONNECT');
    end

    psychrethrow(psychlasterror);
end

return

% drawShape does the actual drawing:
function vpos = drawShape(ang, theta, rotatev, dotson, normalson, IndStore)
% GL needs to be defined as "global" in each subfunction that
% executes OpenGL commands:
global GL
global win

% Backup modelview matrix:
glPushMatrix;

% Setup rotation around axis:
glRotated(theta,rotatev(1),rotatev(2),rotatev(3));
glRotated(ang,0,0,1);

% Scale object by a factor of a:
a=0.2;
glScalef(a,a,a);

% Render current morphed shape via moglmorpher:
% for i=1:length(1400)
%     vpos{i} = moglmorpher('getVertexPositions', win,i-1,i);
% end

moglmorpher('render');

% Some extra visualizsation code for normals, mesh and vertices:
if (dotson == 1 | dotson == 3)
    % Draw some dot-markers at positions of vertices:
    % We disable lighting for this purpose:
    glDisable(GL.LIGHTING);
    % From all polygons, only their defining vertices are drawn:
    glPolygonMode(GL.FRONT_AND_BACK, GL.POINT);

    % Ask morpher to rerender the last shape:
    moglmorpher('render');

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

    % Reset settings for shape rendering:
    glEnable(GL.LIGHTING);
    glColor3f(0,0,1);
end;

if (dotson == 3 | dotson == 4)
    % Compute and retrieve projected screen-space vertex positions:
    vpos = moglmorpher('getVertexPositions', win);

    % Plot the projected 2D points into a Matlab figure window:
    vpos(:,2)=RectHeight(Screen('Rect', win)) - vpos(:,2);
    plot(vpos(:,1), vpos(:,2), '.');
    drawnow;
end;

for i=1:length(IndStore)
    vpos(i,:) = moglmorpher('getVertexPositions', win, IndStore(i),IndStore(i));
end

% Restore modelview matrix:
glPopMatrix;

% Done, return to main-function:
return;
