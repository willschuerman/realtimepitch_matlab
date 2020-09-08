function [f0s,t,amps,pdcs] = recordPitch(pitch_lims,amp_mod)
    %%    
    fs = 44100; % hard code sample rate
    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    afr = audioDeviceReader('NumChannels',1,'SampleRate',fs,'SamplesPerFrame',spf);
    
    % set up for baseline
    baseDuration = 1;
    amp_threshold = 0;
    tstart = 0;
    tend = tstart + (spf/fs);
    readTimer = tic;
    while tend <= baseDuration
        frame = afr();
        amp_t = max(frame);
        amp_threshold = mean([amp_threshold,amp_t]);
        rt = toc(readTimer);
        timeDiff = tend-rt;
        tstart = tend+1/fs;
        tend = tstart + (spf/fs);
        WaitSecs(timeDiff);
    end
    
    
    % set up for recording voice
    recordDuration = 2;
    
    % initialize variables
    pdc_tm1 = NaN;
    f0_tm1 = NaN;
    f0s(1) = NaN;
    pdcs(1) = NaN;
    t(1) = -tstep;

    % start recording
    tstart = 0;
    tend = tstart + (spf/fs);
    readTimer = tic;
    cnt = 2;
    soundFound = 0;
    while tend <= recordDuration
        frame = afr();
        amp_t = max(frame);
        t(cnt) = t(cnt-1)+tstep;
        
        if amp_t >= amp_threshold
            % if this is the first time sound is found, reset timer
            if soundFound == 0
                tstart = 0;
                cnt = 2;
            end
            [f0_cand,pdc_cand] = getCandidateF0(frame,fs,pitch_lims,5);
            if isempty(f0_cand) && isnan(f0_tm1)
                pdc_t = NaN;
                f0_t = NaN;
            elseif isempty(f0_cand) % if the current value is nan
                pdc_t = NaN;
                f0_t = NaN;
            else
                f0_t = f0_cand(1); % using best candidate gives best results
                pdc_t = pdc_cand(1);
            end
        else
            pdc_t = NaN;
            f0_t = NaN; 
        end
        % extrapolate missing values
        f0_t = fillmissing([f0s f0_t]','pchip','EndValues','extrap');
        f0_t = f0_t(end);      

        % store
        f0s(cnt) = f0_t;
        amps(cnt) = amp_t;
        pdcs(cnt) = pdc_t;
        
        % assign current values to previous value status
        amp_tm1 = amp_t;
        f0_tm1 = f0_t;
        pdc_tm1 = pdc_t;
        
        % update counter
        cnt = cnt+1;
        
        % update timer
        rt = toc(readTimer);
        timeDiff = tend-rt;
        tstart = tend+1/fs;
        tend = tstart + (spf/fs);
        
        % wait until the window is finished
        WaitSecs(timeDiff);
    end
release(afr);
    
end