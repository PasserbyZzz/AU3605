% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

function a = mmnorm(b)

m = min(min(b));

a = b - m;

M = max(max(a));

if M > 0
  a = a / M;
end
