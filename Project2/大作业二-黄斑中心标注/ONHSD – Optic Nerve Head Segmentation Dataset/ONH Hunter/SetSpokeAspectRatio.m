% SetSpokeAspectRatio
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting utility.
% SetSpokeAspectRatio - determine the ratios used to adjust to an elliptical rather than
% circular model, with a given aspect ratio, and stores globally

function SetSpokeAspectRatio( aspectRatio )

global ONHSpokeThetas; % array of the angles of the sampled spokes
global ONHSpokeRatios;      % the calculated ratios
global ONHAspectRatio;      % aspect ratio of the model

% store the aspect ratio
ONHAspectRatio = aspectRatio;

noSpokes = size( ONHSpokeThetas, 2 );

ONHSpokeRatios = 0;

% calculate the ratio along each spoke. these are used to adjust forces.
for i=1:noSpokes
    ONHSpokeRatios(i) = norm( [ cos( ONHSpokeThetas(i) ), ONHAspectRatio * sin( ONHSpokeThetas(i) ) ] );
end
