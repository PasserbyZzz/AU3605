% MakeRadialProfile
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting service routine.
% Calculates a 1D profile from offset Start to End
% centred at (CX,CY) in the gradient image, taken at angle theta.
% The profile may be based on either the gradient magnitude, or directed
% gradient, depending on the setting of the ONHUse2DGradient flag.

function TheProfile = MakeRadialProfile( Centre, Start, End, Theta )

% global stores the gradient image
global ONHGradientImage;
global ONHGradientImageX;
global ONHGradientImageY;
global ONHUse2DGradient;

% for debug
[YMax XMax] = size(ONHGradientImage);

directionVector = [ cos(Theta), sin(Theta) ];

% sample points at unit intervals
j=0;
for i=Start:End
    j = j +1;
    
  % calculate coordinates of profile point in image 
  p = Centre + i * directionVector;
  x = p(1);
  y = p(2);
  
%  x = i * cos(Theta) + CX;
%  y = i * sin(Theta) + CY;

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
  
  if ONHUse2DGradient == 0  
      % calculate the profile point using bilinear interpolation
      TheProfile(j) = wx1 * wy1 * ONHGradientImage(y,x) + wx2 * wy1 * ONHGradientImage(y,x+1) + ...
          wx1 * wy2 * ONHGradientImage(y+1,x) + wx2 * wy2 * ONHGradientImage(y+1,x+1);
  else
      
      if x < 1 | x > XMax-1 | y < 1 | y > YMax-1
          dummy=1;
      end
      
       XProfile(j) = wx1 * wy1 * ONHGradientImageX(y,x) + wx2 * wy1 * ONHGradientImageX(y,x+1) + ...
           wx1 * wy2 * ONHGradientImageX(y+1,x) + wx2 * wy2 * ONHGradientImageX(y+1,x+1);
       YProfile(j) = wx1 * wy1 * ONHGradientImageY(y,x) + wx2 * wy1 * ONHGradientImageY(y,x+1) + ...
           wx1 * wy2 * ONHGradientImageY(y+1,x) + wx2 * wy2 * ONHGradientImageY(y+1,x+1);

      % profile given by dot product of directed profile vector with radial direction vector.
      TheProfile(j) = [XProfile(j) YProfile(j)] * directionVector';
  end
end
