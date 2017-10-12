% Ajit Chaudhari
% 11/8/2007
% The Ohio State University
% [index] = matchLabels(list1,list2);
% This function takes the labels in list1 and finds their counterparts in
% list2.  The output is the size of list1 and contains the index of that
% label in list2.  Both lists must be 1-D cell arrays.

function [index] = matchLabels(list1,list2)

nlabels = length(list1);
listarray = char(list2)';
listarray(end+1,:) = ' ';
fieldwidth = size(listarray,1);
listarray2 = squeeze(listarray(:)');
for ctr=1:nlabels,
    label = list1{ctr};
    label = [label ' ']; % Make sure we only get whole-word matches
    found = strfind(listarray2,label);
    if ~isempty(found),
        pick = mod(found-1,fieldwidth); % If found has more than 1 element, pick=0 for the label that starts with what we're looking for
        bestfound = found(~pick);
        index(ctr) = floor(bestfound(1)/fieldwidth)+1; % Use bestfound(1) just in case there are still multiple matches
    else
        index(ctr) = 0;
    end
end