%%FPContact_Trajectories.m
%Ajit Chaudhari
%Ohio State University
%8/17/2009
% This script reads the Eclipse Node for the trial to find which foot
% struck each force plate. It assumes that this information has been
% manually assigned in the database. More than one force plate may be
% assigned to each foot and vice versa, depending on the activity, number
% of gait cycles captured and whether one foot hits multiple plates.
%--------------------


clear

FP_LEFT = -1;
FP_RIGHT = 1;
FP_OTHER = 0;
N_PLATES = 4;
GOOD_LEFT = 'ECL_FPL';
GOOD_RIGHT = 'ECL_FPR';
INVALID = 'ECL_FPI';
AUTO = 'ECL_FPA';

%% Initialize parameters and PECS server

% Get hold of PECS (returns a handle to an ActiveX object)
hPECS = actxserver( 'PECS.Document' );

% Open the trial (returns a handle to an ActiveX object)
hTrial = get( hPECS, 'Trial' );

% Open the processor
hProcessor = get( hPECS, 'Processor' );

% Get foot-plate info from database
hEclipseNode = get(hTrial, 'EclipseNode');
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
        N_PLATES = ctr-1;
        break
    end
end
release(hEclipseNode);

% Get info on how long the trajectories are

% Get start and end fields in the trial for marker data
firstValid = round(double(invoke(hTrial,'FirstValidTrajectoryFieldNum')));
lastValid = round(double(invoke(hTrial,'LastValidTrajectoryFieldNum')));
nFields = lastValid;
firstValid = 1;

%% Assign Trajectories for the existing force plates
FP_Assign = zeros(3,N_PLATES);
FP_Traj = zeros(3,nFields,N_PLATES);
for ctr=1:N_PLATES,
    switch(FP_Foot{ctr})
        case GOOD_LEFT
            FP_Assign(3,ctr) = FP_LEFT;
        case GOOD_RIGHT
            FP_Assign(3,ctr) = FP_RIGHT;
        otherwise
            FP_Assign(3,ctr) = FP_OTHER;
    end
    FP_Traj = FP_Assign(:,ctr)*ones(1,nFields);
    TrajName = sprintf('hFP%dTrajectory',ctr);
    TrajLabel = sprintf('FP%d_Foot',ctr);
    cmd1 = [TrajName '=invoke(hTrial,''CreateTrajectory'');'];
    eval(cmd1);
    cmd2 = sprintf('invoke(%s,''SetPoints'',firstValid,lastValid,FP_Traj);',TrajName);
    eval(cmd2);
    cmd3 = sprintf('invoke(%s,''Label'',''%s'');',TrajName,TrajLabel);
    eval(cmd3);
    cmd4 = sprintf('release(%s);',TrajName);
    eval(cmd4);
end


%% -------------------End automation for different segments here-----------
% Release everything
release( hProcessor );
release( hTrial );
release( hPECS );