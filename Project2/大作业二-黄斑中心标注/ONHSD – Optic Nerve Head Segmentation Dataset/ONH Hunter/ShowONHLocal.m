% ShowONHLocal
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Display utility
% Show specified local model one image at a time.

function P = ShowONHLocal(GlobalPostfix, LocalPostfix, Range)

global ONHGradientImage;

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
if nargin < 3
    Range=[1:size(Files,1)];
end

% for each image selected
for r=Range
    
    % Display image number and file
    disp( sprintf( '%d: %s', r, Files(r).name ) );
    
    % now load the ONH local file
    [pathstr,name,ext,versn] = fileparts(Files(r).name);
    LocalFileName = fullfile( pathstr, 'ONHResults', [name '_' GlobalPostfix '_' LocalPostfix '_L.mat' versn] );
    if exist( LocalFileName, 'file')
        load( LocalFileName );
    else
        disp( sprintf( 'Local file %s not found', LocalFileName ) );
        continue;
    end
    
    % Show the image
    Image = imread( Files(r).name );
    imshow(Image);
    
    % Show the local model
    ONHPlotLocalModel( ONHCentre, ONHSpokes );

    % show force points
    ONHShowLocalForcePoints( ONHCentre, ONHSpokes );
    
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
            % Show the global model
            ONHPlotLocalModel( ONHCentre, ONHSpokes );
            
            % show force points
            ONHShowLocalForcePoints( ONHCentre, ONHSpokes );
        end
    end
end
