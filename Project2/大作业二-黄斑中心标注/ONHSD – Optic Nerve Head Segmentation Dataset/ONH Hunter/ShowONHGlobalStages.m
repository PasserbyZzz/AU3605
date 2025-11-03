% ShowONHGlobalStages
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Display utility
% Show the development of the global model through the stages: initial location,
% location after temporal lock, location after grid search, final location of global model.
% The files that this uses are generated in ONHFitGlobalModel by the statements marked DEBUG,
% which must therefore be commented back in to allow this routine to function.
% Useful for diagnosing which stage failed, if any

function P = ShowONHGlobalStages(Postfix,Range)

% Some control coefficients - number and length of spokes, size of arc
% marker, colors
NoSpokes=24;
SpokeRadius=80;
MarkerWidth=5;
SpokeColor = [ 1 0.5 1 ];
ArcColor = [ 0.5 1 1 ];

% create a new figure window
figure

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
    
    % now load the ONH global dump file
    [pathstr,name,ext,versn] = fileparts(Files(r).name);
    GlobalFileName = fullfile( pathstr, 'ONHResults', [name '_' Postfix '_GDump.mat' versn] );
    if exist( GlobalFileName, 'file')
        load( GlobalFileName );
    else
        disp( sprintf( 'Global file %s not found', GlobalFileName ) );
        continue;
    end
    
    % Show the image
    Image = imread( Files(r).name );
    imshow(Image);
    
    % Show the global models
    ONHPlotGlobalModel( ONHInitialLocation, ONHInitialRadius, ONHAspectRatio, [ 1 1 0] );
    ONHPlotGlobalModel( ONHHoughLocation, ONHHoughRadius, ONHAspectRatio, [ 1 0 1] );
    ONHPlotGlobalModel( ONHTemporalLocation, ONHTemporalRadius, ONHAspectRatio, [1 0 0] );
    ONHPlotGlobalModel( ONHGridLocation, ONHGridRadius, ONHAspectRatio, [0 1 0] );
    ONHPlotGlobalModel( ONHFinalLocation, ONHFinalRadius, ONHAspectRatio, [0 0 1] );
    ONHPlotGlobalModel( ONHPostLocation, ONHPostRadius, ONHPostAspectRatio, [0 1 1] );
    
    % allow user to toggle points
    marksShown=1;
    while 1
        % retrieve user click point
        Pt  = ginput(1);
        
        % not a click, but a return...
        if size(Pt,1) == 0
            break;
        end
        
        % toggle display of markers if click
        marksShown=1-marksShown;
        
        if marksShown == 0
            % show image without marks
            imshow(Image);  
        else
            % Show the global models
            ONHPlotGlobalModel( ONHInitialLocation, ONHInitialRadius, ONHAspectRatio, [ 1 1 0] );
            ONHPlotGlobalModel( ONHHoughLocation, ONHHoughRadius, ONHAspectRatio, [ 1 0 1] );
            ONHPlotGlobalModel( ONHTemporalLocation, ONHTemporalRadius, ONHAspectRatio, [1 0 0] );
            ONHPlotGlobalModel( ONHGridLocation, ONHGridRadius, ONHAspectRatio, [0 1 0] );
            ONHPlotGlobalModel( ONHFinalLocation, ONHFinalRadius, ONHAspectRatio, [0 0 1] );
            ONHPlotGlobalModel( ONHPostLocation, ONHPostRadius, ONHPostAspectRatio, [0 1 1] );
        end
    end
end
