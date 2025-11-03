% ONHModelPointXYs
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Utility routine for drawing and analysis
% function ONHModelPointXYs converts a given centre position
% plus radial displacements (the standard form for storing the 
% ONH model) into the (x,y) locations of same.

function Pts = ONHModelPointXYs( Centre, M )

global ONHSpokeThetas; % angles of the spokes

Pts = [ Centre(1) + M .* cos( ONHSpokeThetas ); Centre(2) + M .* sin( ONHSpokeThetas ) ];
