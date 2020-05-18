function fixlist = fixV(data, info, t, threshold)
% function [data, fix, sac] = fixV (data, info, t, threshold)
%
% bETk private function for calculating fixations based on velocity.
% Use getFixations with the 'V' marker instead.
% 
% This is the simplest fixation finding algorithm I could think of.
% Everything in between saccades is a fixation. 
%
% mcf 5/25/06

% get the distances and convert to v in degrees/sec
X = data(:,1); Y = data(:,2);
dX = diff(X); dY = diff(Y);
d = sqrt(dX.^2 + dY.^2);
d = d ./ info.pixelsPerDegree;
dt = double(diff(t));
v = d ./ (dt / 1000);

% now derive fixlist from v
f_begin = v > threshold; % mark saccades (e.g. fixation beginnings) with 1
f_begin = [1; f_begin(2:end)];
f_end = v > threshold;
f_end = [f_end(2:end); 1] .* -1;

% fixlist is just beginnings and endings
fixlist = f_begin + f_end;