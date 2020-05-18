function [Epnts, FixatText, CalibText, SoundNov, LSoundNov, SoundCNov, AbstText ] = InitDrawEyes( win, res, FixatPath, STrackPath, SLTrackPath, CalibPath, SCTrackPath, maxC, AbstPath )
%maxC - > number of calibration points

%max pictures to load
maxP = 10;

%max sounds to open
maxS = 10;

%max long sounds to open
maxLS = 1;

%max abstract pictures & sounds 
maxA = 6;

%calculate ellipse
Cen = [res(1)/2,res(2)/2];
a = 200;
b = 200;
f1 = [res(1)/2,res(2)/2+a/2];
f2 = [res(1)/2,res(2)/2-a/2];
steps = 500;
Epnts = CalcEllipse( Cen, a, b, f1, f2, steps);

%load picture filenames
pic_ext = '.jpg';
path = FixatPath;
DD = dir(path);
count = 1;
for j=1:length(DD)
    [tmpPath, tmpname, ext, tmpv] = fileparts( DD(j).name );
    if ( strcmp( lower(ext), pic_ext) )
        pictFil{count} = fullfile(path,DD(j).name);
        %store_name
        FixatName{count} = DD(j).name;
        count = count+1;
    end
end
FixatNum = length(FixatName);

RandFix = randperm(FixatNum);

%load maxPic and pass the handles
MmP = min([maxP, FixatNum]);
for i=1:MmP
        %load picture 
        tmpName = pictFil{ RandFix(i) };
        FixatPict = imread(tmpName);
        FixatText(i) = Screen('MakeTexture', win, FixatPict);
end


%load calibration pictures names
pic_ext = '.jpg';
path = CalibPath;
DD = dir(path);
count = 1;
for j=1:length(DD)
    [tmpPath, tmpname, ext, tmpv] = fileparts( DD(j).name );
    if ( strcmp( lower(ext), pic_ext) )
        CalibFil{count} = fullfile(path,DD(j).name);
        %store_name
        CalibName{count} = DD(j).name;
        count = count+1;
    end
end
CalibNum = length(CalibFil);

RandCal = randperm(CalibNum);

%load maxPic and pass the handles
MmC = min([maxC, CalibNum]);
for i=1:MmC
        %load picture 
        tmpName = CalibFil{ RandCal(i) };
        CalPict = imread(tmpName);
        CalibText(i) = Screen('MakeTexture', win, CalPict);
end


% load sound names
s_ext = '.wav';
path = STrackPath;
DD = dir(path);
count = 1;
for j=1:length(DD)
    [tmpPath, tmpname, ext, tmpv] = fileparts( DD(j).name );
    if ( strcmp( lower(ext), s_ext) )
        soundFil{count} = fullfile(path,DD(j).name);
        SoundTrackNames{count} = DD(j).name;
        count = count+1;
    end
end
SoundNum = length(SoundTrackNames);
%RandSound = randperm(SoundNum);
RandSound = SoundNum:-1:1;

%load maxS and pass handles
MmS = min( [maxS SoundNum] );

for i=1:MmS
    SoundNov{i} = Screen( 'OpenMovie', win, soundFil{ RandSound(i) } );  
    disp( soundFil{ RandSound(i) } );
end


% load calibration's sound names
s_ext = '.wav';
path = SCTrackPath;
DD = dir(path);
count = 1;
for j=1:length(DD)
    [tmpPath, tmpname, ext, tmpv] = fileparts( DD(j).name );
    if ( strcmp( lower(ext), s_ext) )
        soundCFil{count} = fullfile(path,DD(j).name);
        SoundCTrackNames{count} = DD(j).name;
        count = count+1;
    end
end
SoundCNum = length(SoundCTrackNames);
%RandSound = randperm(SoundNum);
RandSoundC = SoundCNum:-1:1;

%load maxS and pass handles
MmS = min( [maxS SoundCNum] );

for i=1:MmS
    SoundCNov{i} = Screen( 'OpenMovie', win, soundCFil{ RandSoundC(i) } );  
    disp( soundFil{ RandSoundC(i) } );
end

%load long sounds names
s_ext = '.wav';
path = SLTrackPath;
DD = dir(path);
count = 1;
for j=1:length(DD)
    [tmpPath, tmpname, ext, tmpv] = fileparts( DD(j).name );
    if ( strcmp( lower(ext), s_ext) )
        LsoundFil{count} = fullfile(path,DD(j).name);
        LSoundTrackNames{count} = DD(j).name;
        count = count+1;
    end
end
LSoundNum = length(LSoundTrackNames);
LRandSound = randperm(LSoundNum);


%load maxS and pass handles
MmLS = min( [maxLS LSoundNum] );

for i=1:MmLS
    LSoundNov{i} = Screen( 'OpenMovie', win, LsoundFil{LRandSound(i)} );  
    disp(LsoundFil{LRandSound(i)});
end


%Load abstract pictures
pic_ext = '.jpg';
path = AbstPath;
DD = dir(path);
count = 1;
for j=1:length(DD)
    [tmpPath, tmpname, ext, tmpv] = fileparts( DD(j).name );
    if ( strcmp( lower(ext), pic_ext) )
        AbstFil{count} = fullfile(path,DD(j).name);
        %store_name
        AbstName{count} = DD(j).name;
        count = count+1;
    end
end
AbstNum = length(AbstFil);

RandAbst = randperm(AbstNum);

%load maxA and pass the handles
for i=1:maxA
        %load picture 
        tmpName = AbstFil{ RandAbst(i) };
        AbstPict = imread(tmpName);
        AbstText(i) = Screen('MakeTexture', win, AbstPict);
end





