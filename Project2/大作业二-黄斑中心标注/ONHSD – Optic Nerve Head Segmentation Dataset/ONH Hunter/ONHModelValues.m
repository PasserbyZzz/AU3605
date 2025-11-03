% ONHModelValues
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting service routine.
% ONHModelValues calculates a variety of values from the given model (centre point and spoke
% displacements) that are used in gradient and energy function calculations.
% Service routine for gradient and energy function calculation routines, both local and global

function [Pxy, m, mAv, mNeighAv, e, beta, gValue ] = ONHModelValues( Centre, S )

global ONHSpokeThetas; % array of the angles of the sampled spokes
global ONHSpokeRatios; % ratios of the spokes for normalisation
global ONHInnerRange; % search size from average radius, back towards centre
global ONHOuterRange; % search size from average radius, outwards
global ONHNeighborhoodSize; % global giving neighborhood size.
                            % other spokes within +- this "radius" are considered
                            % neighbors. Note that the definition is circular.
global ONHGradientImage;
global ONHInnerMinimum;
global ONHOuterMaximum;
global ONHRobustThreshold;

Pxy = [ 0 0];

% normalise model position
m = S ./ ONHSpokeRatios;

% calculate the average normalised model displacement.
mAv = mean(m);

% calculate position of the global model
GlobalS = mAv * ONHSpokeRatios;

% Choose the search range, by bounding the requested range between the permitted minimum and maximum.
% This prevents the model from converging to absurd points
SLower = GlobalS-ONHInnerRange * ONHSpokeRatios;
SUpper = GlobalS+ONHOuterRange * ONHSpokeRatios;
SLower = max( SLower, ONHInnerMinimum * ONHSpokeRatios );
SUpper = min( SUpper, ONHOuterMaximum * ONHSpokeRatios );

% Process each spoke in turn
i=0;
for theta = ONHSpokeThetas
    i = i+1;
    
    % work out force point along the radial line. The search is conducted within a restricted range about
    % the current model point.
    spokeForce(i) = RadialExternalForce( Centre, SLower(i), SUpper(i), theta );
end

% check for spokes entirely out of range => invalid position. Signal to caller by setting mAv to NaN.
% other parameters zeroed to suppress annoying warnings
if sum(isnan(spokeForce)) > 0
    mAv=NaN;
    Pxy=0;
    m=0;
    mNeighAv=0;
    e=0;
    beta=0;
    return;
end

% normalise spoke forces to circular model, and normalise model position similarly
% e = external attractor point, m = model point
e = spokeForce ./ ONHSpokeRatios;

% identify outliers and reset to global model position, for robust performance at occasional
% outlying points
eAv = mean(e);
eNormed = (e-eAv)/eAv;
outliers = eNormed.^2 > ONHRobustThreshold^2;
e = e .* ( 1-outliers) + eAv * outliers;
spokeForce = e .* ONHSpokeRatios;

% now calculate the centroid that would correspond to the forces, if they satisfied
% the global model shape.
i=0;
for theta = ONHSpokeThetas
    i = i+1;
    
    % get the gradient value at the force point. The radial profile routine gets abused here to
    % generate a length 1 profile. The gradient is calculated by bilinear interpolation.
    gValue(i) = MakeRadialProfile( Centre, spokeForce(i), spokeForce(i), theta );    
    
    % work out x,y position of the force (force point minus "global" model; i.e. deformation to force points)
    position = Centre + ( spokeForce(i) - mAv * ONHSpokeRatios(i) ) .* [ cos(theta) sin(theta) ];
    
    % Accumulate the force centroid
    Pxy = Pxy + position;
end

% calculate the force position centroid in xy coordinates. This is used for the xy forces
Pxy = Pxy / i;

% calculate the local neighborhood average normalised model displacement
mNeighAv = LocalNeighborAverage(m,ONHNeighborhoodSize);

% calculate stiffness values from the gradient strength at the force points.
% these are used to up-weight parts of the model with a strong edge.
beta = StiffnessVector( gValue, 1.5 );
