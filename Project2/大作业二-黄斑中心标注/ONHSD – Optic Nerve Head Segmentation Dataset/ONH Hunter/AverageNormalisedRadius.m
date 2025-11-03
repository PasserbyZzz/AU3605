% AverageNormalisedRadius - determine the average radius given distances along spokes, adjusting
% for the elliptical model shape.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

function radius = AverageNormalisedRadius( S )

global ONHSpokeRatios;

radius = mean( S ./ ONHSpokeRatios );
