% AngleBetween calculates the subtended angle between two angles.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Utility routine.
% It compensates for range (i.e. outside 0-2pi) and for wraparound

function A = AngleBetween( A1, A2 )

a1 = mod( A1, 2 * pi );
a2 = mod( A2, 2 * pi );

M = max( [ a1 a2 ] );
m = min( [ a1 a2 ] );

A = M-m;

if A > pi
    A = 2 * pi - A;
end