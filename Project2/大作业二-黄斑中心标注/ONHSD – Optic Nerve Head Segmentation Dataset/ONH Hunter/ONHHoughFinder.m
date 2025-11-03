% ONHHoughFinder
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting function - find centre by Hough-transform.
% Determines a local region by radius (truncated to image edges),
% then looks for the ONH by circular hough.
% Best location and radius are returned, together with confidence level
% from the Hough peak

function [newCentre, newRadius, conf] = ONHHoughFinder( Image, Centre, threshold )

searchRange=150;

XMin = Centre(1)-searchRange;
XMax = Centre(1)+searchRange;
YMin = Centre(2)-searchRange;
YMax = Centre(2)+searchRange;

XMin = max( [1 XMin] );
YMin = max( [1 YMin] );
XMax = min( [size(Image,2) XMax] );
YMax = min( [size(Image,1) YMax] );

[x,y,newRadius,conf] = CircularHough( Image, XMin, XMax, YMin, YMax, threshold );

%figure,imshow(edge(Image( YMin:YMax, XMin:XMax ),'Canny',0.2));
%ONHPlotGlobalModel( [x y], newRadius, 1.0, [1 0 0 ] );

x = x+XMin;
y = y+YMin;

newCentre = [x y];

