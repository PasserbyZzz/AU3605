% StiffnessVector
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Fitting utility.
% Calculates the stiffness values for each 
% spoke, normalised w.r.t. each other

function V = StiffnessVector( g, offset )

% offset = 1.5; This was the hard-coded value used in ONH experiments

global ONHUse2DGradient;

if ONHUse2DGradient == 1
    g = 1+g;
end

gAv = mean(g);

for i=1:size(g,2)
    V(i) = stiffness( g(i), -(offset+gAv) );
end

V = 1-V;


