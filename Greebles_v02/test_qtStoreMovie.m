close all;
clear all;

outPicDir = './picts_rot';
extPic = '.jpeg';
movieName = 'greeble_rot.mov';

imgwidth = 1024;
imgheight = 768;

inputPathEvents = './events_rot.txt';

%check for pictures
path = outPicDir;
DD = dir(path);
count = 1;
for j=1:length(DD)
    [tmpPath, tmpname, ext] = fileparts( DD(j).name );
    if ( strcmpi( ext, extPic) )
        pictFil = fullfile(path,DD(j).name);
        %store_name
        names{count} = DD(j).name;
        fullNames{count} = pictFil;
        count = count+1;
    end
end

%make sure that they are sorted correctly
for i=1:length(names)
    filenametmp = names{i};
    Uscore = findstr(filenametmp,'_');
    Dot = findstr(filenametmp,'.');
    numtmp(i) = str2num( filenametmp( (Uscore(1)+1) : (Dot(1)-1) ) );    
end
[S,Index] = sort(numtmp);
fullNamesNew = fullNames(Index(1:end));


%pass movie name, imgwidth, imgheight, and pictures' filenames 
%qtStoreMovie_v04('SAVE_MOVIE',movieName, imgwidth, imgheight,fullNamesNew);

%load events
[StartTime TimeLine Events] = ReadEvents( inputPathEvents );

timeTmp = TimeLine(:,1)-TimeLine(1,1);
durTmp = diff(timeTmp);
movieFramTimDur = [ timeTmp [durTmp;durTmp(end)] ];


%pass movie name, imgwidth, imgheight, and pictures' filenames,
%starting time and duration of each frame
qtStoreMovie_v05('SAVE_MOVIE',movieName, imgwidth, imgheight,fullNamesNew, movieFramTimDur );
