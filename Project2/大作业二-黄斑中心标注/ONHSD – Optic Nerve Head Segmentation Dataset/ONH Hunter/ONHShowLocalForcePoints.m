% ONHShowLocalForcePoints
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Graphing utility
% This routine plots the attractor (force) points with a given local model.
% A useful utility for visualizing the algorithm's performance

function ONHShowLocalForcePoints( Centre, Spokes, Color )

global ONHSpokeRatios;

% default color
if nargin == 2
    Color = [ 1 0.2 0.2 ];
end

% calculate the values needed to determine the gradient (a service function is used,
% as these same values are also used in the energy function)
[Pxy, m, mAv, mNeighAv, e, beta ] = ONHModelValues( Centre, Spokes );

ONHPlotLocalModel( Centre, e .* ONHSpokeRatios, Color, 1 );