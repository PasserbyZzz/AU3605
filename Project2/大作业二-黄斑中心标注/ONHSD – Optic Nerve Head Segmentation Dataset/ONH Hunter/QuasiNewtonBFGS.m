% QuasiNewtonBFGS
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Perform QuasiNewton (BFGS) optimization.
% Parameters: p - the starting point
% gTol - the convergence criterion (threshold on gradient at
% which to stop)
% QNFunc, QNGradient - strings giving the names of the functions
% to be used in evaluating the function, and its gradient
% Reference: Press, W.H. et. al. "Numerical Recipes in C", pp.428
% (Numerical Recipes in MATLAB would have been handier...)
% Author: A. Hunter, 05/01/02

function [Result,f] = QuasiNewtonBFGS( p, gTol, QNFunc, QNGradient )

MAXITS=100;  % Maximum number of iterations
EPS= 3.0E-8; % Machine precision 
TOLX= 4*EPS; % Convergence criterion
STEPMAX=100; % Scaled maximum step length for line searches

N = size(p,2); % Size of vector

% Evalute function and gradient at start point
f = feval(QNFunc,p);
g = feval(QNGradient,p);

% Check that initial function value and gradient are valid
if sum(isnan(g)) > 0 | sum(isnan(f))>0
    Result=p;
    return;
end

% Check for the trivial case where the gradient is zero at the starting
% point. This actually happened to me!
if g == 0
    Result=p;
    return;
end

% Initialize inverse-Hessian approximate G to identity matrix
G = eye(N);

% Initialize search direction to negative gradient
xi = -g;

stepMax = STEPMAX * max(sqrt(dot(p,p)),N);

for it=1:MAXITS
  
   [pNew fNew] = QNLineSearch( p, f, g, xi, stepMax, QNFunc );
   
   % Debug statement
   %  disp( sprintf( 'QN it %d, f=%f', it, fNew ) );
   
   % If it goes insane, use last position.
   if sum(isnan(fNew)) > 0 | sum(isnan(pNew)) > 0
       Result = p;
       return
   end
   
   % Update line direction and current point
   xi = pNew-p;
   p = pNew;
   f = fNew;
   
   % p1 is p with ones replacing any sub-one elements
   p1 = max( [abs(p) ; ones(1,N)] );
   
   if max( abs(xi) ./ p1 ) < TOLX
      % Movement converged to near-zero - finished
      Result = p;
      return
   else
      % Save old gradient and get new one
      gOld = g;
      g = feval(QNGradient,p);
      
      if max(abs(g) .* p1 ./ max([fNew 1.0])) < gTol
         % Gradient converged to acceptable level - finished
         
         % Debug statement
         % disp( sprintf( 'QN finished in %d iterations', it ) );
         
         Result = p;
         return
      end
      
      % get difference of gradients and difference times G
      dg = g-gOld;
      hdg = (G * dg')';
      
      % calculate dot products for denominators
      fac = dot(dg,xi);
      fae = dot(dg,hdg);
      sumdg = sum( dot(dg,dg) );
      sumxi = sum( dot(xi,xi) );
      
      if fac*fac > EPS*sumdg*sumxi % skip update if fac not sufficiently positive
         fac=1.0/fac;
         fad=1.0/fae;
         
         dg=fac*xi-fad*hdg;
         G = G+fac*xi'*xi-fad*hdg'*hdg+fae*dg'*dg;
      end
   end
   
   % calculate next direction
   xi = (-G*g')';
   
   % If it goes insane, use last position.
   if sum(isnan(xi)) > 0
       Result = p;
       return
   end
end

% if this point is reached, it hasn't converged.
%disp('Too many iteration in QuasiNewtonBFGS');
% set result to starting weights
Result = p;

