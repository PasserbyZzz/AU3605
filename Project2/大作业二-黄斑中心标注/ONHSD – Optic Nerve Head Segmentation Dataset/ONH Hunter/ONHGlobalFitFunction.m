% ONHGlobalFitFunction
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting service function.
% Return a fitness value for a proposed global model. Used in the grid-search
% (which in fact was rejected from the final algorithm and not reported in the
% paper, but is retained in case of later reversion).
% Basically this routine returns the total gradient magnitude at the attractor points

function Fit = ONHGlobalFitFunction( P )

global ONHSpokeRatios; % elliptical adjustment ratios

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

% If part of profile is entirely outside image, return fit value to disallow
% this configuration.
if isnan(mAv)
    Fit=Inf;
    return;
end

% fitness is the sum of the gradient values
Fit = sum(gValue);
