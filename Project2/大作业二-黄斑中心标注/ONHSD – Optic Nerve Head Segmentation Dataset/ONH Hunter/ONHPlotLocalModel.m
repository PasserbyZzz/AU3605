% ONHPlotLocalModel
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Graphing routine.
% Plots a given local model onto the current image. The
% plot may be either an interpolated closed cubic spline, or a set of
% markers (crosses). The colour of the plot line / markers may also
% be specified.

function ONHPlotLocalModel( Centre, P, Color, markers )

global ONHSpokeThetas;

noSpokes=24;

% set spokes at regular angles covering full circle
ONHSpokeThetas = ( [1:noSpokes] * 2 * pi ) / noSpokes; 

Pts = ONHModelPointXYs( Centre, P );

% setup default parameters
if nargin == 2
    markers=0;
    Color = [ 1 1 0.5 ];
end
if nargin == 3
    markers=0;
end

if markers == 0
   plotPts = ClosedSpline( Pts', 0.1 );
   line( plotPts(1,:), plotPts(2,:), 'Color', Color, 'LineStyle', '-' ); 
else
   line( Pts(1,:), Pts(2,:), 'Color', Color, 'LineStyle', 'none', 'Marker', 'x' ); 
end



