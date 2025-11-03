% CircleMask returns a Mask with 1's on the radius of a circle of radius R
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.


function Result = CircleMask( R )

Result = fspecial( 'disk', R ) > 0;

if R > 1
  Result(2:2*R,2:2*R) = Result(2:2*R,2:2*R) & ~ ( fspecial('disk',R-1) > 0 );
else
  Result(2,2) = 0;  
end