% [EtoG, com, mag] = principalaxes(markerdata, present, reflocal);
% This function calculates the transformation from the "eigen" CS,
% the principal axes, to the global CS as well as the center of mass.
% It also passes back the eigenvalue norm.
% The arguments are:
%
% markerdata: 3xn matrix for n markers
% present (optional): nx1 vector telling which of the markers in markerdata are
% actually present in the matrix (i.e. not NaN) (ones and zeros)
%
% reflocal (optional): 3xn matrix with local positions of markers in
% reference principal CS to check for flips
%
% Ajit Chaudhari
% modified 12/30/09 [AMWC] to catch an error due to NaN in markerdata being passed
% in. It now throws a 'Missing Marker in PrincipalAxes' error.

function [EtoG, com, mag] = principalaxes(markerdata, present, reflocal),

if (nargin<2),
    present = ~isnan(markerdata(1,:));
end

truncdata = markerdata(:,present);
com = mean(truncdata,2);
p = truncdata - com*ones(1,size(truncdata,2));
psq = p.^2;

I(1,1) = sum(sum(psq(2:3,:)));
I(2,1) = sum(-p(1,:).*p(2,:));
I(3,1) = sum(-p(1,:).*p(3,:));
I(1,2) = I(2,1);
I(2,2) = sum(sum(psq([1 3],:)));
I(3,2) = sum(-p(2,:).*p(3,:));
I(1,3) = I(3,1);
I(2,3) = I(3,2);
I(3,3) = sum(sum(psq(1:2,:)));

try
    [EtoG,lambda] = eig(I,'nobalance');
catch
    error('Missing Marker Error')
end

% Added 4/21/08 Make sure we have a right-handed system
EtoG(:,3) = cross(EtoG(:,1),EtoG(:,2));

mag = norm(diag(lambda));

% Added 7/6/04, check different possible flips to make sure we have best
% solution
if (nargin>2),
	try,
        truncref = reflocal(:,present);
        L1 = EtoG' * (truncdata - com*ones(1,size(truncdata,2)));
        errmat = L1-truncref;
        errsum(1) = sum(sum(errmat.*errmat));
        
        R2 = EtoG * [-1 0 0;0 1 0;0 0 -1];
        L2 = R2' * (truncdata - com*ones(1,size(truncdata,2)));
        errmat = L2-truncref;
        errsum(2) = sum(sum(errmat.*errmat));
        
        R3 = EtoG * [1 0 0;0 -1 0; 0 0 -1];
        L3 = R3' * (truncdata - com*ones(1,size(truncdata,2)));
        errmat = L3-truncref;
        errsum(3) = sum(sum(errmat.*errmat));
        
        R4 = EtoG * [-1 0 0;0 -1 0;0 0 1];
        L4 = R4' * (truncdata - com*ones(1,size(truncdata,2)));
        errmat = L4-truncref;
        errsum(4) = sum(sum(errmat.*errmat));
        
        [minerr,best] = min(errsum);
        
        switch best,
            case 2
                EtoG = R2;
            case 3
                EtoG = R3;
            case 4
                EtoG = R4;
            otherwise
                EtoG = EtoG;
        end
	catch,
        disp(lasterr);
	end
end