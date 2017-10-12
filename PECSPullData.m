% Ajit Chaudhari
% Ohio State University
% PECSPullData.m
% 5/29/2008
% ------------
% This script pulls all
% the data from all the trajectories.  It then matches all the labels. It
% assumes the PECS server has been initiated and that all_labels has been
% loaded.
% Modified 12/30/09 Changed how it handles gaps--now it replaces the Vicon
% data for invalid markers to NaN (Vicon sends the same value as previous
% valid data).
% Modified 1/5/10 [AMWC] Changed how it handles gaps again--if it's a
% static trial, don't worry about times when the marker doesn't move. If
% it's a dynamic trial, invalidate only if it stays the same for more than
% 2 frames in a row. all_Labels stores the default trial type as DYNAMIC.
%
% Modified 6/11/2016 Carley Fuller [CF] Updated the code for Nexus 2.
% This version retains the same format as the original code.
% I left some commentary in about particular Nexus 2 functions, so that
% the update could be easily understood if there was questions.

% Create a vicon object to access vicon commands
vicon = ViconNexus();

% check the number of subjects
nSubjects = length(vicon.GetSubjectNames()); % If there are multiple subjects BodyBuilder won't run
if nSubjects>1,
    error('Too Many Subjects. Operation Failed')
else
    S = vicon.GetSubjectNames();
    S = S{1};  % if there really is one subject this should be good
    % get the frame count
    [First_Frame,End_Frame]=vicon.GetTrialRegionOfInterest; %get frame range
    Frame_Range=End_Frame-First_Frame+1;
    Trial_Length=vicon.GetFrameCount;
end

% Now pull out all the marker trajectories
% data is 3 x (# of frames) x (# of markers)
markers = vicon.GetMarkerNames(S);
nMarkers = length(markers);
for ctr = 1:nMarkers
   try
       for i = First_Frame:1:End_Frame
           j = i-First_Frame+1;
           mark_idx = markers{ctr};
           % [x y z e] = vicon.GetTrajectoryAtFrame(subject,markername,frame)
           %eval([mark_idx '[markx, marky, markz, marke] = vicon.GetTrajectoryAtFrame(S,' mark_idx ',i);'])
           [markx, marky, markz, marke] = vicon.GetTrajectoryAtFrame(S,mark_idx,i);
           datatmp(j,1:4) = [markx, marky, markz, marke];
       end
       jend = End_Frame-First_Frame+1;
       % Transpose and create all marker trajectory matrices
       data(1:3,1:jend,ctr) = (datatmp(:,1:3))';
       % Find when this trajectory is valid (the function has e a logical
       % identifier used for this)
       tmpvalid = (datatmp(:,4))';
       validtrajectory(:,1:jend,ctr) = (tmpvalid~=0);
       %
       if exist('trial_type', 'var') && exist('DYNAMIC', 'var')
            if trial_type == DYNAMIC,
                invalid = ~validtrajectory(1,:,ctr); % Find all instances where position isn't valid
                data(:,invalid,ctr) = NaN;
            end
       end
       
   catch
      disp('Marker not found:')
      disp(markers{ctr})
   end
end

% recreate PECSlabels
PECSlabels = markers;   % This used to be a list of 219 markers (141 generated from 
% other processes - essentially model output things; one to represent a "Not_There" marker)

% Add in this nonexistant marker
data(:,:,ctr+1) = NaN;
notthereidx = nMarkers+1;
firstValid(notthereidx) = First_Frame(1);
lastValid(notthereidx) = End_Frame(1);
PECSlabels{notthereidx} = 'NOT_THERE';

% Match up downloaded with trajectories with the ones we are looking for
labelidx = matchLabels(all_Labels,PECSlabels);
labelidx(labelidx==0) = notthereidx;