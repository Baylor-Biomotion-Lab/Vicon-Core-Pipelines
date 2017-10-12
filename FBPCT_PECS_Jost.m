% Ajit Chaudhari
% PCT_PECS.m
% 11/8/2007
% The Ohio State University
% -------------------------
% This script takes a trial and calculates the cluster coordinates systems
% for the thigh and shank of the right and left legs.  If anatomic CS
% markers are present it assumes that this is a reference trial and
% calculates the anatomic coordinate systems as well.  In addition to
% adding virtual markers for the origin & X,Y,Z axes of the coordinate
% systems, it also creates a point for the eigenvalue norm of each
% cluster.  This point is to be used to evaluate nonrigid motion by
% comparing the eigenvalue norm between the reference trial and any
% other trials.
% Modified 11/27/07 to use new SuperPCT marker set
% Modified 12/20/07 to use Plug-In-Gait Full Body + bilateral PCT (FBPCT)
% Modified 1/5/10 [AMWC] Totally replaced to make this a helper for
% FBPCT_dynamicPECS.m and FBPCT_staticPECS.m
% Modified 7/10/12 [AMWC] to gracefully handle missing markers for each segment
%
% Modified 7/4/2016 [CF] To update the code to use the Nexus 2 commands
% instead of PECS calls. The function call to PECSPullData has been updated
% as well. (The code is kept as close to the original as possible).

% PECSPullData; % Pull out all trajectories
clearvars
load('20170614_1000_FWALK_ 4_trajectoryData')

%----------------------Automate for different segments starting here-------
% Include a try/catch in case one leg or one segment is not fully markered

% Grab all indices that correspond to thigh and shank clusters
rt_thigh_idx = labelidx(rt_thigh_clusterlabels);
rt_shank_idx = labelidx(rt_shank_clusterlabels);
lt_thigh_idx = labelidx(lt_thigh_clusterlabels);
lt_shank_idx = labelidx(lt_shank_clusterlabels);

% 12/10/07 remove any markers that aren't there (idx==0)
% 10/09/09 [Jamison] NOT_THERE = PECSlabels(last)... so we want to
%   eliminate any idx==length(PECSlabels) ;
absent_mkr=length(PECSlabels);
rt_thigh_idx = rt_thigh_idx(rt_thigh_idx~=absent_mkr);
rt_shank_idx = rt_shank_idx(rt_shank_idx~=absent_mkr);
lt_thigh_idx = lt_thigh_idx(lt_thigh_idx~=absent_mkr);
lt_shank_idx = lt_shank_idx(lt_shank_idx~=absent_mkr);

ClusterIdx={rt_thigh_idx; rt_shank_idx; lt_thigh_idx; lt_shank_idx};

if trial_type==STATIC,
    % 2/24/08 Since this is a static reference trial, create reflocals for the
    % thighs and shanks so we can check for flips
    reflocal_rt_thigh = [];
    reflocal_rt_shank = [];
    reflocal_lt_thigh = [];
    reflocal_lt_shank = [];
else % trial_type==DYNAMIC or QUASISTATIC
    % 2/25/08 Since this is a dynamic trial, load reflocals for the
    % thighs and shanks
    reflocalfname = ['' '_reflocal.mat'];  % the '' was labelprefix() - this needs to be checked**** [CF]
    try
        % Save _reflocal in the correct folder to avoid error.
%         path=vicon.GetTrialName;
%         [~,loc]=regexp(path,'\\','match');
%         path(loc(end-1):end)='';
        cd('H:\Research\MATLAB\Data\Articulate Labs\20170614_1000')
        load(reflocalfname);
    catch ME1
        errordlg(sprintf('Couldn''t load %s, can''t continue',reflocalfname),'No Local Reference File');
        error('No Local Reference File');
    end
end

vicon=ViconNexus();
% Go through all time points and get all the principal axes for each
% timepoint
segnames = {'rt_thigh','rt_shank','lt_thigh','lt_shank'};
segmarkers = {'Origin','X','Y','Z','Mag'};
CScomponents = {'Origin','XV','YV','ZV','mag'};

% Create new trajectories for all the segnames:segmarkers defined above
for ctr = 1:length(segnames),
    for ctr1 = 1:length(segmarkers),
        tname = [segnames{ctr} segmarkers{ctr1}];
        %
        % Check to see if marker already exists [CF]
        modnames = vicon.GetModelOutputNames(S);
        % First, is there any modeled marker names
        modl = length(modnames);
        mark_exists=zeros(length(modnames),1);
        if modl >= 1 % if yes, then check
            for modi = 1:length(modnames)
                if strcmp(modnames(modi),tname) == 1
                    mark_exists(modi) = 1;
                else
                    mark_exists(modi) = 0;
                end
            end
        else   % if not, then state that mark_exists is zero
            mark_exists = 0;
        end
        %
        % Now do nothing or create the marker
        if max(mark_exists) == 1
            % you can't create another of the same marker
            % and there is not a trajectory set here (so do nothing)
            %
        else
            % the marker will be created
            vicon.CreateModeledMarker(S, tname)
            % the trajectory is set later
        end
    end
end

% Go through all valid frames. Try to create a cluster CS. If this
% works, write the values to the trajectories for the markers for the
% segment. If it doesn't work (calcClusterCS threw an error) then
% invalidate that point for all the trajectories of that segment

ClusterData=cell(size(ClusterIdx));
ClusterCS=cell(size(ClusterIdx));
for ctr=First_Frame:1:End_Frame,
    for ctr1 = 1:length(segnames),
        s = segnames{ctr1};
        j = ctr-First_Frame+1;
        validData = true;
        
        try
          eval([s '_data = squeeze(data(:,j,' s '_idx));']) %rt_thigh_data = squeeze(data(:,ctr,rt_thigh_idx));
          ClusterData{ctr1}=squeeze(data(:,ctr,ClusterIdx{ctr1}));
          ClusterCS{ctr1}=zeros(length(First_Frame:1:End_Frame),1);
            eval(['[' s 'CS,reflocal_' s '] = calcClusterCS(' s '_data,[],reflocal_' s ');']) %[rt_thighCS(ctr),reflocal_rthigh] = calcClusterCS(rt_thigh_data,[],reflocal_rthigh);
            
        catch ME1
            validData = false;
            troubleframe = ctr;
        end
        
        for ctr2 = 1:length(CScomponents), % For the 5 variables {Origin, X, Y, Z, Mag} set the value
            tCSname = [s 'CS.' CScomponents{ctr2}];
            len = eval(['length(' tCSname ')']);
            if len==1   % Scalar needs to be converted to a trajectory, put that in Z component and pad with zeros
                eval([tCSname '=[0;0;' tCSname '];']);
            elseif len==3  % The variable is not being read correctly by the function, so need to evaluate the string to pull out the numeric variable
                tCSnamenum = eval([tCSname]);
            else
            end
            tname = [s segmarkers{ctr2}];
            
            if validData==true,
                % Functions work oddly, so get model output (will be all zeros) to assign model output
                [dtemp,~] = vicon.GetModelOutput(S, tname);
                % Assign the tCSname value to dtemp
                dtemp(1:3,ctr) = tCSnamenum;
                % Then set model output - should work every time
                vicon.SetModelOutputAtFrame(S, tname, ctr, dtemp(1:3,ctr), true)
            else
                disp('Not a valid point')
                disp('Frame in question is: ')
                disp(troubleframe)
            end
        end
    end
end

disp('Finished With Trial')
if trial_type==STATIC,
    % 2/24/08 Since this is the reference trial, we must save the reflocal
    % values to use for subsequent dynamic trials
    save('_reflocal.mat','reflocal*'); % 6/17/2016 was able to remove labelprefix as it is an empty character string
end
