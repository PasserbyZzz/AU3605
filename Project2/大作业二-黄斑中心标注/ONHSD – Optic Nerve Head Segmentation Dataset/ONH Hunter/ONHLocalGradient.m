% ONHLocalGradient
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting service routine
% This routine determines the gradient of the parameter vector for the local model.
% It is provided to the gradient descent or quasi-newton routines to optimize the
% model.
% It is passed a parameter vector containing the centre and spoke displacements, and passes back
% corresponding gradient.
% It may fail close to edges of the image, in which case a gradient of zero is returned
% to stop the optimization routine.

function Gradient = ONHLocalGradient( P )

global ONHSpokeRatios; % elliptical adjustment ratios
global ONHAlpha;
global ONHGamma;
global ONHNeighborhoodSize;

% break parameters out into centre and spoke distances
Centre = P(1:2);
S = P(3:size(P,2));

% calculate the values needed to determine the gradient (a service function is used,
% as these same values are also used in the energy function)
[Pxy, m, mAv, mNeighAv, e, beta, gValue ] = ONHModelValues( Centre, S );

% if part of profile entirely out of range, return zero gradient to prevent further
% motion.
if isnan(mAv)
    Gradient = zeros(size(P));
    return;
end

% now calculate the forces
% in normalised space, calculate the gradient, based on the formula:
% F = Fext + beta . gamma . ( Fglobal + alpha . Flocal ) for spokes, and = Fxy for xy.
% Fext = m(i)-e(i).  External force pulls the model towards the attractor point.
% Fglobal = m(i)-<m>(i). Global force pulls model points towards their average.
% Flocal = m(i)-<m>N(i). local force pulls model points towards their local average.
% Fxy = ( [x y] - <[px py]>. xy force pulls x,y towards model centroid.
% The forces are combined using some weighting factors:
% beta - the stiffness factor. This is essentially a measure of global model confidence,
% and is used to weight the relative contributions of the external and internal forces.
% gamma - a user-supplied factor to weight external versus internal contribution.
% alpha - a user-supplied factor to weight global versus local contributions to internal
%         force (i.e. whether to follow global shape, or just maintain local smoothness).

Fxy =  Centre - Pxy;

Fext = m-e;
Fglobal = (m-mAv) - mean(m-mAv);
Flocal = m-mNeighAv - LocalNeighborAverage( m-mNeighAv, ONHNeighborhoodSize );

% calculate instantaneous version of external gradient
% This version does gradient flow without attractor points
% for i=1:size(S,2)
%     Fext(i)=SampleSecond(Centre,S(i));
% end

Frest = Fext + ONHGamma * beta .* ( Fglobal + ONHAlpha * Flocal );

%Frest = Flocal;

% now denormalize the gradient back to elliptical coordinates
Frest = Frest .* ONHSpokeRatios;

Fxy = [0 0];

% concatenate xy and spoke forces for overall force vector
Gradient = [ Fxy Frest ];
