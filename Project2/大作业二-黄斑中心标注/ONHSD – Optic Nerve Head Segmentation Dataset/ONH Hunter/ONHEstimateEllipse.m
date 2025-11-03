% ONHEstimateEllipse
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Service routine for global modelling.
% Estimate the best-fitting ellipse from a set of spoke displacements.
% Used in re-estimation of the aspect ratio.

function [ newRadius, newAspectRatio ] = ONHEstimateEllipse( spokes )

global ONHSpokeThetas;

% accumulate square discrepancy moderated for number of participating points,
% and normalisation factors;
Xsquare=0;
Ysquare=0;
Xnorm=0;
Ynorm=0;
for i=1:size(spokes,2)
    theta = ONHSpokeThetas(i);
    
    Xsquare = Xsquare + ( spokes(i) * cos(theta) )^2;
    Ysquare = Ysquare + ( spokes(i) * sin(theta) )^2;
    Xnorm = Xnorm + (cos(theta))^2;
    Ynorm = Ynorm + (sin(theta))^2;
end

newRadius = sqrt( Xsquare / Xnorm );
newAspectRatio = sqrt( Ysquare / Ynorm ) / newRadius;
