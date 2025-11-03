% ONHGlobalGradient
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting service routine
% This routine determines the gradient of the parameter vector for the global model.
% It is provided to the gradient descent or quasi-newton routines to optimize the
% model.
% It is passed a parameter vector containing the centre and radius, and passes back
% corresponding gradient.
% It may fail close to edges of the image, in which case a gradient of zero is returned
% to stop the optimization routine.

function Gradient = ONHGlobalGradient( P )

global ONHSpokeRatios; % elliptical adjustment ratios
global ONHFixedRadius;

% break parameters out into centre and radius
Centre = P(1:2);
Radius = P(3);

% calculate spoke points of current model.
S = ONHSpokeRatios * Radius;

% calculate the values needed to determine the gradient (a service function is used,
% as these same values are also used in the energy function)
% most of these values are irrevalent during global model fit (the service routine
% below is shared with the global fit procedures).
[Pxy, m, mAv, mNeighAv, e, beta, gValue ] = ONHModelValues( Centre, S );

% if part of profile entirely out of range, return zero gradient to prevent further
% motion.
if isnan(mAv)
    Gradient = zeros(size(P));
    return;
end

% determine x,y force
Fxy =  Centre - Pxy;

% determine radial force
if ONHFixedRadius
    Fradial=0;
else
   Fradial = Radius-mean(e);
end

% concatenate xy and radial force for overall force vector
Gradient = [ Fxy Fradial ];
