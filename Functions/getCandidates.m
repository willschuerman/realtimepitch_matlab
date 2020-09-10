function [peaks,locs] = getCandidates(domain,edge,numCandidates,peakDistance)
% This function is for internal use only and may be changed in a future
% release.
%

% Copyright 2017-2018 The MathWorks, Inc.

numCol = cast(size(domain,2),'like',domain);
locs   = zeros(numCol,numCandidates,'like',domain);
peaks  = zeros(numCol,numCandidates,'like',domain);
lower  = edge(1);
upper  = edge(end);

for c = 1:numCol
    for b = 1:numCandidates
        [tempPeak,tempLoc] = max( domain(lower:upper,c) );
        
        idxToRemove = max(tempLoc - peakDistance + lower,lower):min(tempLoc + peakDistance + lower,upper);
        domain(idxToRemove,c) = nan;
        
        locs(c,b) = lower + tempLoc - 1;
        peaks(c,b) = tempPeak;
    end
end

end