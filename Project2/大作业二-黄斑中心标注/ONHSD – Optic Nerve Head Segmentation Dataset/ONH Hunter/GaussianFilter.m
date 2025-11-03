function F = GaussianFilter( sigma, radius )
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.


% create x,y sample points
[x,y] = meshgrid( -radius:radius );

% create the filter
F = exp( -( x.*x+y.*y )/(2*sigma*sigma) )/(2*pi*sigma*sigma);

% normalise the filter to sum to 1.0
total = sum(F(:));

F = F / total;
