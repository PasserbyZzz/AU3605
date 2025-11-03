function corr_filter = FourierCorrelation(I,T)
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

%-----------------------------------------------------------------------------------
%Program    :  Fourier Correlation
%
%Purpose	: Performs a fast fourier transform to calculate the correlation between 
%			  an image and a template
%
%Outcome	: 
%
%Calls	    : 
%-----------------------------------------------------------------------------------

      %I is the image
      %T is the template

      [Iy,Ix] = size(I);
      [Ty,Tx] = size(T);

      A = I;
      B = T;
      
      B = rot90(B);
      B = rot90(B);
      
      %----------------------------------------
	  %Zero pad A & B to a power of 2
	  %----------------------------------------
      A(1024,1024) = 0;
      B(1024,1024) = 0;

      %----------------------------------------
	  %Perform a fourier transform to calculate correlation
	  %----------------------------------------
      Fourier=ifft2(fft2(A).*(fft2(B)));
      
      Correlation=Fourier(1:(Iy+Ty-1),1:(Ix+Tx-1));
      
      %----------------------------------------
	  %Obtain the real number from the fourier transform
	  %----------------------------------------
      corr_filter_tmp=real(Correlation);
         
      corr_filter = corr_filter_tmp(floor(Ty/2):Iy+floor(Ty/2),floor(Tx/2):Ix+floor(Tx/2));  
      
return      