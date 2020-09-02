function [f0,pdc] = getCandidateF0(frame,fs,ncandidates)
    % set variables
    f0 = nan(ncandidates,1);
    pdc = nan(ncandidates,1);
    
    % hann the frame
    win = hann(length(frame));
    frame = detrend(frame.*win,'constant'); 
    [c, lag] = xcorr(frame,'coeff');

    % remove negative lags
    c(1:length(frame)) = [];
    lag(1:length(frame)) = [];
    f = fs./lag;
    
    % remove impossible frequencies
    c = c(f<400);
    lag = lag(f<400);
    f = f(f<400);
    
    % find peaks
    [pks,locs] = findpeaks(c);
        

    % convert peaks to frequency
    tmp = fs./lag(locs);
    
    % find and rank candidates?
    for nc = 1:ncandidates
        if ~isempty(tmp)
            [conf, idx] = max(pks);
            f0(nc,1) = tmp(idx);
            pdc(nc,1) = conf;
            tmp(idx) = [];
            pks(idx) = [];
        end
    end
    
    
    
    
    %%
%     subplot(1,2,1)
%     plot(lag,c)
%     hold on
%     scatter(lag(locs),pks)
%     title('peaks found at lag')
%     subplot(1,2,2)
%     scatter(tmp,pks)
%     box on
%     title('strength at frequency')    
end