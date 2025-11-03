function Z= MexHat

% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Generating the hat without for loops
C = 2*(pi^-0.25)/sqrt(3);
[X,Y] = meshgrid(-5:0.1:5);
s = 0.1;
d = 0.25;                  %0.475

R = X.^2 + Y.^2 + eps;
R = R.*s;
Z = C*(1-R).*exp(-R./2);
[a,b] = size(Z);

for J = round(a/2)-1:round(a/2)+1
    for K = 1:b
        Z(J,K) = 0;
    end 
end

for J = 1:a
    for K =1:b
        if Z(J,K)<0
            Z(J,K) = d*Z(J,K);
        end
    end
end  

centrex = round(a/2);
centrey = round(b/2);
radius = 18;                                  %12.5
scalefactor = 0.03;                             %0.02
for J = centrex-radius:centrex + radius;
    for K = centrey - radius:centrey + radius
        h = scalefactor*sqrt(radius^2 - (centrex - J)^2 - (centrey - K)^2);
        if (C-h) < Z(J,K)
            Z(J,K) = C-h;
        end    
    end
end    

%Z = mmnorm(Z);

%figure,imshow(Z)
Z = rot90(Z);

%mesh(Z);
%rotate3d on