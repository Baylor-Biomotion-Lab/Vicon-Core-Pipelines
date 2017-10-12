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
% Modified 2/24/08 to write local coordinates of cluster markers to file
% (FBPCT_staticPECS.m) or to read local coordinates of cluster markers from
% reference file (FBPCT_dynamicPECS.m).
% Modified 12/30/09 [AMWC] to write more helpful error message if there are
% missing markers.
% Modified 1/5/10 [AMWC] to collapse back Static and Dynamic PECS code
% since there is so much overlap. This way we won't have to change things
% in so many places.

clear

load all_labels
trial_type = DYNAMIC;

FBPCT_PECS
