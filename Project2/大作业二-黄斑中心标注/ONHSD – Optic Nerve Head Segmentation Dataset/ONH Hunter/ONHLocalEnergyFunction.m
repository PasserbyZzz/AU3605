% ONHLocalEnergyFunction
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting service routine.
% Determine the energy function for a local model given by the centre and spoke displacements.
% This routine can be used in Quasi-Newton to optimize the local model.
% Near to / over image edges may return Inf to indicate that the optimization should not consider
% that location.

function Energy = ONHLocalEnergyFunction( P )

global ONHSpokeRatios; % elliptical adjustment ratios
global ONHAlpha;
global ONHGamma;

% break parameters out into centre and spoke distances
Centre = P(1:2);
S = P(3:size(P,2));

% number of spokes
N = size(P,2)-2;

% calculate the values needed to determine the energy function (a service function is used,
% as these same values are also used in the gradient)
[Pxy, m, mAv, mNeighAv, e, beta, gValue ] = ONHModelValues( Centre, S );

% If part of profile is entirely outside image, return infinite energy to disallow
% this configuration.
if isnan(mAv)
    Energy=Inf;
    return;
end

% in normalised space, calculate the energy function, based on the formula:
% E = Exy + Eext + beta . gamma . ( Eglobal + alpha . Elocal ) for spokes.
% Eext = Sum_i((m(i)-e(i))^2))/2.  External energy measures displacement from attractor points.
% Eglobal = Sum_i((m(i)^2-<m>(i)^2)/2. Global force measures displacement of model points from their average.
% Flocal = Sum_i(m(i)^2-m(i)<m>N(i))/2. Local force measures displacement of model points towards their local average.
% Exy = ((x-<px>)^2+(y-<py>)^2)/2. xy energy measures displacement of x,y from centroid of model points.
% The energies are combined using some weighting factors:
% beta - the stiffness factor. This is essentially a measure of global model confidence,
% and is used to weight the relative contributions of the external and internal forces.
% gamma - a user-supplied factor to weight external versus internal contribution.
% alpha - a user-supplied factor to weight global versus local contributions to internal
%         force (i.e. whether to follow global shape, or just maintain local smoothness).
% The ONHSpokeRatios^2 term compensates for the fact that the gradient should actually be w.r.t. the
% input (unnormalised) vector. We desire a force scaled by the aspect ratio, but 1/aspect drops out of
% the error function differentiation from the m terms, so we need aspect^2 to compensate.

% do the force calculations

Exy =  sum( (Centre - Pxy).^2 )/2;

Eext = ( (m-e).^2 ) / 2;

% calculate instantaneous version of energy
% for i=1:size(S,2)
%     Eext(i)=Eext(i)+SampleFirst(Centre,S(i));
% end

Eglobal = ( m-mAv ).^2 / 2;

Elocal = ( m-mNeighAv ).^2 / 2;

Erest = ( ONHSpokeRatios.^2 ) .* ( Eext + ONHGamma * beta .* ( Eglobal + ONHAlpha * Elocal ) );

%Erest = ( ONHSpokeRatios.^2 ) .* Elocal;

Exy = 0;

% concatenate xy and spoke forces for overall force vector
Energy = Exy + sum(Erest);
