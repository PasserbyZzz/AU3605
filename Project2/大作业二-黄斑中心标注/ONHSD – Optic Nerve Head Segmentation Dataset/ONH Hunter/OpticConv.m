% OpticConv
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting utility
% OpticConv - convolute image with "optic polo" to strengthen optic nerve head
% response.
% Best algorithm at present doesn't use this, and not used in paper - retained
% in case of reversion

function Result = OpticConv( Image, Version )

switch Version
case 1
    T = eyeread('conpolo2.bmp'); % read in filter stored as bmp file
case 2
    T = eyeread('conpolo31.bmp'); % read in filter stored as bmp file
    
case 3
    T = eyeread('conpolo32.bmp'); 
    
case 4
    % filter with a smallish LoG filter - emphasizes edge of ONH
    Result = imfilter( Image, -fspecial( 'log', 21, 3 ) );
    return;
    
    % don't filter at all
case 5
    Result = Image;
    return;
end

c = conv2(Image,T);

cn2 = mmnorm(c);   
cn2 = cn2.*cn2.*cn2;  

[y x] = size(cn2);      

Result = mmnorm( mmnorm(Image) + cn2(40:y-40,40:x-40));


