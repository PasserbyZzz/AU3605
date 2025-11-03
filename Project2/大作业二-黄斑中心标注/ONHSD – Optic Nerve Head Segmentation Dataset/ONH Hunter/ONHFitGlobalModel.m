% ONHFitGlobalModel
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Core fitting routine for the global model. Given an image and starting centre point, plus
% algorithm control parameters, fit the global model, and return its centre, radius and aspect ratio.

function [ newCentre, newRadius, newAspectRatio ] = ONHFitGlobalModel( Image, centre, startingAspectRatio, radius, erodeSize, aspectIterations, houghThreshold, temporal, gridsearch, twoD, polo1, polo2 )

global ONHSpokeThetas;
global ONHSpokeRatios;
global ONHAspectRatio;
global ONHSpokeThetas; % angles of spokes to be sampled
global ONHSpokeRatios;
global ONHInnerRange; % search size from average radius, back towards centre
global ONHOuterRange; % search size from average radius, outwards
global ONHNeighborhoodSize;
global ONHFixedRadius;
global ONHUse2DGradient;
global ONHInnerMinimum;
global ONHOuterMaximum;
global ONHRobustThreshold;
global ONHOutsideMask;

% global ONHDebugFigure;

% control constants
qnGTolerance=1e-6; % convergence of gradient descent
inner=10;
outer=10;
noSpokes=24;
temporalLimit = 4; % temporal edge defined by 2 times this plus 1 spokes (i.e. horizontal, plus above,below)
sigma = 5.0;

houghConfidenceThreshold=12;

ONHRobustThreshold=1;

% copy control parameters to globals
ONHInnerRange=inner;
ONHOuterRange=outer;
ONHNeighborhoodSize=0;

% figures for minimum and maximum model radius.
ONHInnerMinimum=25;
ONHOuterMaximum=60;

% generate mask used to identify retinal exterior
ONHOutsideMask = Image > 0.15;
ONHOutsideMask = imerode( ONHOutsideMask, strel( 'disk', 11 ) );

% specify use of 2D (directed) gradient rather than pure magnitude-based gradient
% this could be added to control parameters
ONHUse2DGradient=twoD;

% Apply morphological erosion of vessel
if erodeSize > 0
    Image = imclose( Image, strel( 'disk', erodeSize ) );
end 

% apply "polo" smoothing filter, then calculate gradient image
if polo1 > 0
   ONHSetGradientImage( OpticConv( Image, polo1 ), sigma );
else
   ONHSetGradientImage( Image, sigma );
end

% % DEBUG - store initial location and radius for later analysis
% ONHInitialLocation = centre;
% ONHInitialRadius = radius;
% 
% % DEBUG - store hough location and radius for later analysis
% % Need to initialize in advance in case hough isn't used - the variables
% % should still exist
% ONHHoughLocation = centre;
% ONHHoughRadius = radius;

% use circular hough transform to search for a better position.
if houghThreshold ~= 0
  [hCentre, hRadius, confidence] = ONHHoughFinder( Image, centre, houghThreshold );
  
  % only accept the Hough move if it is high enough confidence
  if confidence > houghConfidenceThreshold
    centre = hCentre;
    radius = hRadius;
  end
  
%   % DEBUG - store hough location and radius
%   ONHHoughLocation = centre;
%   ONHHoughRadius = radius;
end  

% set the centre points
Cx = centre(1);
Cy = centre(2);

% do the temporal-only part of the search
if temporal
    % Work out where the temporal spokes are. This depends whether the image is left or right temporal
    % the temporal edge is always nearer the centre of the image, so determine this using the start centre point
    % position.
    if Cx < 380
        temporalSamples = [ 0:temporalLimit noSpokes-temporalLimit:noSpokes-1 ];
    else
        temporalSamples = [ noSpokes/2+1-temporalLimit : noSpokes/2+1+temporalLimit ];
    end
    
    % fix radius for this stage
    ONHFixedRadius = 1;
    
    % set up spoke array to contain the temporal spokes
    ONHSpokeThetas = ( temporalSamples * 2 * pi ) / noSpokes;    
    
    % set the aspect ratio (this also sets up the ONHSpokeRatio vector used to adjust
    % between circular and elliptical displacements)
    SetSpokeAspectRatio( startingAspectRatio );

    % use gradient descent to find a better centre and radius. ONHGlobalGradient is the routine that works
    % out the gradient given a position and radius; GradientDescent is a generic gradient desecent procedure
    p = GradientDescent( [ Cx Cy radius ], 'ONHGlobalGradient', 0.15, 0.1, 0.1, 20 );
    
    % update model position with the new centre and radius
    Cx = p(1);
    Cy = p(2);
    radius = p(3);
    
%    ONHPlotGlobalModel( p(1:2), p(3) );
end

% % DEBUG - store post-temporal location and radius for later analysis
% ONHTemporalLocation = [Cx Cy];
% ONHTemporalRadius = radius;

% do grid-search
if gridsearch
    % use a small range to avoid getting sucked into the pallor
    ONHInnerRange=5;
    ONHOuterRange=5;
    
    % set spokes at regular angles covering full circle
    ONHSpokeThetas = ( [1:noSpokes] * 2 * pi ) / noSpokes;
    
    % set the aspect ratio (this also sets up the ONHSpokeRatio vector used to adjust
    % between circular and elliptical displacements)
    SetSpokeAspectRatio( startingAspectRatio );
    
    % check whether ONH is on left or right of image, used to determine where temporal edge is
    if Cx < 380
        left=1;
    else
        left=0;
    end
    
    for gx=1:11
        for gy=1:11
            % evaluate point with temporal lock
            if left
                gridEnergy(gy,gx) = ONHGlobalFitFunction( [Cx+gx-6, Cy+gy-6, radius+6-gx ] );
            else
                gridEnergy(gy,gx) = ONHGlobalFitFunction( [Cx+gx-6, Cy+gy-6, radius+gx-6 ] );
            end            
        end
    end
    
    % find the lowest energy point in the grid and use that. break ties arbitrarily
    [dy,dx] = find( gridEnergy == min(gridEnergy(:)) );
    dy = dy(1);
    dx = dx(1);
    Cx = Cx+dx-6;
    Cy = Cy+dy-6;
    if left
        radius = radius+6-dx;
    else
        radius = radius+dx-6;
    end
end

% % DEBUG - store post-grid search location and radius for later analysis
% ONHGridLocation = [Cx Cy];
% ONHGridRadius = radius;

%
% do the full model search
%

% smoothing factor for this iteration
sigma=5.0;

% generate new gradient image, and apply new smoothing filter if selected
if polo2 > 0
   ONHSetGradientImage( OpticConv( Image, polo2 ), sigma );
else
   ONHSetGradientImage( Image, sigma );
end

% use a small range to avoid getting sucked into the pallor
ONHInnerRange=5;
ONHOuterRange=5;

% allow radius to vary for this stage
ONHFixedRadius = 0;

% set spokes at regular angles covering full circle
ONHSpokeThetas = ( [1:noSpokes] * 2 * pi ) / noSpokes;

% set the aspect ratio (this also sets up the ONHSpokeRatio vector used to adjust
% between circular and elliptical displacements)
SetSpokeAspectRatio( startingAspectRatio );

% use gradient descent to optimize the position
p = GradientDescent( [ Cx Cy radius ], 'ONHGlobalGradient', 0.5, 0.1, 0.1, 50 );

% extract new centre, radius. store aspect ratio for function return if aspect update is
% not enabled.
newCentre = p(1:2);
newRadius = p(3);
newAspectRatio = startingAspectRatio;

% % DEBUG - store post final search location and radius for later analysis
% ONHFinalLocation = newCentre;
% ONHFinalRadius = newRadius;

% This section recalculates the aspect ratio from the final force points, and repeats
% the final stage. It may be iterated a number of times, but one is enough, I think.
% This tweaks the model closer to the actual contour, and thus reduces distortion effects
% suffered by the final local model.

for its=1:aspectIterations
    % calculate spoke points of current model.
    S = ONHSpokeRatios * newRadius;
    Cx = newCentre(1);
    Cy = newCentre(2);
    
    % calculate the force points (and lots of other irrelevant stuff) using the standard
    % service routine. Only "e" (normalised force point distance) is of interest
    [Pxy, m, mAv, mNeighAv, e, beta ] = ONHModelValues( newCentre, S );
    
    % don't attempt aspect reset if model value stage fails
    if isnan( mAv )
        break;
    end
    
    % calculate position of force points by de-normalizing
    f = e .* ONHSpokeRatios;
    
    % now fit a better elliptical model to the force points by varying the aspect ratio and radius
    [ radius, aspectRatio ] = ONHEstimateEllipse( f );
    
    % update aspect ratio
    SetSpokeAspectRatio( aspectRatio );
    
    % reapply gradient descent at new aspect ratio
    p = GradientDescent( [ Cx Cy radius ], 'ONHGlobalGradient', 0.5, 0.1, 0.1, 20 );
    
    % extract new centre and radius
    newCentre = p(1:2);
    newRadius = p(3);
    newAspectRatio = aspectRatio;
end

% % DEBUG - store post-aspect position for dump file
% ONHPostLocation = newCentre;
% ONHPostRadius = newRadius;
% ONHPostAspectRatio = newAspectRatio;

% % $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% % DEBUG section - fill dump file with intermediate stage results, for later viewing using ShowONHGlobalStages
% global ONHDumpFile;
% save( ONHDumpFile, 'ONHInitialLocation', 'ONHInitialRadius', 'ONHTemporalLocation', 'ONHTemporalRadius', ...
%       'ONHGridLocation', 'ONHGridRadius', 'ONHFinalLocation', 'ONHFinalRadius', 'ONHAspectRatio', ...
%       'ONHPostLocation', 'ONHPostRadius', 'ONHPostAspectRatio', 'ONHHoughLocation', 'ONHHoughRadius' );
