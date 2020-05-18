function state=ExpControl(command,varargin)
% 
% General syntax
% 
% 	status = ExpControl('command', ...)
% 	
% 	if status == 0, the command has been successfully executed
%
% __Experiment related commands___________________________________________
%
%   ExpControl('StartExp')
%
%       Starts the experiment. Global variables controlling the exact
%       behaviour:
%
%       * EXPERIMENT - the name of the experiment. This controls the name
%       of the log file being created, the file name will start with the
%       experiment name (and it will be followed by an underscore and the
%       subject ID). It will also be displayed on the video if the video
%       titler is enabled.
%
%       * SUBJECT - experiment subject identifier. If unset or zero, Matlab
%       will ask for it. Subjects with negative or zero identifier will not
%       be logged. The subject ID will be visible on the video if the video
%       titler is enabled.
%
%       * BACKCOLOR - the background color in RGB format in a 3x1 matrix
%
%       * NETSTATIONHOST - host name of NetStation if EEG recording is used
%
%       * EEG - whether to use EEG recording (true or false)
%
%       * TITLER - whether to use the video titler (true or false)
%
%   ExpControl('FinishExp')
%
%       Finishes the experiment.
%
%   ExpControl('PauseExp')
%
%       Temporarily pauses an experiment. Displays the text "PAUSE" on the
%       video (if the titler is enabled), stops recording and waits for
%       either Space or Q to be pressed. If Space was pressed, resumes the
%       experiment, otherwise finishes it (no need to call FinishExp
%       afterwards).
%
%   ExpControl('SuspendExp')
%
%       Temporarily pauses an experiment without actually displaying
%       "PAUSE" on the video or waiting for any keypress (so the script
%       keeps on running after executing this command). To resume, use
%       ExpControl('ResumeExp').
%
%   ExpControl('ResumeExp')
%
%       Resumes an experiment previously stopped by
%       ExpControl('SuspendExp').
%
%   ExpControl('Standby')
%
%       Waits for either Space or Q to be pressed. In case of Space, starts
%       recording, in case of Q, finishes the experiment (no need to call
%       ExpControl('FinishExp') afterwards). Returns true if the experiment
%       has been finished.
%
%   ExpControl('CheckPause')
%
%       Checks whether the Escape key is pressed. If yes, pauses the
%       experiment. If your experiment runs something in a loop and you
%       call ExpControl('CheckPause') regularly in the main loop (e.g. once
%       in every iteration), it allows you to pause the experiment at any
%       time by pressing Esc. Returns true if the user pressed Q (=quit)
%       after pausing the experiment, false otherwise.
%
% __Screen related commands_______________________________________________
%
%   ExpControl('EraseScreen'[, color])
%
%       Erases the experiment window with the given color (or the background
%       colour if it is omitted). Returns the timestamp of the moment when
%       the screen has been cleared.
%
% __Keyboard related commands_____________________________________________
% 
%   ExpControl('WaitSpace')
% 	
% 	    Waits until the user presses the Space or the Q key.
%       Returns false if the Space key was pressed, otherwise returns true.
%       No message is displayed.
%
%   ExpControl('IsKey', keycode)
%
%       Returns true if the key with the given keycode is pressed.
%       Numeric or string keycodes are both allowed - see the source code
%       of KbName in PsychToolbox to get the list of the known keycodes or
%       call KbName without arguments - the key name of the next pressed
%       key will be returned (and displayed in the Matlab main window if
%       KbName is invoked from the command line).
% 
    global EXPWIN;
    global BACKCOLOR;
    
    state=false;
    switch lower(command)
        case 'iskey'
            % Checks whether a given key is pressed
            if nargin<2
                key=0;
            else
                key=varargin{1};
            end
            state=IsKey(key);
            return
        case 'waitspace'
            % Waits for Space or Q
            state=WaitSpace();
            return
        case 'erasescreen'
            % Erases the screen with the given color (or the background)
            if(nargin<2)
                color=BACKCOLOR;
            else
                color=varargin{1};
            end
            EraseScreen(color);
            return
        case 'finishexp'
            % Finishes the experiment, closes NetStation and Horita link
            FinishExp();
            return
        case 'suspendexp'
            % Suspends an experiment (stops recording)
            SuspendExp();
            return;
        case 'resumeexp'
            % Resumes a suspended experiment (restarts recording)
            ResumeExp();
            return
        case 'pauseexp'
            % Pauses an experiment
            state=PauseExp();
            return;
        case 'standby'
            % Waits for Space or Q and starts the experiment in case of
            % Space
            state=Standby();
            return
        case 'checkpause'
            % Checks whether Esc is pressed. If yes, pauses the experiment
            state=CheckPause();
            return
        case 'startexp'
            state=StartExp();
            % Starts the experiment
            return
        case 'progress'
            % Displays a progress meter on the experiment screen
            if(nargin<2)
                percentage=0;
            else
                percentage=varargin{1};
            end
            if (nargin>=3)
                percentage=percentage/varargin{2}*100;
            end
            Gauge(percentage);
            return;
        otherwise
            error('Invalid command. Call "help ExpControl" to find out the available commands.');
            return;
    end
return

function ctrl=IsKey(key)
    global KEYBOARD;
    [keyIsDown,secs,keyCode]=PsychHID('KbCheck', KEYBOARD);
    if ~isnumeric(key)
        kc = KbName(key);
    else
        kc = key;
    end;
    ctrl=keyCode(kc);
return

function state=WaitSpace()
    QKEY=KbName('q');
    SPACEKEY=KbName('space');
    while 1
        if IsKey(QKEY)
            state=true;
%            while IsKey(QKEY)
%            end
            return;
        end
        if IsKey(SPACEKEY)
            state=false;
            return;
        end
    end
return

function time=EraseScreen(color)
    global EXPWIN;
    if(nargin<1)
        color=BlackIndex(EXPWIN);
    end
    Screen('FillRect',EXPWIN,color);
    time=Screen('Flip',EXPWIN);
return

function FinishExp()
    global EXPWIN;
    global EEG;
    global TITLER;
    
    if EEG, NetStation('StopRecording'); end;
    WaitSecs(1);
    if TITLER, Horita('Clear'); Horita('Close'); end;
    diary off;
    if EXPWIN >=0
        EraseScreen();
        Screen('CloseAll');
        EXPWIN=-1;
        ShowCursor();
    end
    if EEG, NetStation('Disconnect'); end;
return

function ResumeExp()
    global EXPWIN;
    global EEG;
    global TITLER;
    if EEG, NetStation('Synchronize'); end;
    if EEG, NetStation('StartRecording'); end;
    if TITLER, Horita('ClearLine',0); end;
return

function SuspendExp()
    global EEG;
    global TITLER;
    global BACKCOLOR;
    
    if EEG, NetStation('StopRecording'); end;
    EraseScreen(BACKCOLOR);
    if TITLER, Horita('ClearLine',0); end;
return

function state=Standby()
    fprintf('\nPress SPACE to start or Q to quit\n');
    Horita('ClearLine',0);
    Horita('Write',0,7,'PAUSE');
    if WaitSpace() 
        FinishExp();
        state=true;
        return
    else
        ResumeExp();
        state=false;
        return
    end
return

function state=PauseExp()
    SuspendExp();
    fprintf('\nPress SPACE to resume or Q to Quit\n');
    Horita('ClearLine',0);
    Horita('Write',0,7,'PAUSE');
    if WaitSpace() 
        FinishExp();
        state=true;
        return
    else
        ResumeExp();
        state=false;
        return
    end
return

function state=CheckPause()
    ESCKEY=41;
    if IsKey(ESCKEY)
        state=PauseExp();
        return
    end
    state=false;
return


function state=StartExp()

    global KEYBOARD;
    global EXPERIMENT;
    global SUBJECT;
    global BACKCOLOR;
    global NETSTATIONHOST;
    global EEG;
    global EXPWIN;
    global TITLER;
    global DEBUG;
    
    if isempty(DEBUG), DEBUG=0; end
    
    if isempty(EEG), EEG=false; end;
    if EEG, 
        if isempty(which('eeghost')),
            EEG=0;
        else
            eeghost; 
        end
    end

    if isempty(TITLER), TITLER=false; end;
    
    kb=GetKeyboardIndices;
    KEYBOARD=kb(1);
 
    if isempty(SUBJECT) || (SUBJECT == 0)
        fprintf('\n');
        SUBJECT=input('Subject number: ');
        fprintf('\n');
    end
    
    s=sprintf('%5.3f',SUBJECT/1000.);
    if isempty(EXPERIMENT)
        EXPERIMENT='TEST';
    end
    if SUBJECT > 0
        diary([EXPERIMENT '_' s(3:5) '.log']);
    end

    Screen('Preference','SkipSyncTests',1-DEBUG);
    Screen('Preference','SuppressAllWarnings',1-DEBUG);
    screens=Screen('Screens');
	screenNumber=max(screens);
    [EXPWIN, rect] = Screen('OpenWindow', screenNumber, 0,[],32, 2, 0);
    
    if isempty(BACKCOLOR)
        BACKCOLOR = BlackIndex(EXPWIN);
    end

    HideCursor();
    EraseScreen(BACKCOLOR);

    fprintf('\n****************************************\nExperiment %s\n',EXPERIMENT);
    fprintf('%s\n',datestr(now));
    fprintf('Subject %s\n\n',s(3:5));

    if EEG
        if isempty(NETSTATIONHOST)
            warning('NetStation host not given, disabling EEG recording');
            EEG=false
        else
            fprintf('Initializing NetStation connection on host %s\nPlease wait ...', NETSTATIONHOST);
            fprintf('\n');
            [status, msg] = NetStation('Connect',NETSTATIONHOST);
            if status>0
                fprintf('Connection failed: %s\n', msg);
                EEG=false;
            else
                fprintf('Synchronizing to NetStation, please wait...\n');
                NetStation('Synchronize');
            end
        end
    end
    
    if TITLER
        status=Horita('Open');
        if status, TITLER=false; end;
    end
    
    if TITLER    
        Horita('TimeOff');
        Horita('DateOff');
        Horita('DatePos',2,0);
        Horita('DateOn');
        Horita('ClearLine',0);
        Horita('ClearLine',1);
        exp=['         ' EXPERIMENT];
        exp=exp(length(exp)-8:length(exp));
        Horita('Write',2,11,exp);
        Horita('Write',1,0,'TR:');
        Horita('Write',1,14,'S:');
        Horita('Write',1,17,s(3:5));
    end
    
    state=false;
return

function Gauge(percentage)
    global BACKCOLOR;
    global EXPWIN;
    
    if ~isnumeric(percentage)
        error('Gauge: percentage must be numeric!');
    elseif percentage<0
        warning('Gauge: percentage must not be negative!');
        percentage=0;
    elseif percentage>100
        warning('Gauge: percentage must not be greater than 100!');
        percentage=100;
    end;
    
    [w, h] = Screen('WindowSize', EXPWIN);
    gaugerect = [w*0.25 h*0.45 w*0.75 h*0.55];
    fillrect = gaugerect;
    fillrect(3) = w*(0.25+0.005*percentage);
    
    Screen('FillRect',EXPWIN,BACKCOLOR);
    WHITECOLOR = WhiteIndex(EXPWIN);
    Screen('FrameRect', EXPWIN, WHITECOLOR, gaugerect);
    if fillrect(3)>fillrect(1)
        Screen('FillRect', EXPWIN, WHITECOLOR, fillrect);
    end;
    
    s=sprintf('%d%%', round(percentage));
    ts = Screen('TextSize', EXPWIN, floor(h*0.05));
    nbr = Screen('TextBounds', EXPWIN, s);
    x0 = (w-nbr(3))/2; y0 = (h-nbr(4))/2;
    Screen('DrawText', EXPWIN, s, x0, y0, [0 0 255]);
    Screen('TextSize', EXPWIN, ts);
    Screen('DrawingFinished', EXPWIN);
    Screen('Flip', EXPWIN);
return