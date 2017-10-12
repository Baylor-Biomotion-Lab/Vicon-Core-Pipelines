% Ajit Chaudhari
% 11/8/2007
% The Ohio State University
% [Origin,Xv,Yv,Zv,magnitude] = reshapeCS(CS_datastructure,<firstValid>,<lastValid>);
%
% This function just reshapes to allow saving individual trajectories
% through time rather than all values for each instant in time.
% Modified 4/9/08 to allow optional arguments for firstValid and last Valid

function [O,X,Y,Z,mag] = reshapeCS(CSstruct,firstValid,lastValid)
nFrames = length(CSstruct);
if nargin<3,
    lastValid = nFrames;
end
if nargin<2,
    firstValid = 1;
end

for ctr=firstValid:lastValid,
    try % If caller didn't give correct firstValid and/or lastValid the dimensions won't match
        O(:,ctr) = CSstruct(ctr).Origin(:);
        X(:,ctr) = CSstruct(ctr).XV(:);
        Y(:,ctr) = CSstruct(ctr).YV(:);
        Z(:,ctr) = CSstruct(ctr).ZV(:);
        mag(3,ctr) = CSstruct(ctr).mag; % Fills in entire rest of the array with zeros
    end
end
