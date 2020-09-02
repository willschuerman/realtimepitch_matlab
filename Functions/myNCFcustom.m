function [f0,conf] = myNCFcustom(y,params,extraParams)
% This function is for internal use only and may be changed in a future
% release.
%
% Algorithm based on:
% B.S. Atal, "Automatic Speaker Recognition Based on Pitch
% Contours." The Journal of the Acoustical Society of America 52,
% 1687 (1972).
%

%   Copyright 2017-2018 The MathWorks, Inc.

%#codegen

% Read in state and parameter variables
edge = round(params.SampleRate./fliplr(params.Range));
r    = cast(size(y,1),'like',y);

% Autocorrelation
mxl = min(edge(end),r - 1);
m2  = 2^nextpow2(2*r - 1);
c1  = real(ifft(abs(fft(y,m2,1)).^2,[],1))./sqrt(m2);
Rt  = [c1(m2 - mxl + (1:mxl),:); c1(1:mxl+1,:)];

% Energy of original signal, y
yRMS = sqrt(Rt(edge(end)+1,:));

% Clip out the lag domain of based on pitch search range
lag  = Rt( (edge(end)+1+edge(1)):end, : );

% Repmat for vectorized computation
yRMS = repmat(yRMS,size(lag,1),1);

% Normalize lag domain energy by input signal energy
lag = lag./yRMS;

% Zero-pad domain so time locs can be easily interpreted.
domain = [zeros(edge(1)-1,size(lag,2));lag];

% Peak picking
[peak,locs] = audio.internal.pitch.getCandidates( ...
    domain, ...
    edge, ...
    extraParams.NumCandidates, ...
    extraParams.MinPeakDistance);


% Convert lag domain to frequency
f0 = params.SampleRate./locs;
%conf = peak./sum(abs(peak),2); % <--- CHANGED HERE
conf = peak;
end