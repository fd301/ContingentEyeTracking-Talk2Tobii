function [fix, sac] = findFixAndSac(data, NEinfo, info, t, fixlist)
% function [fix, sac] = findFixAndSac (info, fixlist)
%
% function for calculating fixations and saccades.
%

% get the distances and convert to v in degrees/sec, just like fixV
X = data(:,1); Y = data(:,2);
dX = diff(X); dY = diff(Y);
d = sqrt(dX.^2 + dY.^2);
d = d ./ info.pixelsPerDegree;
d = [0; d];
dt = [0; diff(t)];
v = [d .* dt];
a = [0; diff(v)];

index = 1:length(fixlist);
fbegin = index(fixlist == 1);
fend = index(fixlist == -1);

% gather information about each fixation and saccade
for i = 1:length(fbegin)
    if i ~= 1 % there isn't a first saccade, just a first fixation
        sac_elem(i-1) = fbegin(i);
        sac_from(i-1,:) = data(fbegin(i),:);
        sac_to(i-1,:) = data(fbegin(i)+1,:);
        sac_v(i-1) = v(fbegin(i));
        sac_a(i-1) = a(fbegin(i));
        travel = sac_from(i-1,:) - sac_to(i-1,:);
        sac_dist(i-1) = sqrt(travel(1)^2 + travel(2)^2) / info.pixelsPerDegree;
    end;
    fix_length(i) = t(fend(i)) -  t(fbegin(i)); 
    fix_elem(i,:) = [fbegin(i) fend(i)];
    fix_meanpos(i,:) = [nanmean(data(fbegin(i):fend(i),1)) nanmean(data(fbegin(i):fend(i),2))];
    fix_stdpos(i,:) =  nanstd(d(fbegin(i):fend(i)));
end;

fix = { fix_length, fix_elem, fix_meanpos, fix_stdpos };
sac = { sac_elem, sac_from, sac_to, sac_v, sac_a, sac_dist };

% null saccade
% if ~exist('sac')
%     sac(1).null = 1;
% else
%     sac(1).null = 0;
% end;

