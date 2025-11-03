% ONHFitLocalModel
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Core fitting routine for the local model.
% Given an image and starting global model, plus control parameters,
% fit a deformable local model and return its centre and spoke displacements.

function [ newCentre, spokes ] = ONHFitLocalModel( Image, centre, radius, sigma, inner, outer, neighborhood, alpha, gamma, aspectRatio )

global ONHAspectRatio;
global ONHGradientImage;
global ONHSpokeThetas; % angles of spokes to be sampled
global ONHSpokeRatios;
global ONHInnerRange; % search size from average radius, back towards centre
global ONHOuterRange; % search size from average radius, outwards
global ONHNeighborhoodSize; % global giving neighborhood size.
                            % other spokes within +- this "radius" are considered
                            % neighbors. Note that the definition is circular.
global ONHAlpha; % weighting of local versus global internal model
global ONHGamma; % weighting of internal versus external model
global ONHInnerMinimum;
global ONHOuterMaximum;
global ONHUse2DGradient;
global ONHRobustThreshold;

global ONHDebugFigure;

% use 2D gradient version
ONHUse2DGradient=1;

ONHRobustThreshold=0.2;

% control constants
noSpokes=24;
qnGTolerance=1e-6; % convergence of quasi-newton

% copy control parameters to globals
ONHAlpha = alpha;
ONHGamma = gamma;
ONHNeighborhoodSize=neighborhood;
ONHInnerRange=inner;
ONHOuterRange=outer;

% figures for minimum and maximum model radius.
ONHInnerMinimum=25;
ONHOuterMaximum=50;

% Get the gradient image, and store it in global for access
% by force calculation routines
ONHSetGradientImage( Image, sigma );

% debug image, for plotting algorithm progress
%ONHDebugFigure = figure, imshow(ONHGradientImage);

% set spokes at regular angles covering full circle
ONHSpokeThetas = ( [1:noSpokes] * 2 * pi ) / noSpokes;    

% set the aspect ratio (this also sets up the ONHSpokeRatio vector used to adjust
% between circular and elliptical displacements)
SetSpokeAspectRatio( aspectRatio );

% generate the initial model points using the specified radius and the standard
% aspect ratio
M = radius * ONHSpokeRatios;

% call quasi-newton to generate new centre and spoke displacement vector, using the associated
% energy function and gradient routines.
P = QuasiNewtonBFGS( [ centre M ], qnGTolerance, 'ONHLocalEnergyFunction', 'ONHLocalGradient' );

% extract new centre and spoke displacements and return as results of the function
newCentre = P(1:2);
spokes = P(3:size(P,2));
