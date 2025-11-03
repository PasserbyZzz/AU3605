% SampleFirst
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting utility
% Samples the first derivative magnitude at a given point in a given direction.
% Used in the direct "gradient vector" version of the algorithm, with no
% attractor points (currently not used in paper)

function Second = SampleFirst( Point, Theta )

% global stores the gradient image
global ONHGradientImageX;
global ONHGradientImageY;

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

XProfile = wx1 * wy1 * ONHGradientImageX(y,x) + wx2 * wy1 * ONHGradientImageX(y,x+1) + ...
    wx1 * wy2 * ONHGradientImageX(y+1,x) + wx2 * wy2 * ONHGradientImageX(y+1,x+1);
YProfile = wx1 * wy1 * ONHGradientImageY(y,x) + wx2 * wy1 * ONHGradientImageY(y,x+1) + ...
    wx1 * wy2 * ONHGradientImageY(y+1,x) + wx2 * wy2 * ONHGradientImageY(y+1,x+1);

% profile given by dot product of directed profile vector with radial direction vector.
Second = [XProfile YProfile] * directionVector';
