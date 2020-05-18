function saccades = sacV(data, info, t, threshold)
% function saccades = fixV (data, info, t, threshold)
%
% bETk private function for calculating saccades based on velocity.
% Use getSaccades with the 'V' marker instead.
% 
% This is very simple.
%
% mcf 6/11/06

% get the distances and convert to v in degrees/sec
X = data(:,1); Y = data(:,2);
dX = diff(X); dY = diff(Y);
d = sqrt(dX.^2 + dY.^2);
d = d ./ info.pixelsPerDegree;
dt = double(diff(t));
v = [0; d ./ (dt / 1000)];
saccades = v > threshold; % mark saccades with 1

% note that this code also appears in fixV (but it's so similar that it
% seemed like a shame to call it twice. 
