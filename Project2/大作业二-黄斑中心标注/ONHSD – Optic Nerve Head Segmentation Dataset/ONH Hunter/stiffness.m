function stiff = stiffness( Gradient, Coeff )
% Function to generate a stiffness value from a gradient
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Coefficient determines the shape of the curve. 0 is symmetric,
% positive pushes the curve to the left, negative to the right
% asymptotes with zero slope at (0,1) and (1,0)

% Method. Essentially, uses the cubic y=2x^3-3x^2+1, which has the
% right general shape and is symmetric.
% Raising this to the power Coeff "squashes" it to the left. 
% To squash to the right, we feed (1-x) to the equation instead,
% then use 1-y, thus reflecting the function to squash right.

if ( Coeff == 0 )
  stiff = 2 * Gradient .^ 3 - 3 * Gradient .^ 2 + 1;
elseif Coeff > 0 
  stiff = ( 2 * Gradient .^ 3 - 3 * Gradient .^ 2 + 1 ) .^ ( 1 + Coeff );  
else
  Coeff = 1 - Coeff;
  Gradient = 1 - Gradient;
  stiff = 1- ( 2 * Gradient .^ 3 - 3 * Gradient .^ 2 + 1 ) .^ Coeff;
end


      
