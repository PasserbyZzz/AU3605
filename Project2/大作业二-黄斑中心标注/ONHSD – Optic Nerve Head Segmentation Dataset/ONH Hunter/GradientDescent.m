% GradientDescent.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Generic Optimization routine
% Does gradient descent with momentum, given a function, GradFn, which
% can calculate the gradient of the function to be minimized at point p.
% Other parameters control the algorithm - eta = learning rate, Momentum = momentum
% rate, GThreshold = stopping condition threshold on gradient, maxIterations other
% stopping condition.

function Result = GradientDescent( p, GradFn, Eta, Momentum, GThreshold, maxIterations )

Delta = 0.0;


for it=1:maxIterations
    
    % work out the gradient
    g = feval(GradFn,p);
    
    % if its sub-threshold, stop the search
    if abs(g) < GThreshold 
        break;
    end

    % work out size of change, and remember it for next iteration
    Delta = Eta * -g + Momentum * Delta;
    
    % Make the change
    p = p + Delta;
end

% return the finishing point
Result = p;