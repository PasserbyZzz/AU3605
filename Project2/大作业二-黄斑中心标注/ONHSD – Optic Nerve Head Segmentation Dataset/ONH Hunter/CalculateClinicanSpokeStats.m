% CalculateClinicanSpokeStats
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Analysis utility
% This processes the multiple mark-up files produced by clinicians using NominateONH, and
% produces the single file containing their mean and standard deviation perimeters
% Postfixes is a string array of the individual clinician ids used in NominateONH; e.g.
% if we did NominateONH( 'Bob' ) and NominateONH( 'David' ) then pass { 'Bob', 'David' } to
% this routine.
% Done once to allow the disparity calculation routines to work.

function CalculateClinicanSpokeStats(Postfixes,Range)

% Some control coefficients - number and length of spokes, size of arc
% marker, colors
NoSpokes=24;
SpokeRadius=80;
MarkerWidth=5;
SpokeColor = [ 1 0.5 1 ];
ArcColor = [ 0.5 1 1 ];

% Find all bitmap files in the current directory
Files = dir('*.bmp');

% default is to process all files (if no parameter given)
if nargin == 1
    Range=[1:size(Files,1)];
end

% for each image selected
for r=Range
    
    % Display image number and file
    disp( sprintf( '%d: %s', r, Files(r).name ) );
    
    % now load the ONH centre files
    [pathstr,name,ext,versn] = fileparts(Files(r).name);
    
    for pf = 1:size(Postfixes,2)
        Postfix = Postfixes{pf};
        
       % load the edge marker file, if any
       [pathstr,name,ext,versn] = fileparts(Files(r).name);
       ONHFileName = fullfile( pathstr, 'Clinicians', [name '_' Postfix '.mat' versn] );
        if exist( ONHFileName, 'file')
           load( ONHFileName );
       else
           ONHEdge = zeros(NoSpokes,1);
       end
       
       % copy data into tensor
       Edges( :, pf ) = ONHEdge;
    end
    
    % now calculate mean and sd
    ONHMeanEdge = mean( Edges, 2 );
    ONHsdEdge = std( Edges, 0, 2 );
    
    % write the mean and sd to file
    ONHMeanFileName = fullfile( pathstr, 'Clinicians', [name '_' 'AvSD' '.mat' versn] );
    save( ONHMeanFileName, 'ONHMeanEdge', 'ONHsdEdge' );
end



