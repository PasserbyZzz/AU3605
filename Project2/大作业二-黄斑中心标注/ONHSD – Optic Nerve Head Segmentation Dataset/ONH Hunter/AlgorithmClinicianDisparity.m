% AlgorithmClinicianDisparity
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Utility routine.
% Determines the per-spoke disparity between a given version of the
% algorithm (expressed in x,y points) and the clinician's hand-drawn perimeters.
% Service routine for GlobalClinicianDisparity and LocalClinicianDisparity

function disparity = AlgorithmClinicianDisparity( clinicianCentre, clinicianPoints, algorithmPoints )

% generate a more closely spaced version of the algorithm-determined perimeter
splineInterpolatedPoints = ClosedSpline( algorithmPoints, 0.1 );    

% Determine the angle of the spline-interpolated model points from the clinician-origin.
modelTheta = atan2( splineInterpolatedPoints(2,:)-clinicianCentre(2), splineInterpolatedPoints(1,:)-clinicianCentre(1) );

% for each clinician-spoke, find the spline-interpolated model point closest in angle. The length of this
% is used, leading to a disparity.
for i=1:24
    theta = (i-1) * pi / 12;
    
    for j=1:size(splineInterpolatedPoints,2)
        ab(j) = AngleBetween( modelTheta(j), theta );
    end
    
    % find closest angle; break ties arbitrarily
    [m ind] = find( ab == min(ab) );
    ind = ind(1);
    
    % get the clinician mean model point
    MX = clinicianCentre(1) + clinicianPoints(i) * cos(theta);
    MY = clinicianCentre(2) + clinicianPoints(i) * sin(theta);
    
    % use that one for the disparity
    disparity(i) = norm( [ splineInterpolatedPoints(1,ind)-MX splineInterpolatedPoints(2,ind)-MY ] );
end

