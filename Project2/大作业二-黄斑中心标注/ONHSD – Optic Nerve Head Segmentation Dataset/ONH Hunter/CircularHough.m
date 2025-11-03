% CircularHough
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Used in fitting routines
% Search for the disk by applying a circular Hough filter within a given sub-area
% of the image, and return the peak point, together with its "confidence" (Hough peak level)

function [x,y,r,conf] = CircularHough( Image, XMin, XMax, YMin, YMax, cannyThreshold )

global ONHOutsideMask;

Image = Image( YMin:YMax, XMin:XMax );

[H W] = size(Image);

% edge detect the image, but mask out retinal boundary (important to avoid false edges along
% edge of retina!)
%Edge = edge( Image, 'Canny', cannyThreshold ) & ONHOutsideMask(YMin:YMax, XMin:XMax);
Edge = edge( Image, 'Canny', cannyThreshold );

CircleMap = zeros( H+150, W+150, 15 );

% set up circular masks
for i=1:15
    CMask{i} = CircleMask( 26+2*i );
    sizeY(i) = size( CMask{i}, 1 );
    shiftY(i) = - floor( sizeY(i) / 2 );
    sizeX(i) = size( CMask{i}, 2 );
    shiftX(i) = - floor( sizeX(i) / 2 );
end

% get edge pixels
[py px] = find( Edge );

% process each pixel in turn
for i=1:size(py,1)
    % each circle size in turn
    for j=1:15
        % accumulate count on relevant pixels
        CircleMap( 75+py(i)+shiftY(j):75+py(i)+sizeY(j)+shiftY(j)-1, 75+px(i)+shiftX(j):75+px(i)+sizeX(j)+shiftX(j)-1, j ) = ...
        CircleMap( 75+py(i)+shiftY(j):75+py(i)+sizeY(j)+shiftY(j)-1, 75+px(i)+shiftX(j):75+px(i)+sizeX(j)+shiftX(j)-1, j ) + CMask{j};
    end
end

% blur the images to integrate evidence locally
CircleMap = imfilter( CircleMap, fspecial( 'gaussian', 7, 1.5 ) );

% now generate maximums on each x,y position (highest circle likelihood of any radius)
% figure
% for i=1:10
% subplot(2,5,i),mmshow(CircleMap( 51:H+51, 51:51+W, i ));
% end
% figure,mmshow(max( CircleMap( 51:H+51, 51:51+W, : ), [], 3 ));

% find highest confidence circle and return its x,y,radius
CM = CircleMap(76:76+H, 76:76+W,:);
conf = max( CM(:) );
ind = find( CM == conf );
ind = ind(1);
[y,x,r] = ind2sub( size(CM), ind );
r=r(1)*2+26;

