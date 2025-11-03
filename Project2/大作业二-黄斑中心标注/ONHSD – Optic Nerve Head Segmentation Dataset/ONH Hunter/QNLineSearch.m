% QNLineSearch
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Slave to QuasiNewton - perform an approximate line search
% along a given direction from a given point in N-d space
% Returns new point, x, and function value at that point
% in a cell array.
% Parameters: pOld, fOld, g - start point, function value and gradient; d the
% search direction, stepMax maximum step size
% Reference: Press, W.H. et. al. "Numerical Recipes in C", pp.385
% (Numerical Recipes in MATLAB would have been handier...)
% Author: A. Hunter, 05/01/02

function [p,f] = QNLineSearch( pOld, fOld, g, d, stepMax, QNFunc )

ALF = 1.0E-4;
TOLX = 1.0E-7;

N = size(pOld,2);

sum = sqrt( dot(d,d) );

% ensure direction vector is reasonably scaled
if sum > stepMax
   d = d * ( stepMax / sum );
end

slope = dot(d,g);

% p1 is pOld with ones replacing any sub-one elements
p1 = max( [abs(pOld); ones(1,N) ] );

% alamin - minimum line search distance
alamin = TOLX / max( abs(d) ./ p1 );

% alam - distance along ray. Start with full Newton step
alam = 1.0;

while 1
   % find test point, and evaluate function there
   p = pOld + alam * d;
   f = feval(QNFunc, p );
   
   if alam < alamin
      % Have backtracked to start-point. Strange. Bail out.
      %disp('zero backtrack in QNLineSearch');
      p = pOld;
      f = fOld;
      return
   elseif f <= fOld + ALF * alam * slope
      % Sufficient function decrease achieved - bail out
      return
   else
      % Do back-tracking
      if alam == 1.0
         % First time. Use quadratic estimate to back-track
         tmplam = -slope/(2.0*(f-fOld-slope));
      else
         % subsequent backtracks. Use cubic
         rhs1 = f-fOld-alam*slope;
         rhs2=f2-fOld2-alam2*slope;
         
         if alam == alam2
             dummy=1;
         end

         a=(rhs1/(alam*alam)-rhs2/(alam2*alam2))/(alam-alam2);
         b=(-alam2*rhs1/(alam*alam)+alam*rhs2/(alam2*alam2))/(alam-alam2);
         if a == 0.0
            tmplam = -slope/(2.0*b);
         else
            disc = b*b-3.0*a*slope;
            if disc < 0.0
               %disp('Roundoff problem in QNLineSearch');
            else
               tmplam = (-b+sqrt(disc))/(3.0*a);
            end
            % Limit tmplam to no more than half alam
            if tmplam > 0.5 * alam
               tmplam = 0.5*alam;
            end
         end
      end
   end
   alam2=alam;
   f2 = f;
   fOld2 = fOld;
   alam=max([tmplam 0.1*alam]); % alam at least tenth last version
end
