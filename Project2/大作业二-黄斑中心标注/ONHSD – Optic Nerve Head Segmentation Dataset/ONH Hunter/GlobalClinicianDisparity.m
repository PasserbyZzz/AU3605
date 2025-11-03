% GlobalClinicianDisparity.
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Analysis routine.
% Determines the per-spoke disparity between a given version of the
% global algorithm and the clinician's hand-drawn perimeters.
% These are saved to file for later analysis, and also returned in case of immediate
% ad.hoc. analysis

function [ONHDisparity, ONHNormDisparity] = GlobalClinicianDisparity( Postfix, Range )

SpokeColor = [ 1 0.5 1 ];
ArcColor = [ 0.5 1 1 ];
MarkerWidth=5;

sdConstant = 0.1;

% Find all bitmap files in the current directory
Files = dir('*.bmp');

% default is to process all files (if no parameter given)
if nargin == 1
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
    
    % load the algorithm centre and radius (global model estimates); in ONHCentre
    GlobalFileName = fullfile( pathstr, 'ONHResults', [name '_' Postfix '_G.mat' versn] );
    load( GlobalFileName );
    
    spokes = pi/12 * [1:24];
    for i=1:24
        adjustedRadii(i) = ONHRadius * norm( [ cos( spokes(i) ); ONHAspectRatio * sin( spokes(i) ) ] );
    end
    algorithmPoints = [ ONHCentre(1)+adjustedRadii .* cos(spokes); ONHCentre(2)+adjustedRadii .* sin(spokes) ]';
    
    % calculate the disparities using standard routine, and copy to the disparity array
    ONHDisparity(count,:) = AlgorithmClinicianDisparity( clinicianCentre, ONHMeanEdge, algorithmPoints );

    % calculate the normalized disparity (divide by standard deviation)
    ONHNormDisparity(count,:) = ONHDisparity(count,:) ./ ( ONHsdEdge' + sdConstant );
    
    % now write out the disparities to file (they are also returned)
    ONHDisparityFileName = fullfile( pathstr, 'ONHResults', ['Disparity_' Postfix '.mat' versn] );
    save( ONHDisparityFileName, 'ONHDisparity', 'ONHNormDisparity' );
end
