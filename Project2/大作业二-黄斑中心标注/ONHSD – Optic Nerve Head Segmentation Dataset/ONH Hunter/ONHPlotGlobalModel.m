% ONHPlotGlobalModel
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Graphing routine.
% ONHPlotGlobalModel plots a given global model onto the current image. The
% plot is an ellipse. The colour of the ellipse may also be specified.

function ONHPlotGlobalModel( Centre, Radius, AspectRatio, Color )

% setup default parameters
if nargin == 3
    Color = [ 1 1 0.5 ];
end

% Displaying the global model ellipse directly using the (bizarre, but true!) rectangle function
rectangle( 'Curvature', [1 1], 'Position', [ Centre(1)-Radius Centre(2)-Radius*AspectRatio Radius*2 (Radius*AspectRatio*2) ], 'EdgeColor', Color );
