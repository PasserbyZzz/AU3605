% RadialExternalForce
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting utility
% Determines the radial force at a given angle from the
% given centre point, limited to within the radial range [Start,End]
% This is basically the radial displacement of the peak point along the radial
% line in the range [Start,End] (i.e. it returns the displacement of the attractor
% point along the spoke

function Force = RadialExternalForce( Centre, startRadius, endRadius, theta )

global ONHGradientImage;

[YMax XMax] = size(ONHGradientImage);

% $$$$$$$$$$$$$$$$$$$$$$$$$$$
% profiling version - not currently used
% % kernel to enhance edge detection in the appropriate direction (i.e. light-dark transfer
% % proceeding outwards from the ONH centre)
% edgeEnhancer = [0.7 0.7 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0 -0.1 -0.20 -0.3 -0.4 -0.5 -0.6 -0.7 -0.7 -0.7];

% % calculate amount of padding applied to convolving with edge enhancer
% eeSize = floor( size( edgeEnhancer, 2 ) / 2 );
% 
% % Make a radial profile in the desired range. It must extend beyond the range so that the
% % enhancement can be carried out correctly
% Profile = MakeRadialProfile( CX, CY, Start-eeSize, End+eeSize, Theta );
% 
% % Convolve with the edge enhancer, and then trim to non-padded size
% Enhanced = conv( Profile, edgeEnhancer ); 
% Enhanced = Enhanced( eeSize+eeSize+1 : size(Enhanced,2)-eeSize-eeSize );

% Find the location of the peak. In the event of a tie, choose the innermost (arbitrary choice)
% ML = find( Enhanced == min( Enhanced ) ); 
%
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

% calculate end point of spoke. If its out of the image, recalculate the end radius to
% get back inside

endX = Centre(1) + endRadius * cos(theta);
endY = Centre(2) + endRadius * sin(theta);

if endX > XMax-1 
    endRadius = (XMax-Centre(1)-3)/cos(theta);
end
if endX < 1
    endRadius = (Centre(1)-2)/cos(theta);
end
if endY > YMax-1 
    endRadius = (YMax-Centre(2)-3)/sin(theta);
end
if endY < 1
    endRadius = (Centre(2)-2)/sin(theta);
end

% ditto start radius

startX = Centre(1) + startRadius * cos(theta);
startY = Centre(2) + startRadius * sin(theta);

if startX > XMax-1 
    startRadius = (XMax-Centre(1)-3)/cos(theta);
end
if startX < 1
    startRadius = (Centre(1)-2)/cos(theta);
end
if startY > YMax-1 
    startRadius = (YMax-Centre(2)-3)/sin(theta);
end
if startY < 1
    startRadius = (Centre(2)-2)/sin(theta);
end

% recalculate points
endX = Centre(1) + ceil(endRadius) * cos(theta);
endY = Centre(2) + ceil(endRadius) * sin(theta);
startX = Centre(1) + floor(startRadius) * cos(theta);
startY = Centre(2) + floor(startRadius) * sin(theta);

% do nothing if the force line is out of bounds (returns empty result)
if startRadius > endRadius | startX < 2 | startX > XMax-3 | startY < 2 | startY > YMax-3 | endX < 2 | endX > XMax-3 | endY < 2 | endY > YMax-3
    Force = NaN;
    return;
end

% debug - display position
%[Centre startRadius endRadius endX endY XMax YMax]

% make the profile within the specified range, and find the peak point.
% The use of floor is critical to ensure that, if the radius is changed fractionally,
% the distance alters too.
Profile = MakeRadialProfile( Centre, floor(startRadius), ceil(endRadius), theta );
ML = find( Profile == min( Profile ) );

% return the peak point displacement from the centre
Force = ML(1,1) + floor(startRadius) - 1;
