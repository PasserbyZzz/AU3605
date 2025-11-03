% ClosedSpline.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Utility for drawing.
% Generates spline points with given spacing for a closed spline,
% i.e. makes the end point the same as the start-point.

function Result = ClosedSpline( pts, spacing )

N = size(pts,1);

% Create new array with start point wrapped around
spts = [ pts ; pts( 1, : ) ];

% generate the spline points using the standard MATLAB function
Result = spline(1:N+1,spts',1:spacing:N+1);
