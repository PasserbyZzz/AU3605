% ONHGlobalEnergyFunction
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting service routine.
% Determine the energy function for a global model given by the centre and radius.
% This routine can be used in Quasi-Newton to optimize the global model.

function Energy = ONHGlobalEnergyFunction( P )

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

% If part of profile is entirely outside image, return infinite energy to disallow
% this configuration.
if isnan(mAv)
    Energy=Inf;
    return;
end

% xy energy
Exy =  sum( (Centre - Pxy).^2 )/2;

% radial energy
Eradial = (Radius-mean(e)).^2/2;

Energy = Exy + Eradial;