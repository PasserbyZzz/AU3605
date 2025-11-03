% ShowONHGlobal
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Display utility
% Show specified global models one image at a time. Allows comparison
% as multiple ones can be plotted simultaneously.

function P = ShowONHGlobal(Postfixes,Range)

% color used to plot the boundary
Colors = { [ 1 1 0.5], [1 0.5 0.5 ], [0.5 1 0.5], [0.5 0.5 1] } ;

% create a new figure window
figure

% Find all bitmap files in the current directory
Files = dir('*.bmp');

% default is to process all files (if no parameter given)
if nargin == 1
    Range=[1:size(Files,1)];
end

colorNo=1;

% convert first parameter to a cell array if not already.
if iscell( Postfixes ) == 0
    Postfixes = { Postfixes };
end

AspectRatios = zeros(1,10);

% for each image selected
for r=Range
    
    % Display image number and file
    disp( sprintf( '%d: %s', r, Files(r).name ) );
    
    % Show the image
    Image = imread( Files(r).name );
    imshow(Image);
    
    % display each global model required in turn
    for pf = 1:size(Postfixes,2)
        Postfix = Postfixes{pf};
        Color = Colors{pf};
        
        % now load the ONH global file
        [pathstr,name,ext,versn] = fileparts(Files(r).name);
        GlobalFileName = fullfile( pathstr, 'ONHResults', [name '_' Postfix '_G.mat' versn] );
        if exist( GlobalFileName, 'file')
            load( GlobalFileName );
        else
            disp( sprintf( 'Global file %s not found', GlobalFileName ) );
            continue;
        end
        
        % Show the global model
        ONHPlotGlobalModel( ONHCentre, ONHRadius, ONHAspectRatio, Color );
        AspectRatios(pf) = AspectRatios(pf)+ONHAspectRatio;
    end
    
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
            % display each global model required in turn
            for pf = 1:size(Postfixes,2)
                Postfix = Postfixes{pf};
                Color = Colors{pf};
                
                % now load the ONH global file
                [pathstr,name,ext,versn] = fileparts(Files(r).name);
                GlobalFileName = fullfile( pathstr, 'ONHResults', [name '_' Postfix '_G.mat' versn] );
                if exist( GlobalFileName, 'file')
                    load( GlobalFileName );
                else
                    disp( sprintf( 'Global file %s not found', GlobalFileName ) );
                    continue;
                end
                
                % Show the global model
                ONHPlotGlobalModel( ONHCentre, ONHRadius, ONHAspectRatio, Color );
            end
        end
    end
end

AspectRatios = AspectRatios / size(Range,2)

end
