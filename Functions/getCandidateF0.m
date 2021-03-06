function [f0,pdc] = getCandidateF0(y,fs,pitch_lims)
    ncandidates = 5; % hard coded
    % set variables
    f0 = nan(ncandidates,1);
    pdc = nan(ncandidates,1);
    
    %% testing out pre-emphasis
    % the speech signal was filtered through a 1-kHz low-pass filter and each sample of the low-pass 
    % filtered signal was raised to the third power to emphasize the high-amplitude portions of the speech waveform
    y = y.^3;
    %%
    
    
    edge = round(fs./fliplr(pitch_lims)); % gives pitch lims by lags. interesting
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
    fvec = fs./(1:length(domain));
    
    % Peak picking
    [pdc,locs] = getCandidates(domain,edge,ncandidates,20);
    
    % Convert lag domain to frequency
    f0 = fs./locs;
  

end