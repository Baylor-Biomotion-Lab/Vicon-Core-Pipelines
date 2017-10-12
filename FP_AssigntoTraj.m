clc;

clear;



% Get hold of PECS (returns a handle to an ActiveX object)

hPECS = actxserver( 'PECS.Document' );



% Open the trial (returns a handle to an ActiveX object)

hTrial = get( hPECS, 'Trial' );

hEclipseNode = get(hTrial, 'EclipseNode');

hSubject = invoke(hTrial,'Subject',0);



TrialName = get(hEclipseNode, 'Title');

labelprefix = invoke(hSubject,'LabelPrefix');

subjectname = invoke(hSubject,'Name');





FP_LEFT = -1;

FP_RIGHT = 1;

FP_INVALID = 0;

FP_AUTO = 2;

FP_MIA= 3;

N_PLATES = 6;

GOOD_LEFT = 'ECL_FPL';

GOOD_RIGHT = 'ECL_FPR';

INVALID = 'ECL_FPI';

AUTO = 'ECL_FPA';





for ctr=1:N_PLATES,

    fpstring = sprintf('FP%d',ctr);

    platestring = sprintf('Plate %d',ctr);

    try

        FP_Foot{ctr} = invoke(hEclipseNode, 'GetTextAttribute',fpstring);

    catch

        try

            FP_Foot{ctr} = invoke(hEclipseNode, 'GetTextAttribute',platestring);

        catch

            FP_Foot{ctr} = {};

        end

    end

    if isempty(FP_Foot{ctr})

        N_PLATES = ctr-1; % Resets down the number of force plates if it finds that there are fewer than 6

        break

    end

end

release(hEclipseNode);



FP_Assign = zeros(N_PLATES);

for ctr=1:N_PLATES,

    switch(FP_Foot{ctr})

        case GOOD_LEFT

            FP_Assign(ctr) = FP_LEFT;

        case GOOD_RIGHT

            FP_Assign(ctr) = FP_RIGHT;

        case AUTO

            FP_Assign(ctr) = FP_AUTO;

        otherwise

            FP_Assign(ctr) = FP_INVALID;

    end

end



if isempty(find(FP_Assign==FP_LEFT)) & isempty(find(FP_Assign==FP_RIGHT));

    release( hSubject );

    release( hTrial );

    release( hPECS );

    errordlg(sprintf('Force plates have not been assigned to feet. Press OK to Quit.\n%s_%s',subjectname,TrialName),'Force Plate Assignment Error');



    break    

end

    

%% create trajectories



LastFrame=get(hTrial, 'LastValidTrajectoryFieldNum');



FP1_Assign(1,1:LastFrame)=FP_Assign(1);  %creation of 1 x N frames matrix

FP1_Assign(3,1:LastFrame)=zeros;         %makes matrix into 3 x N frames so that it can be a trajectory



FP2_Assign(1,1:LastFrame)=FP_Assign(2);  %creation of 1 x N frames matrix

FP2_Assign(3,1:LastFrame)=zeros;         %makes matrix into 3 x N frames so that it can be a trajectory



FP3_Assign(1,1:LastFrame)=FP_Assign(3);  %creation of 1 x N frames matrix

FP3_Assign(3,1:LastFrame)=zeros;         %makes matrix into 3 x N frames so that it can be a trajectory



FP4_Assign(1,1:LastFrame)=FP_Assign(4);  %creation of 1 x N frames matrix

FP4_Assign(3,1:LastFrame)=zeros;         %makes matrix into 3 x N frames so that it can be a trajectory

try

    FP5_Assign(1,1:LastFrame)=FP_Assign(5);  %creation of 1 x N frames matrix

    FP5_Assign(3,1:LastFrame)=zeros;         %makes matrix into 3 x N frames so that it can be a trajectory



    FP6_Assign(1,1:LastFrame)=FP_Assign(6);  %creation of 1 x N frames matrix

    FP6_Assign(3,1:LastFrame)=zeros;         %makes matrix into 3 x N frames so that it can be a trajectory

    

catch

    FP5_Assign(1,1:LastFrame)=FP_MIA;  %creation of 1 x N frames matrix

    FP5_Assign(3,1:LastFrame)=zeros;         %makes matrix into 3 x N frames so that it can be a trajectory



    FP6_Assign(1,1:LastFrame)=FP_MIA;  %creation of 1 x N frames matrix

    FP6_Assign(3,1:LastFrame)=zeros;

end





%% send trajectories to Nexus





hnewTrajectory = invoke(hTrial,'CreateTrajectory');

invoke(hnewTrajectory,'SetPoints',1,LastFrame,FP1_Assign);

invoke(hnewTrajectory,'Label',[labelprefix 'FP1_Assign']);



hnewTrajectory = invoke(hTrial,'CreateTrajectory');

invoke(hnewTrajectory,'SetPoints',1,LastFrame,FP2_Assign);

invoke(hnewTrajectory,'Label',[labelprefix 'FP2_Assign']);



hnewTrajectory = invoke(hTrial,'CreateTrajectory');

invoke(hnewTrajectory,'SetPoints',1,LastFrame,FP3_Assign);

invoke(hnewTrajectory,'Label',[labelprefix 'FP3_Assign']);



hnewTrajectory = invoke(hTrial,'CreateTrajectory');

invoke(hnewTrajectory,'SetPoints',1,LastFrame,FP4_Assign);

invoke(hnewTrajectory,'Label',[labelprefix 'FP4_Assign']);



hnewTrajectory = invoke(hTrial,'CreateTrajectory');

invoke(hnewTrajectory,'SetPoints',1,LastFrame,FP5_Assign);

invoke(hnewTrajectory,'Label',[labelprefix 'FP5_Assign']);



hnewTrajectory = invoke(hTrial,'CreateTrajectory');

invoke(hnewTrajectory,'SetPoints',1,LastFrame,FP6_Assign);

invoke(hnewTrajectory,'Label',[labelprefix 'FP6_Assign']);



release( hnewTrajectory );

release( hSubject );

release( hTrial );

release( hPECS );