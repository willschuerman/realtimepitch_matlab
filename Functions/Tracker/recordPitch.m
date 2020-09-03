function [f0s,t,amps,pdcs] = recordPitch(fname,pitch_lims,amp_mod)
    %%    

    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    afr = dsp.AudioFileReader('Filename',fname,'PlayCount',1,'SamplesPerFrame',spf);
    adw = audioDeviceWriter('SampleRate', afr.SampleRate);
    nframes = ceil(length(s)/spf);
    % get first audio frame (which we do not store)
    frame = afr();
    amp_tm1 = max(frame); 
    t(1) = -tstep;
    
    pdc_tm1 = NaN;
    f0_tm1 = NaN;
    
    f0s(1) = NaN;
    pdcs(1) = NaN;

    amp_threshold = amp_tm1*amp_mod; % set threshold for sound
    if tone == 3
        pitch_lims(1) = ceil(1/tstep)+1;
        amp_threshold = 0;
    end
    
    
    % get subsequent audio frames
    cnt = 2;
    while ~isDone(afr) && cnt < nframes-2
        frame = afr();
        amp_t = max(frame); 
        t(cnt) = t(cnt-1)+tstep;
        
        if amp_t >= amp_threshold
            [f0_cand,pdc_cand] = getCandidateF0(frame,fs,pitch_lims,ncandidates);
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
        
        % iterate
        cnt = cnt+1;
        
    end
    
    release(afr);
    release(adw);
    
end