function [hout,s,v] = rgb2hsi(r,g,b)
%RGB2HSI Convert red-green-blue colors to hue-saturation-value.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

%   H = RGB2HSI(M) converts an RGB color map to an HSI color map.
%   Each map is a matrix with any number of rows, exactly three columns,
%   and elements in the interval 0 to 1.  The columns of the input matrix,
%   M, represent intensity of red, blue and green, respectively.  The
%   columns of the resulting output matrix, H, represent hue, saturation
%   and color value, respectively.
%
%   HSI = RGB2HSI(RGB) converts the RGB image RGB (3-D array) to the
%   equivalent HSI image HSI (3-D array).
%
%   CLASS SUPPORT
%   -------------
%   If the input is an RGB image, it can be of class uint8, uint16, or 
%   double; the output image is of class double.  If the input is a 
%   colormap, the input and output colormaps are both of class double.



switch nargin
  case 1,
     if isa(r, 'uint8'), 
        r = double(r) / 255; 
     elseif isa(r, 'uint16')
        r = double(r) / 65535;
     end
  case 3,
     if isa(r, 'uint8'), 
        r = double(r) / 255; 
     elseif isa(r, 'uint16')
        r = double(r) / 65535;
     end
     
     if isa(g, 'uint8'), 
        g = double(g) / 255; 
     elseif isa(g, 'uint16')
        g = double(g) / 65535;
     end
     
     if isa(b, 'uint8'), 
        b = double(b) / 255; 
     elseif isa(b, 'uint16')
        b = double(b) / 65535;
     end
     
  otherwise,
      error('Wrong number of input arguments.');      
end
  
threeD = (ndims(r)==3); % Determine if input includes a 3-D array



if threeD,
  g = r(:,:,2); b = r(:,:,3); r = r(:,:,1);
  siz = size(r);
  r = r(:); g = g(:); b = b(:);
  M = [r,g,b];
elseif nargin==1,
  M = r;
  g = r(:,2); b = r(:,3); r = r(:,1);
  siz = size(r);
else
  if ~isequal(size(r),size(g),size(b)), 
    error('R,G,B must all be the same size.');
  end
  siz = size(r);
  r = r(:); g = g(:); b = b(:);
  M = [r,g,b];
end

RGBmin = min(M')';
s = zeros(size(RGBmin));
h = zeros(size(RGBmin));
i = zeros(size(RGBmin));


sumRGB = M(:,1) + M(:,2) + M(:,3);
k = find(sumRGB);

%----------------------------------------------
%intensity
%----------------------------------------------
i(k) = sumRGB(k)/3;

%----------------------------------------------
%saturation
%----------------------------------------------
s(k) = 1 - ( (3*RGBmin(k))./sumRGB(k) );

s_invalid = find(i==0);
s(s_invalid) = 0;

%----------------------------------------------
%hue
%----------------------------------------------
h_t = 0.5*( (M(:,1)-M(:,2)) + (M(:,1)-M(:,3)) );

h_d = sqrt((M(:,1)-M(:,2)).^2 + (M(:,1)-M(:,3)).*(M(:,2)-M(:,3)));

degree_conversion = 180/pi;
k = find(h_d);
h(k) = acos(h_t(k)./h_d(k))* degree_conversion;

%----------------------------------------------
%hue is not defined when saturation is 0 or intensity is 0
%----------------------------------------------
h_invalids = find((s==0) | (i ==0));
h(h_invalids) = 0;

%----------------------------------------------
%when b > g
%----------------------------------------------
k = find(b>g);
h(k) = (360 - h(k));

%----------------------------------------------
%normalise hue
%----------------------------------------------
h = h/360;

if nargout<=1,
  if (threeD | nargin==3),
    hout = zeros([siz,3]);
    hout(:,:,1) = reshape(h,siz);
    hout(:,:,2) = reshape(s,siz);
    hout(:,:,3) = reshape(i,siz);
  else
    hout = [h s i];
  end
else
  hout = reshape(h,siz);
  s = reshape(s,siz);
  i = reshape(i,siz);
end
