% Optic locator - adapted from J. Lowell's optic_locator function but
% takes a double grey-scale image.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

function Centre = optic_locator(image)

hsi = RGB2HSI(image);
I = hsi(:,:,3);
[Ia,Ib,p]=size(I);
          	
	%----------------------------------------   
	%Create a binary image by thresholding image 
	%----------------------------------------
	thresh = 10.0;
    image_in = rgb2gray(image);
    image_threshold = (image_in>thresh);
	
	%----------------------------------------   
	%Set size of mask, erode image and subtract eroded image from whole image 
	%----------------------------------------
	SE = ones(20,20);
	imageborder = double(imerode(image_threshold,SE,5));      

%imageborder = double( imerode(image_threshold,ones(30)) );
    
    T= MexHat;
    
    c = FourierCorrelation(I,T);
    %figure,mmshow(c)

    c2 = imageborder.*c(1:Ia,1:Ib);  
    %figure, mmshow(c2)

    [optic_y,optic_x] = find(c2==max2(c2));
    optic_y = optic_y(1,1);
    optic_x = optic_x(1,1);
    Centre = [ optic_x optic_y ];
    
return