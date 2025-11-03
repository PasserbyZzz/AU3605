% BatchExperiments
% Copyright University of Lincoln, 2008. Prof. Andrew Hunter,
% ahunter@lincoln.ac.uk.
% This file may not be reproduced or used without the permission of the
% owner.

% Analysis utility
% Used this file to generate various experiments off-line.
% Experiments commented out after use but left in file - this makes it easy to 
% cut and paste to analyze the results later

% % Try at various sizes 40-45 range, best temporal
% MakeONHGlobal( '1.05-41-0-1-0.0-10100', 1.05, 41, 0, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.05-42-0-1-0.0-10100', 1.05, 42, 0, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.05-43-0-1-0.0-10100', 1.05, 43, 0, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.05-44-0-1-0.0-10100', 1.05, 44, 0, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); 
% 
% % ditto, hough erode global
% MakeONHGlobal( '1.05-41-7-1-0.2-00100', 1.05, 41, 7, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.05-42-7-1-0.2-00100', 1.05, 42, 7, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.05-43-7-1-0.2-00100', 1.05, 43, 7, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.05-44-7-1-0.2-00100', 1.05, 44, 7, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); 
% 
% % without aspect adjustment - both "best temporal" and "hough erode global"
% MakeONHGlobal( '1.05-40-0-0-0.0-10100', 1.05, 40, 0, 0, 0.0, 1, 0, 1, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.05-40-7-0-0.2-00100', 1.05, 40, 7, 0, 0.2, 0, 0, 1, 0, 0, 1:99 );
% 
% % without 2D gradient - both "best temporal" and "hough erode global"
% MakeONHGlobal( '1.05-40-0-1-0.0-10000', 1.05, 40, 0, 1, 0.0, 1, 0, 0, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.05-40-7-1-0.2-00000', 1.05, 40, 7, 1, 0.2, 0, 0, 0, 0, 0, 1:99 );


% % Batch generation of global models
% 
% % Size 40
% 
% % WITHOUT EROSION
% % hough
% MakeONHGlobal( '1.05-40-0-1-0.2-10100', 1.05, 40, 0, 1, 0.2, 1, 0, 1, 0, 0, 1:99 ); % hough, temp, no grid
% MakeONHGlobal( '1.05-40-0-1-0.2-00100', 1.05, 40, 0, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough, global only
% 
% % no hough
% MakeONHGlobal( '1.05-40-0-1-0.0-00100', 1.05, 40, 0, 1, 0.0, 0, 0, 1, 0, 0, 1:99 ); % global only
% MakeONHGlobal( '1.05-40-0-1-0.0-10100', 1.05, 40, 0, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, no grid
% MakeONHGlobal( '1.05-40-0-1-0.0-11100', 1.05, 40, 0, 1, 0.0, 1, 1, 1, 0, 0, 1:99 ); % temporal with grid
% 
% % WITH EROSION
% % hough
% MakeONHGlobal( '1.05-40-7-1-0.2-10100', 1.05, 40, 7, 1, 0.2, 1, 0, 1, 0, 0, 1:99 ); % hough, temp, no grid
% MakeONHGlobal( '1.05-40-7-1-0.2-00100', 1.05, 40, 7, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough, global only
% 

% % no hough
% MakeONHGlobal( '1.05-40-7-1-0.0-00100', 1.05, 40, 7, 1, 0.0, 0, 0, 1, 0, 0, 1:99 ); % global only
% MakeONHGlobal( '1.05-40-7-1-0.0-10100', 1.05, 40, 7, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, no grid
% MakeONHGlobal( '1.05-40-7-1-0.0-11100', 1.05, 40, 7, 1, 0.0, 1, 1, 1, 0, 0, 1:99 ); % temporal with grid
% 
% % size 35
% 
% % WITHOUT EROSION
% % hough
% MakeONHGlobal( '1.05-35-0-1-0.2-10100', 1.05, 35, 0, 1, 0.2, 1, 0, 1, 0, 0, 1:99 ); % hough, temp, no grid
% MakeONHGlobal( '1.05-35-0-1-0.2-00100', 1.05, 35, 0, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough, global only
% 
% % no hough
% MakeONHGlobal( '1.05-35-0-1-0.0-00100', 1.05, 35, 0, 1, 0.0, 0, 0, 1, 0, 0, 1:99 ); % global only
% MakeONHGlobal( '1.05-35-0-1-0.0-10100', 1.05, 35, 0, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, no grid
% MakeONHGlobal( '1.05-35-0-1-0.0-11100', 1.05, 35, 0, 1, 0.0, 1, 1, 1, 0, 0, 1:99 ); % temporal with grid
% 
% % WITH EROSION
% % hough
% MakeONHGlobal( '1.05-35-7-1-0.2-10100', 1.05, 35, 7, 1, 0.2, 1, 0, 1, 0, 0, 1:99 ); % hough, temp, no grid
% MakeONHGlobal( '1.05-35-7-1-0.2-00100', 1.05, 35, 7, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough, global only
% 
% % no hough
% MakeONHGlobal( '1.05-35-7-1-0.0-00100', 1.05, 35, 7, 1, 0.0, 0, 0, 1, 0, 0, 1:99 ); % global only
% MakeONHGlobal( '1.05-35-7-1-0.0-10100', 1.05, 35, 7, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, no grid
% MakeONHGlobal( '1.05-35-7-1-0.0-11100', 1.05, 35, 7, 1, 0.0, 1, 1, 1, 0, 0, 1:99 ); % temporal with grid
% 
% % size 45
% 
% % WITHOUT EROSION
% % hough
% MakeONHGlobal( '1.05-45-0-1-0.2-10100', 1.05, 45, 0, 1, 0.2, 1, 0, 1, 0, 0, 1:99 ); % hough, temp, no grid
% MakeONHGlobal( '1.05-45-0-1-0.2-00100', 1.05, 45, 0, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough, global only
% 
% % no hough
% MakeONHGlobal( '1.05-45-0-1-0.0-00100', 1.05, 45, 0, 1, 0.0, 0, 0, 1, 0, 0, 1:99 ); % global only
% MakeONHGlobal( '1.05-45-0-1-0.0-10100', 1.05, 45, 0, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, no grid
% MakeONHGlobal( '1.05-45-0-1-0.0-11100', 1.05, 45, 0, 1, 0.0, 1, 1, 1, 0, 0, 1:99 ); % temporal with grid
% 
% % WITH EROSION
% % hough
% MakeONHGlobal( '1.05-45-7-1-0.2-10100', 1.05, 45, 7, 1, 0.2, 1, 0, 1, 0, 0, 1:99 ); % hough, temp, no grid
% MakeONHGlobal( '1.05-45-7-1-0.2-00100', 1.05, 45, 7, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough, global only
% 
% % no hough
% MakeONHGlobal( '1.05-45-7-1-0.0-00100', 1.05, 45, 7, 1, 0.0, 0, 0, 1, 0, 0, 1:99 ); % global only
% MakeONHGlobal( '1.05-45-7-1-0.0-10100', 1.05, 45, 7, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, no grid
% MakeONHGlobal( '1.05-45-7-1-0.0-11100', 1.05, 45, 7, 1, 0.0, 1, 1, 1, 0, 0, 1:99 ); % temporal with grid

% % With 1.02 aspect ratio
% 
% MakeONHGlobal( '1.02-40-0-0-0.0-10100', 1.02, 40, 0, 0, 0.0, 1, 0, 1, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.02-40-7-0-0.2-00100', 1.02, 40, 7, 0, 0.2, 0, 0, 1, 0, 0, 1:99 );
% 
% % without 2D gradient - both "best temporal" and "hough erode global"
% MakeONHGlobal( '1.02-40-0-1-0.0-10000', 1.02, 40, 0, 1, 0.0, 1, 0, 0, 0, 0, 1:99 ); 
% MakeONHGlobal( '1.02-40-7-1-0.2-00000', 1.02, 40, 7, 1, 0.2, 0, 0, 0, 0, 0, 1:99 );
% 
% MakeONHGlobal( '1.02-40-0-1-0.2-00100', 1.02, 40, 0, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough, global only
% MakeONHGlobal( '1.02-40-0-1-0.0-00100', 1.02, 40, 0, 1, 0.0, 0, 0, 1, 0, 0, 1:99 ); % global only
% MakeONHGlobal( '1.02-40-0-1-0.0-10100', 1.02, 40, 0, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal
% 
% MakeONHGlobal( '1.02-40-7-1-0.2-00100', 1.02, 40, 7, 1, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough, global only, erosion
% MakeONHGlobal( '1.02-40-7-1-0.0-00100', 1.02, 40, 7, 1, 0.0, 0, 0, 1, 0, 0, 1:99 ); % global only, erosion
% MakeONHGlobal( '1.02-40-7-1-0.0-10100', 1.02, 40, 7, 1, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, erosion


% With 1.03 aspect ratio

% all combs temporal or not, hough or not, erode or not
MakeONHGlobal( '1.03-40-0-3-0.0-10100', 1.03, 40, 0, 3, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal
MakeONHGlobal( '1.03-40-0-3-0.0-00100', 1.03, 40, 0, 3, 0.0, 0, 0, 1, 0, 0, 1:99 ); % direct
MakeONHGlobal( '1.03-40-0-3-0.2-10100', 1.03, 40, 0, 3, 0.2, 1, 0, 1, 0, 0, 1:99 ); % temporal hough
MakeONHGlobal( '1.03-40-0-3-0.2-00100', 1.03, 40, 0, 3, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough direct
MakeONHGlobal( '1.03-40-7-3-0.0-10100', 1.03, 40, 7, 3, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal erode
MakeONHGlobal( '1.03-40-7-3-0.0-00100', 1.03, 40, 7, 3, 0.0, 0, 0, 1, 0, 0, 1:99 ); % erode direct
MakeONHGlobal( '1.03-40-7-3-0.2-10100', 1.03, 40, 7, 3, 0.2, 1, 0, 1, 0, 0, 1:99 ); % temporal hough erode
MakeONHGlobal( '1.03-40-7-3-0.2-00100', 1.03, 40, 7, 3, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough erode direct

% without 2D gradient - both "temporal" and "hough erode global"
MakeONHGlobal( '1.03-40-0-3-0.0-10000', 1.03, 40, 0, 3, 0.0, 1, 0, 0, 0, 0, 1:99 ); 
MakeONHGlobal( '1.03-40-7-3-0.2-00000', 1.03, 40, 7, 3, 0.2, 0, 0, 0, 0, 0, 1:99 );


% % different aspect reset
% MakeONHGlobal( '1.03-40-0-0-0.0-10100', 1.03, 40, 0, 0, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, no aspect reset
% MakeONHGlobal( '1.03-40-7-0-0.2-00100', 1.03, 40, 7, 0, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough erode direct, no aspect reset
% MakeONHGlobal( '1.03-40-0-2-0.0-10100', 1.03, 40, 0, 2, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, aspect its=2
% MakeONHGlobal( '1.03-40-7-2-0.2-00100', 1.03, 40, 7, 2, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough erode direct, aspect its=2
% MakeONHGlobal( '1.03-40-0-3-0.0-10100', 1.03, 40, 0, 3, 0.0, 1, 0, 1, 0, 0, 1:99 ); % temporal, aspect its=2
% MakeONHGlobal( '1.03-40-7-3-0.2-00100', 1.03, 40, 7, 3, 0.2, 0, 0, 1, 0, 0, 1:99 ); % hough erode direct, aspect its=2

% generate the local models using the same parameters throughout, except stick with erode if eroding on first stage

% all combs
MakeONHLocal( '1.03-40-0-3-0.0-10100', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-0-3-0.0-00100', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-0-3-0.2-10100', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-0-3-0.2-00100', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-7-3-0.0-10100', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-7-3-0.0-00100', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-7-3-0.2-10100', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-7-3-0.2-00100', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );

% without 2D
MakeONHLocal( '1.03-40-0-3-0.0-10000', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-7-3-0.2-00000', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );

% % aspect its
% MakeONHLocal( '1.03-40-0-0-0.0-10100', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
% MakeONHLocal( '1.03-40-7-0-0.2-00100', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );
% MakeONHLocal( '1.03-40-0-2-0.0-10100', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
% MakeONHLocal( '1.03-40-7-2-0.2-00100', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );
% MakeONHLocal( '1.03-40-0-3-0.0-10100', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
% MakeONHLocal( '1.03-40-7-3-0.2-00100', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );

% now build the statistics for later graphing

GlobalClinicianDisparity( '1.03-40-0-3-0.0-10100' ); % temporal
GlobalClinicianDisparity( '1.03-40-0-3-0.0-00100' ); % direct
GlobalClinicianDisparity( '1.03-40-0-3-0.2-10100' ); % temporal hough
GlobalClinicianDisparity( '1.03-40-0-3-0.2-00100' ); % hough direct
GlobalClinicianDisparity( '1.03-40-7-3-0.0-10100' ); % temporal erode
GlobalClinicianDisparity( '1.03-40-7-3-0.0-00100' ); % erode direct
GlobalClinicianDisparity( '1.03-40-7-3-0.2-10100' ); % temporal hough erode
GlobalClinicianDisparity( '1.03-40-7-3-0.2-00100' ); % hough erode direct

% without 2D gradient - both "temporal" and "hough erode global"
GlobalClinicianDisparity( '1.03-40-0-3-0.0-10000' ); 
GlobalClinicianDisparity( '1.03-40-7-3-0.2-00000' );


% % different aspect reset
% GlobalClinicianDisparity( '1.03-40-0-0-0.0-10100' ); % temporal, no aspect reset
% GlobalClinicianDisparity( '1.03-40-7-0-0.2-00100' ); % hough erode direct, no aspect reset
% GlobalClinicianDisparity( '1.03-40-0-2-0.0-10100' ); % temporal, aspect its=2
% GlobalClinicianDisparity( '1.03-40-7-2-0.2-00100' ); % hough erode direct, aspect its=2
% GlobalClinicianDisparity( '1.03-40-0-3-0.0-10100' ); % temporal, aspect its=3
% GlobalClinicianDisparity( '1.03-40-7-3-0.2-00100' ); % hough erode direct, aspect its=3

LocalClinicianDisparity( '1.03-40-0-3-0.0-10100', '0-0.5-3-1-4-4' );
LocalClinicianDisparity( '1.03-40-0-3-0.0-00100', '0-0.5-3-1-4-4' );
LocalClinicianDisparity( '1.03-40-0-3-0.2-10100', '0-0.5-3-1-4-4' );
LocalClinicianDisparity( '1.03-40-0-3-0.2-00100', '0-0.5-3-1-4-4' );
LocalClinicianDisparity( '1.03-40-7-3-0.0-10100', '7-0.5-3-1-4-4' );
LocalClinicianDisparity( '1.03-40-7-3-0.0-00100', '7-0.5-3-1-4-4' );
LocalClinicianDisparity( '1.03-40-7-3-0.2-10100', '7-0.5-3-1-4-4' );
LocalClinicianDisparity( '1.03-40-7-3-0.2-00100', '7-0.5-3-1-4-4');

% without 2D gradient
LocalClinicianDisparity( '1.03-40-0-3-0.0-10000', '0-0.5-3-1-4-4' );
LocalClinicianDisparity( '1.03-40-7-3-0.2-00000', '7-0.5-3-1-4-4' );

% LocalClinicianDisparity( '1.03-40-0-0-0.0-10100', '0-0.5-3-1-4-4' );
% LocalClinicianDisparity( '1.03-40-7-0-0.2-00100', '7-0.5-3-1-4-4' );
% LocalClinicianDisparity( '1.03-40-0-2-0.0-10100', '0-0.5-3-1-4-4' );
% LocalClinicianDisparity( '1.03-40-7-2-0.2-00100', '7-0.5-3-1-4-4' );
% LocalClinicianDisparity( '1.03-40-0-3-0.0-10100', '0-0.5-3-1-4-4' );
% LocalClinicianDisparity( '1.03-40-7-3-0.2-00100', '7-0.5-3-1-4-4' );


% additional: without 2D gradient - "direct" and "erode" approaches
MakeONHGlobal( '1.03-40-0-3-0.0-00000', 1.03, 40, 0, 3, 0.0, 0, 0, 0, 0, 0, 1:99 ); % direct
MakeONHGlobal( '1.03-40-7-3-0.0-00000', 1.03, 40, 7, 3, 0.0, 0, 0, 0, 0, 0, 1:99 ); % erode direct
MakeONHLocal( '1.03-40-0-3-0.0-00000', '0-0.5-3-1-4-4', 0, 0.5, 3, 1, 4, 4 );
MakeONHLocal( '1.03-40-7-3-0.0-00000', '7-0.5-3-1-4-4', 7, 0.5, 3, 1, 4, 4 );
GlobalClinicianDisparity( '1.03-40-0-3-0.0-00000' ); % direct
GlobalClinicianDisparity( '1.03-40-7-3-0.0-00000' ); % erode direct
LocalClinicianDisparity( '1.03-40-0-3-0.0-00000', '0-0.5-3-1-4-4');
LocalClinicianDisparity( '1.03-40-7-3-0.0-00000', '7-0.5-3-1-4-4');
