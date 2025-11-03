% ONHSetGradientImage
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting service function
% ONHSetGradientImage sets up the gradient images used in ONH finding.
% There is a magnitude image (directionless gradient, inverted so that
% minimisation finds biggest gradient), and an X,Y pair for directed gradient;
% also the Laplacian.

function ONHSetGradientImage( image, sigma )

global ONHGradientImage;
global ONHGradientImageX;
global ONHGradientImageY;
global ONHSecondDerivativeImageXX;
global ONHSecondDerivativeImageYY;

if sigma ~= 0 
   image = GaussianBlur( image, sigma );
end;

% get the gradient magnitude, x and y.
Grad2 = gradient2( image );
ONHGradientImageX = real(Grad2);
ONHGradientImageY = imag(Grad2);
ONHGradientImage = abs( Grad2 );


% get the gradient magnitude. gradient2 returns the gradient vectors as a complex matrix;
% abs retrieves the magnitude of this
%ONHGradientImage = abs( gradient2( image ) );

% invert, then normalize to range 0,1.
ONHGradientImage = mmnorm( -ONHGradientImage );

% normalise x,y gradient to range [-1,+1];
ONHGradientImageX = mmnorm( ONHGradientImageX ) * 2 - 1;
ONHGradientImageY = mmnorm( ONHGradientImageY ) * 2 - 1;

% These ones were used for experiments that optimized by flowing directly along the laplacian
% vector; performance was about the same as the ``anchored snake''
Grad2nd = gradient2( ONHGradientImageX );
ONHSecondDerivativeImageXX = real(Grad2nd);

Grad2nd = gradient2( ONHGradientImageY );
ONHSecondDerivativeImageYY = imag(Grad2nd);
