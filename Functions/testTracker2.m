function [f0, pdc, tt] = testTracker2(s,fs,pitchlims)
    if fs~=44100
        % resample
        s = resample(s,44100,fs);
        fs = 44100;
    end
    
    % general
    winLen = round(fs*0.02);                                      
    winOve = round(fs*0.01);                                     
    winSli = winLen-winOve;    
    
    
    nframe = ceil((length(s)-winLen)/(winSli));
    ncandidates = 1;
    f0 = nan(nframe,ncandidates);
    pdc = nan(nframe,ncandidates);
    tt = nan(nframe,1);
    
    if size(s,1)==1
        s=s';
    end    

    % init loop
    ini = 1;
    fin = winLen;
    cnt = 1;
    
    while fin <= length(s)
        % frame
        frame = s(ini:fin);
        win = hann(length(frame));
        frame = detrend(frame.*win,'constant'); 
        
        % time
        tt(cnt) = 1000*ini/fs;
        %%
        % autocorrelation
        [c, lag] = xcorr(frame,'coeff');
        stem(lag,c);
        
        % remove negative lags
        c(1:winLen) = [];
        lag(1:winLen) = [];
        
        % find peaks
        [pks,locs] = findpeaks(c);
        
        % peaks in range
        tmp = fs./lag(locs);
        idxs = find(tmp>pitchlims(1) & tmp<pitchlims(2));
        % max peak in range
        for cand = 1:ncandidates
            if ~isempty(idxs)
                [pk,idx] = max(pks(idxs));
                f0(cnt,cand) = tmp(idxs(idx));
                pdc(cnt,cand) = pk;
                % set prior candidate to 0
                pks(idxs(idx)) = 0;
            end
        end
        %% update vars
        cnt = cnt+1;
        ini = ini+winSli;
        fin = ini+winLen;
    end
%     % correct jumps
%     for i=1:length(f0)-1
%         if ~isnan(f0(i)) && ~isnan(f0(i+1)) && abs(f0(i+1)-f0(i))>5
%             f0(i) = f0(i+1);
%         end
%     end
%     
%     % smooth
%     f0 = movmean(f0,5);
end
       

%% things that don't work
%         % periodogram
%         [pxx,f] = periodogram(frame,[],1:400,fs);
%         
%         % get estimate from periodogram
%         [pks,freqs] = findpeaks(pxx,f);
%         [~,idx] = max(pks);
%         cf = freqs(idx);
%         pitchlims = [cf-10 cf+10];
%         plims(cnt,1) = pitchlims(1);
%         plims(cnt,2) = pitchlims(2);
