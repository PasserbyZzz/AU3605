% ClinicianCentroids.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Analysis routine.
% Calculate the centroids of each ONH assigned by the clinicians

function [Centroids,Disparities] = ClinicianCentroids( Range )

global ONHSpokeThetas;

% Find all bitmap files in the current directory
Files = dir('*.bmp');

% default is to process all files (if no parameter given)
if nargin == 0
    Range=[1:size(Files,1)];
end

% for each image selected
count=0;
for r=Range
    count = count+1;
    
    % split path name
    [pathstr,name,ext,versn] = fileparts(Files(r).name);    
    
    % load average clinician data
    ONHMeanFileName = fullfile( pathstr, 'Clinicians', [name '_' 'AvSD' '.mat' versn] );
    load( ONHMeanFileName );
    
    % load centre file used for clinician estimates; in ONHCentre
    CentreFileName = fullfile( pathstr, 'Clinicians', [name '_C' '.mat' versn] );
    if exist( CentreFileName, 'file')
        load( CentreFileName );
    else
        disp( sprintf( 'Centre file %s not found', CentreFileName ) );
        continue;
    end
    clinicianCentre = ONHCentre(1:2);
    
    % calculate clinician edge points
    noSpokes=24;
    
    % set spokes at regular angles covering full circle
    ONHSpokeThetas = ( [1:noSpokes] * 2 * pi ) / noSpokes; 
    
    Pts = ONHModelPointXYs( clinicianCentre, ONHMeanEdge' );    
    
    % centroid is mean of the xy's
    Centroids(count,:) = mean( Pts, 2 )';

    % load centre file from location algorithm
    CentreFileName = fullfile( pathstr, 'Centres', [name '_C' '.mat' versn] );
    if exist( CentreFileName, 'file')
        load( CentreFileName );
    else
        disp( sprintf( 'Centre file %s not found', CentreFileName ) );
        continue;
    end
    
    Disparities(count) = norm( [Centroids(count,:)-ONHCentre(1:2)] );
    
    figure,imshow(imread(Files(r).name));
   line( Centroids(count,1), Centroids(count,2), 'Color', [0 0 0], 'LineStyle', 'none', 'Marker', 'x' );
   line( ONHCentre(1), ONHCentre(2), 'Color', [0 0 0], 'LineStyle', 'none', 'Marker', '+' );
end