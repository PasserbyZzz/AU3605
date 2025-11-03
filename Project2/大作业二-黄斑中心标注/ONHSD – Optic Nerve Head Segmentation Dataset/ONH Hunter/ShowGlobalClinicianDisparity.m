% ShowGlobalClinicianDisparity
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Display utility
% Draws a gallery figure with each ONH centred with clinician
% and global models drawn on.
% Used to generate one of the figures for the paper - also useful for overviewing results

function [ONHDisparity, ONHNormDisparity] = ShowGlobalClinicianDisparity( Postfix, Range )

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

% create new figure window
figure
noImages=size(Range,2);
xSize = ceil(sqrt(noImages));
ySize = ceil(noImages/xSize);

% for each image selected
count=0;
for r=Range
    count = count+1;
    
    % split path name
    [pathstr,name,ext,versn] = fileparts(Files(r).name);    
    
     % show the image
     Image = imread( Files(r).name );
     
     subplot( xSize, ySize, count );
     imshow(Image);
    
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
    ClinicianCentre = ONHCentre(1:2);

    % plot the clincian mean
    ONHPlotLocalModel( ONHCentre, ONHMeanEdge', [ 1 0 0 ] );
    
    % plot +/- 2 s.d.s from mean
    ONHPlotLocalModel( ONHCentre, ONHMeanEdge' - 2 * ONHsdEdge', [ 1 0.5 0.5 ] );
    ONHPlotLocalModel( ONHCentre, ONHMeanEdge' + 2 * ONHsdEdge', [ 1 0.5 0.5 ] );
    
    % adjust the figure so just the ONH and its surround is visible
    set( gca, 'XLim', [ ONHCentre(1)-80 ONHCentre(1)+80 ] );
    set( gca, 'YLim', [ ONHCentre(2)-80 ONHCentre(2)+80 ] );
    
    % load the algorithm centre and radius (global model estimates)
    GlobalFileName = fullfile( pathstr, 'ONHResults', [name '_' Postfix '_G.mat' versn] );
    load( GlobalFileName );

    % plot the global model    
    ONHPlotGlobalModel( ONHCentre, ONHRadius, ONHAspectRatio, [ 1 1 0.5 ] );
end
