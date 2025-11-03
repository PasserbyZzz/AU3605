% NominateONH
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Clinician mark-up routine.
% This routine is used to nominate by hand the ``gold-standard'' segmentation.
% Run this function to assign points to the ONH edge.
% To place a radial marker, click at the desired edge point for the ONH
% along each radial spoke.
% If you get it wrong, just click again. If you are unsure, make a best
% guess.
% To view the image without the spokes click to the top left of the image;
% to redisplay spokes click there again.
% When an image is finished, press RETURN.
% You can specify a single image or a number of them, e.g.:
% NominateONH( 3, 'ONH' ) - do it on image 3
% NominateONH( 1:5, 'ONH' ) - images 1 through 5
% NominateONH( [1 2 7 9 ], 'ONH' ) - images 1,2,7 and 9
% NominateONH( 'ONH' ) - all images in the directory.
% The Postfix is used to specify the file postfix for storing the
% points - useful if multiple people are involved.
% MakeOpticMarkerFiles must be run first
% CHECK THAT you have assigned all markers before finishing. You can usually
% see the markers in the middle (or a bit of them) if they are unassigned
% (except for the rightmost, which is not visible when at the centre).

function P = NominateONH(Postfix,Range)

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
    
    % now load the ONH centre file
    [pathstr,name,ext,versn] = fileparts(Files(r).name);
    CentreFileName = fullfile( pathstr, 'Clinicians', [name '_C' '.mat' versn] );
    if exist( CentreFileName, 'file')
        load( CentreFileName );
    else
        disp( sprintf( 'Centre file %s not found', CentreFileName ) );
        continue;
    end

    % get the centre
    CX = ONHCentre(1);
    CY = ONHCentre(2);
    
    % load the edge marker file, if any
    [pathstr,name,ext,versn] = fileparts(Files(r).name);
    ONHFileName = fullfile( pathstr, 'Clinicians', [name '_' Postfix '.mat' versn] );
    if exist( ONHFileName, 'file')
        load( ONHFileName );
    else
        ONHEdge = zeros(NoSpokes,1);
    end
    
    % Show the image
    Image = imread( Files(r).name );
    imshow(Image);    
    
    % show the spokes and markers
    for i=1:NoSpokes
        Theta = (i-1) * 2 * 3.141592 / NoSpokes;
        
        % The spoke
        XOff = SpokeRadius * cos(Theta);
        YOff = SpokeRadius*sin(Theta);
        line( [CX CX+XOff], [CY CY+YOff], 'Color', SpokeColor, 'LineStyle', '-' ); 
        
        % The marker
        MX = CX + ONHEdge(i) * cos(Theta);
        MY = CY + ONHEdge(i) * sin(Theta);
        XOff = MarkerWidth * cos(Theta+3.141593*0.5);
        YOff = MarkerWidth * sin(Theta+3.141593*0.5);
        line( [MX-XOff MX+XOff], [MY-YOff MY+YOff], 'Color', ArcColor, 'LineStyle', '-' ); 
    end
    
    marksShown=1;
    
    % allow user to toggle points
    while 1
        % retrieve user click point
        Pt  = ginput(1);
        
        % not a click, but a return...
        if size(Pt,1) == 0
            break;
        end
        
        % toggle display of markers if click to left or above image
        if Pt(1) < 1 | Pt(2) < 1
            marksShown=1-marksShown;
            
            if marksShown == 0
                % show image without marks
                imshow(Image);  
            else
                
                % show the marks
                for i=1:NoSpokes
                    Theta = (i-1) * 2 * 3.141592 / NoSpokes;
                    
                    % The spoke
                    XOff = SpokeRadius * cos(Theta);
                    YOff = SpokeRadius*sin(Theta);
                    line( [CX CX+XOff], [CY CY+YOff], 'Color', SpokeColor, 'LineStyle', '-' ); 
                    
                    % The marker
                    MX = CX + ONHEdge(i) * cos(Theta);
                    MY = CY + ONHEdge(i) * sin(Theta);
                    XOff = MarkerWidth * cos(Theta+3.141593*0.5);
                    YOff = MarkerWidth*sin(Theta+3.141593*0.5);
                    line( [MX-XOff MX+XOff], [MY-YOff MY+YOff], 'Color', ArcColor, 'LineStyle', '-' ); 
                end
            end
            
        else
            % click within image area
            
            % Find nearest spoke to click point, by angle
            Theta = atan2( Pt(2)-CY, Pt(1)-CX );
            spoke = round( Theta * NoSpokes / ( 2.0 * 3.141592 ) );
            if spoke < 0 
                spoke = NoSpokes + spoke + 1;
            else
                spoke = spoke+1;
            end
            
            % Find the distance out from the centre, and assign to the edge structure
            ONHEdge(spoke) = norm( Pt - [ CX CY ] );
            
            % redisplay the image
            imshow(Image);  
            
            for i=1:NoSpokes
                Theta = (i-1) * 2 * 3.141592 / NoSpokes;
                
                % The spoke
                XOff = SpokeRadius * cos(Theta);
                YOff = SpokeRadius*sin(Theta);
                line( [CX CX+XOff], [CY CY+YOff], 'Color', SpokeColor, 'LineStyle', '-' ); 
                
                % The marker
                MX = CX + ONHEdge(i) * cos(Theta);
                MY = CY + ONHEdge(i) * sin(Theta);
                XOff = MarkerWidth * cos(Theta+3.141593*0.5);
                YOff = MarkerWidth*sin(Theta+3.141593*0.5);
                line( [MX-XOff MX+XOff], [MY-YOff MY+YOff], 'Color', ArcColor, 'LineStyle', '-' ); 
            end
        end
    end
            
    % store the spoke radial distance file
    save( ONHFileName, 'ONHEdge' );
end
