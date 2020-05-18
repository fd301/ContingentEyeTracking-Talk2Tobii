function store = orgFixSac_v2( inputPathEyeTracking, imageSize )
%extract saccades and fixations based on a velocity threshold.

%load eyetracking
EyeTrackingData = load(inputPathEyeTracking);
%info.imageSize = [1024 768];
info.imageSize = imageSize;
              
% extract saccades and fixations
distanceL = EyeTrackingData(:,15);
distanceR = EyeTrackingData(:,16);
% tobii does it in mm
info.meanDistFromTrackerCM = mean([mean(distanceL(distanceL > 0)) mean(distanceR(distanceR > 0))]) / 10;
info.stdDistFromTrackerCM = mean([std(distanceL(distanceL>0)) std(distanceR(distanceR>0))]) / 10;
% using this info, calculate the pixels per degree
CMperDegreeVisualAngle = tan(2*pi/360) * info.meanDistFromTrackerCM;
%pixelsPerCM = 19; % this is tobii specific, for the ET-17
pixelsPerCM = 38; % this is tobii specific, for the 1750 (Fani:I measured it myself)
info.pixelsPerDegree = pixelsPerCM * CMperDegreeVisualAngle; 

threshold = 35;

%valid data is when either/both left or right eye validity is 0
ConstEyeNF = -1;        %use this constant when eyes not found
len = length(EyeTrackingData);
indL = find( EyeTrackingData(:,11) == 0 );
indR = find( EyeTrackingData(:,12) == 0 );

t1 = zeros(len,1);
t2 = zeros(len,1);
t1(indL) = 1;
t2(indR) = 1;

t3 = t1 & t2;
t4 = t1 & (~t2);
t5 = (~t1) & t2;
t6 = (~t1) & (~t2);

indFBEyes = find(t3);
indFLEyes = find(t4);
indFREyes = find(t5);
indFNEyes = find(t6);

data = ones(len,2)*ConstEyeNF;
data(indFBEyes,:) = ( EyeTrackingData(indFBEyes,3:4) + EyeTrackingData(indFBEyes,5:6) )/2;
data(indFLEyes,:) = EyeTrackingData(indFLEyes,3:4);
data(indFREyes,:) = EyeTrackingData(indFREyes,5:6);

t = EyeTrackingData(:,1) + EyeTrackingData(:,2)/1000000;
tPsctool  = EyeTrackingData(:,17);

%find start and end of not found eyes
tmpD = diff(indFNEyes);
tmpI = find(tmpD>1);
NEinfo = [indFNEyes'  indFNEyes(tmpI+1)'-1];

fixlist = fixV(data, NEinfo, info, t, threshold);
[fix, sac] = findFixAndSac_v02(data, NEinfo, info, t, fixlist);

%estimate a list of lines and circles that should be painted on top 
%estimate characteristics for sampling points:

%for i=1:IndexSamples    
%end
fix_elem = fix{2};
sac_elem = sac{1};

fix_length = fix{1};
fix_meanpos = fix{3};
sac_from = sac{2};
sac_to = sac{3};

t1 = t-t(1);
for i=1:length(t1)
    % is i a saccade
    store(i).t = [t1(i) tPsctool(i)];
        
    indexSac = find( sac_elem==i );
    if( ~isempty(indexSac) )
        store(i).type = 'sac';
        store(i).from = sac_from(indexSac,:);
        store(i).to = sac_to(indexSac,:);
        
        store(i).radius = 0;
        store(i).meanpos = [0 0];
    elseif( ~isempty( find(i==indFNEyes) ) )
        store(i).type = 'EyesNotFound';
        store(i).radius = 0;
        store(i).meanpos = [0 0];
        store(i).from = [0 0];
        store(i).to = [0 0];
    else
        %look for a fixation
        indexFix = find( fix_elem(:,1) <= i  );
        if( isempty(indexFix) )
            error('error in input data');
        end
        indexFix = indexFix(end);
        if( fix_elem(indexFix,2)< i) %there is no fixation or saccade
            store(i).type = 'nan';
            store(i).radius = 0;
            store(i).meanpos = [0 0];
        else
            store(i).type = 'fix';
            store(i).radius = i-fix_elem(indexFix,1);
            tmp = fix_elem(indexFix):i;
%            [indX indY] = find( data(tmp,1)<0 && data(tmp,2)<0 );
            store(i).meanpos = [ nanmean( data( tmp, 1 ) )   nanmean( data( tmp, 2) )];
            
%             if( sqrt( (store(i).meanpos(1) - data(i,1) )^2 + ( store(i).meanpos(2) - data(i,2) )^2 ) > 0.01 )
%                 store(i).meanpos = data(
%             end
        end
        
        store(i).from = [0 0];
        store(i).to = [0 0];
        
    end
    
end

return;


% h = figure(1);
% axis([0 info.imageSize(1) 0 info.imageSize(2)]);
% 
% %normalise fix_length
% MinFix_len = min(fix_length);
% MaxFix_len = max(fix_length);
% MinMy = 100;
% MaxMy = 1000;
% for i = 1:length(fix_length)
%     hold off;
%     %s = fix(i).stdpos * info.pixelsPerDegree;
%     s = fix_length(i);
%     s = (MaxMy-MinMy)*(s-MinFix_len)/(MaxFix_len-MinFix_len)+MinMy;
%     store(i).s = s;
%     store(i).fix = [fix_meanpos(i,1)*info.imageSize(1) fix_meanpos(i,2)*info.imageSize(2)];
%     
%     rectangle('Position',[fix_meanpos(i,1)*info.imageSize(1) fix_meanpos(i,2)*info.imageSize(2) s s], ...
%         'Curvature',[1 1],'FaceColor','r');
%     
%     if ( i < length(sac_from) )
%         lx = [sac_from(i,1) sac_to(i,1)];
%         ly = [sac_from(i,2) sac_to(i,2)];
%         store(i).line = [lx*info.imageSize(1) ly*info.imageSize(2)];
%         line(lx*info.imageSize(1),ly*info.imageSize(2))
%     else
%         store(i).line = [0 0 ];
%     end
%     refresh(h);
%     pause(0.2);
%     i
% end
%     
% axis ij;
% axis off;
% hold off;
%     
