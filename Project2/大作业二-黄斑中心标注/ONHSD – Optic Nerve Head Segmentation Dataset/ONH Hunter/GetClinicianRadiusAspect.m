% GetClinicianRadiusAspect
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Analysis routine
% estimate actual radius and aspect ratio from clinician markings

function [R, AR] = GetClinicianRadiusAspect( Range )

global ONHSpokeThetas;
noSpokes=24;
ONHSpokeThetas = ( [1:noSpokes] * 2 * pi ) / noSpokes;

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
    
    % calc radius and aspect ratio
    [ radius, aspectRatio ] = ONHEstimateEllipse( ONHMeanEdge' );
    R(count) = radius;
    AR(count) = aspectRatio;
end