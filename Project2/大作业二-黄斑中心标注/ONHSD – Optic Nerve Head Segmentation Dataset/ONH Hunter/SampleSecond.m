% SampleSecond
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting utility
% Samples the second derivative magnitude at a given point along a given
% direction, using the LaPlacian stored in globals.
% Used for the "no attractors" version, which is not currently in use.

function Second = SampleSecond( Point, Theta )

% global stores the gradient image
global ONHSecondDerivativeImageXX;
global ONHSecondDerivativeImageYY;

directionVector = [ cos(Theta), sin(Theta) ];

% calculate coordinates of profile point in image 
x = Point(1);
y = Point(2);

% calculate weightings for the four pixels potentially involved
% in calculating the profile point
if floor(x) == x
    wx1 = 1.0;
    wx2 = 0.0;
else
    wx1 = ceil(x) - x;
    wx2 = x - floor(x);
end

if floor(y) == y
    wy1 = 1.0;
    wy2 = 0.0;
else
    wy1 = ceil(y) - y;
    wy2 = y - floor(y);
end

x = floor(x);
y = floor(y);

XProfile = wx1 * wy1 * ONHSecondDerivativeImageXX(y,x) + wx2 * wy1 * ONHSecondDerivativeImageXX(y,x+1) + ...
    wx1 * wy2 * ONHSecondDerivativeImageXX(y+1,x) + wx2 * wy2 * ONHSecondDerivativeImageXX(y+1,x+1);
YProfile = wx1 * wy1 * ONHSecondDerivativeImageYY(y,x) + wx2 * wy1 * ONHSecondDerivativeImageYY(y,x+1) + ...
    wx1 * wy2 * ONHSecondDerivativeImageYY(y+1,x) + wx2 * wy2 * ONHSecondDerivativeImageYY(y+1,x+1);

% profile given by dot product of directed profile vector with radial direction vector.
Second = [XProfile YProfile] * directionVector';
