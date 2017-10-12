%% HJC_Test_Final created by Felix from Vicon for Baylor University
% for use with the Point Cluster.
% Additional commentary added by Carley Fuller 5/17/2016
%
% Modified 7/1/2016 Carley Fuller[CF]
% So this code can be run more than once and overwrite a prior HJC trajectory.
%
% Modified 10/19/2016 [CF]
% Needed to add an elseif statement about a gap that occurs at the end of
% the trial.
%
clear
clc
%
% Create a vicon object to access vicon commands
vicon = ViconNexus();
%
% [CF] check the number of subjects
nSubjects = length(vicon.GetSubjectNames()); % If there are multiple subjects BodyBuilder won't run
if nSubjects>1,
    error('Too Many Subjects. Operation Failed')
else
S = vicon.GetSubjectNames();
S = S{1};
end
%
[First_Frame,End_Frame]=vicon.GetTrialRegionOfInterest; %get frame range
Frame_Range=End_Frame-First_Frame+1;
Trial_Length=vicon.GetFrameCount;
MAX_ITER=10000;
%
%% Get Toe Trajectories
for i=First_Frame:1:End_Frame
    j=i-First_Frame+1;
    % IF an error occurs where the information cannot be accessed review
    % line 9-10 to possibly correct the error
    [RT(1,j),RT(2,j),RT(3,j)]= vicon.GetTrajectoryAtFrame(S,'RTOE',i);
    [LT(1,j),LT(2,j),LT(3,j)]= vicon.GetTrajectoryAtFrame(S,'LTOE',i);
end
RT_C=RT';       % transform to column vector
LT_C=LT';
%
%% Check to see which one is moving and populating thigh data
for i=1:1:Frame_Range-1
    j=i+2;
    RT_distance(i,:)=((RT_C(j)-RT_C(1)).^2)^0.5;
    LT_distance(i,:)=((LT_C(j)-LT_C(1)).^2)^0.5;
end
%
RT_Max=max(RT_distance);
LT_Max=max(LT_distance);
%
%% Populate thigh_data_ctr
if RT_Max>LT_Max
    hjc_name='RHJC';
    for i=First_Frame:1:End_Frame
        j=i-First_Frame+1;
        [RFP1(1,j),RFP1(2,j),RFP1(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFP1',i);
        [RFP2(1,j),RFP2(2,j),RFP2(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFP2',i);
        [RFP3(1,j),RFP3(2,j),RFP3(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFP3',i);
        [RFM1(1,j),RFM1(2,j),RFM1(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFM1',i);
        [RFM2(1,j),RFM2(2,j),RFM2(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFM2',i);
        [RFM3(1,j),RFM3(2,j),RFM3(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFM3',i);
        [RFA1(1,j),RFA1(2,j),RFA1(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFA1',i);
        [RFA2(1,j),RFA2(2,j),RFA2(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFA2',i);
        [RFA3(1,j),RFA3(2,j),RFA3(3,j)]=vicon.GetTrajectoryAtFrame(S,'RFA3',i);
        [RGTR(1,j),RGTR(2,j),RGTR(3,j)]=vicon.GetTrajectoryAtFrame(S,'RGTR',i);
        for k=1:1:3
            old_thigh_data_ctr(k,:,j)=[RGTR(k,j) RFP1(k,j) RFP2(k,j) RFP3(k,j) RFM1(k,j) RFM2(k,j) RFM3(k,j) RFA1(k,j) RFA2(k,j) RFA3(k,j)];
        end
    end
else
    hjc_name='LHJC';
    for i=First_Frame:1:End_Frame
        j=i-First_Frame+1;
        [LFP1(1,j),LFP1(2,j),LFP1(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFP1',i);
        [LFP2(1,j),LFP2(2,j),LFP2(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFP2',i);
        [LFP3(1,j),LFP3(2,j),LFP3(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFP3',i);
        [LFM1(1,j),LFM1(2,j),LFM1(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFM1',i);
        [LFM2(1,j),LFM2(2,j),LFM2(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFM2',i);
        [LFM3(1,j),LFM3(2,j),LFM3(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFM3',i);
        [LFA1(1,j),LFA1(2,j),LFA1(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFA1',i);
        [LFA2(1,j),LFA2(2,j),LFA2(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFA2',i);
        [LFA3(1,j),LFA3(2,j),LFA3(3,j)]=vicon.GetTrajectoryAtFrame(S,'LFA3',i);
        [LGTR(1,j),LGTR(2,j),LGTR(3,j)]=vicon.GetTrajectoryAtFrame(S,'LGTR',i);
        for k=1:1:3
            old_thigh_data_ctr(k,:,j)=[LFA1(k,j) LFA2(k,j) LFA3(k,j) LFM1(k,j) LFM2(k,j) LFM3(k,j) LFP1(k,j) LFP2(k,j) LFP3(k,j) LGTR(k,j)]; % does order matter? include GTR?
        end
    end
end
%
%% Pelvis
for i=First_Frame:1:End_Frame
    j=i-First_Frame+1;
    [LASI(1,j),LASI(2,j),LASI(3,j)] = vicon.GetTrajectoryAtFrame(S,'LASI',i);
    [RASI(1,j),RASI(2,j),RASI(3,j)] = vicon.GetTrajectoryAtFrame(S,'RASI',i);
    [RPSI(1,j),RPSI(2,j),RPSI(3,j)] = vicon.GetTrajectoryAtFrame(S,'RPSI',i);
    [LPSI(1,j),LPSI(2,j),LPSI(3,j)] = vicon.GetTrajectoryAtFrame(S,'LPSI',i);
end
for ctr=1:Frame_Range
    PELO(:,ctr)=(RASI(:,ctr)+LASI(:,ctr))/2;
    SACR(:,ctr)=(RPSI(:,ctr)+LPSI(:,ctr))/2;
    PELZ(:,ctr)=RASI(:,ctr)-LASI(:,ctr);
    PELZ(:,ctr)=PELZ(:,ctr)./norm(PELZ(:,ctr));          %unit vector
    PELX_temp(:,ctr)=SACR(:,ctr)-PELO(:,ctr);
    PELY(:,ctr)=cross(PELX_temp(:,ctr),PELZ(:,ctr));     %cross product of PELX_temp, PELZ
    PELY(:,ctr)= PELY(:,ctr)./norm(PELY(:,ctr));         %unit vector
    PELX(:,ctr)=cross(PELY(:,ctr),PELZ(:,ctr));          %cross product of PELY and PELZ
    old_PtoG(:,:,ctr)=[PELX(:,ctr) PELY(:,ctr) PELZ(:,ctr)];
end
%
%% Condense thigh_data_ctr to eliminate frames with no trajectory data
Check=(any(old_thigh_data_ctr==0)); 
Exists=(all(Check==0));
Exists=squeeze(Exists)';
%
% Populate the number of gaps
Gaps=0;
for i=1:length(Exists)
    j=i-1;
    k=i+1;
    if (Exists(1,i)==0)&&(Exists(1,j)==1)
        Gaps=Gaps+1;                    
        Gap_Start(1,Gaps)=i-1;
    elseif (Exists(1,i)==0)&&(i==length(Exists))
        % [CF] needed to add a case for the end of the trial
        Gaps=Gaps;
        Gap_End(1,Gaps)=i;
    elseif (Exists(1,i)==0)&&(Exists(1,k)==1)
        Gaps=Gaps;
        Gap_End(1,Gaps)=k;
    end
end
%
% condense data for thigh_data_ctr and PtoG
line1=1;
for i=1:Frame_Range
    if Exists(1,i)==1
        thigh_data_ctr(:,:,line1)=old_thigh_data_ctr(:,:,i);
        PtoG(:,:,line1)=old_PtoG(:,:,i);
        line1=line1+1;
    end
end   
%
%% Calculating Hip Joint Center
for ctr=1:length(thigh_data_ctr)
    thigh_data_local(:,:,ctr)=PtoG(:,:,ctr)'*(thigh_data_ctr(:,:,ctr)-PELO(:,ctr)*ones(size(thigh_data_ctr(1,:,ctr))));
    current_tdl(:,:)=thigh_data_local(:,:,ctr);
    local_thigh_data(ctr,:)=current_tdl(:)';
    Trial_pelvis(ctr).PtoG = PtoG(:,:,ctr);
    Trial_pelvis(ctr).PELO = PELO(:,ctr);
end
%
hjc_local=quartichjc_unbias(local_thigh_data,MAX_ITER);
Frame_Range_Gaps=length(PtoG);
hjc_global=zeros(3,Frame_Range_Gaps);
%
for ctr=1:1:Frame_Range_Gaps
    hjc_temp(ctr,:)=Trial_pelvis(ctr).PtoG*hjc_local;
    hjc_global(:,ctr)=hjc_temp(ctr,:)'+Trial_pelvis(ctr).PELO;
end
%
% accounting for gaps in data when writing back to global
hjc_global_temp=zeros(3,Frame_Range);
Counter_Gaps=1;
for i=1:Frame_Range
    if Exists(i)==1
        hjc_global_temp(:,i)=hjc_global(:,Counter_Gaps);
        Counter_Gaps=Counter_Gaps+1;
    else
        Counter_Gaps=Counter_Gaps;
    end
end
%
% Export data to Vicon Nexus 2.2.3
hjc_global_new=zeros(3,Trial_Length);
hjc_global_new(:,First_Frame:End_Frame)=hjc_global_temp;
%
% Check to see if marker already exists [CF]
modnames = vicon.GetModelOutputNames(S);
if isempty(modnames) == 0 && strcmp(modnames(1),hjc_name) == 1
    % you can't create another of the same marker both left and right 
    % should be before SACR (so if the bodybuilder script is run then this
    % should still work)
    vicon.SetModelOutput(S, hjc_name, hjc_global_new, Exists);
elseif isempty(modnames) == 1
    % the marker will be created and output set
    vicon.CreateModeledMarker(S, hjc_name)
    vicon.SetModelOutput(S, hjc_name,hjc_global_new,Exists);
end
%