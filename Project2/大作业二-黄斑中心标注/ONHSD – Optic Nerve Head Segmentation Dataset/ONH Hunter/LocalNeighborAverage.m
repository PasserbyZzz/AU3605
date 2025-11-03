% LocalNeighborAverage.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Service routine for local model fitting.
% Calculates the average of the neighboring elements in
% the vector supplied as a parameter, where the neighbourhood size is supplied
% as a parameter, and neighbors are defined circularly (i.e. last neighbors first).
% The average does not include the element itself.

function N = LocalNeighborAverage( S, neighSize )

N = zeros( size(S) );

% do nothing if zero-sized neighborhood
if neighSize == 0
    return;
end
      
% for each offset, shift the vector and accumulate total
for i=-neighSize:neighSize
    
    % don't do the zero shift - the point itself is not included in its neighborhood
    if i == 0
        continue;
    end
    
    % circular shift the vector, and add to total
    N = N + circshift( S, [0 i] );
end

% convert sum to mean
N = N / ( neighSize * 2 );

                            
                          
                            
                            

