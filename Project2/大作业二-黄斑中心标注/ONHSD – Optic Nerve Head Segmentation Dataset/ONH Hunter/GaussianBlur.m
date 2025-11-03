% GradientBlur - blur an image by efficient convolution with a
% gaussian filter.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

%
% Andrew Hunter, 18/09/02 University of Durham, based on
% original version by James Lowell, ditto.

function GI = GaussianBlur( I, sigma )

M = GaussianFilter( sigma, ceil(sigma*3) );

GI = xconv2(I,M);