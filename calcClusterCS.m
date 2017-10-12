% Ajit Chaudhari
% 11/8/2007
% [clusterCS] = calcClusterCS(markerdata,scalefactor,reflocal,present);
% clusterCS.Origin is the origin of the cluster CS in global coordinates. The XV, YV,
% and ZV describe points along the X,Y,Z local axes (in global
% coordinates).
% mag is the eigenvalue norm of the cluster.
%
% scalefactor is an optional parameter to scale the X,Y,Z vectors for
% visualization (default=100 mm).
% Modified 2/24/08 to take a set of local coordinates from the reference
% trial and to return it (creates a new one if one was not passed in).
% Modified 4/19/08 to take an optional vector present that tells it which
% of the markers in reflocal are present in markerdata. Allows a
% subset of markers present during the reference trial to be used in the dynamic trial.
% Modified 7/24/08 to force all markers present in reference trial to be
% present in the dynamic trial as well.
% Modified 12/30/09 to not create an error dialog, just the error. Now the
% caller can catch the error and figure out more information.


function [clusterCS,reflocaln] = calcClusterCS(markerdata,scalefactor,reflocal,present)

DEFAULT_SCALE = 100;

if nargin<2,
    scalefactor = DEFAULT_SCALE;
else if isempty(scalefactor),
        scalefactor = DEFAULT_SCALE;
    end
end

nmarkers = size(markerdata,2); % markerdata is 3xn

if (nargin>=3 && ~isempty(reflocal)),
    nrefmarkers = size(reflocal,2); % reflocal should be 3xn
    if (nrefmarkers<=nmarkers), % Changed from >= to == 7/24/08, changed from == to <= 9/5/12
        if nargin<4,
            present = logical(ones(nrefmarkers,1));
        end
        [EtoG,clusterCS.Origin,clusterCS.mag] = principalaxes(markerdata,present,reflocal);
        reflocaln = reflocal;
    else
        error('Mismatched Marker Error');
    end
else
    [EtoG,clusterCS.Origin,clusterCS.mag] = principalaxes(markerdata);
    reflocaln = EtoG' * (markerdata - clusterCS.Origin*ones(1,nmarkers));
end
clusterCS.XV = EtoG*[scalefactor;0;0]+clusterCS.Origin;
clusterCS.YV = EtoG*[0;scalefactor;0]+clusterCS.Origin;
clusterCS.ZV = EtoG*[0;0;scalefactor]+clusterCS.Origin;
