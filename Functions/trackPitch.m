function [f0s,f0cents,t,amps,pdcs] = trackPitch(fname,pitch_lims,amp_mod)
    %%
    [s,fs] = audioread(fname);
    tone = str2double(fname(end-7));
    ncandidates = 5;
    

    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    afr = dsp.AudioFileReader('Filename',fname,'PlayCount',1,'SamplesPerFrame',spf);
    nframes = ceil(length(s)/spf);
    
    % get first audio frame (which we do not store)
    frame = afr();
    amp_tm1 = max(frame); 
    t(1) = -tstep;
    
    pdc_tm1 = NaN;
    f0_tm1 = NaN;
    base_f0 = NaN;
    
    f0s(1) = NaN;
    pdcs(1) = NaN;
    f0cents(1) = NaN;

    amp_threshold = amp_tm1*amp_mod; % set threshold for sound
    if tone == 3
        pitch_lims(1) = ceil(1/tstep)+1;
        amp_threshold = 0;
    end
    
    
    % get subsequent audio frames
    cnt = 2;
    while ~isDone(afr) && cnt < nframes-1
        frame = afr();
        amp_t = max(frame); 
        t(cnt) = t(cnt-1)+tstep;
        
        [f0_t,pdc_t,base_f0] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims);

%         % extrapolate missing values
%         f0_t = fillmissing([f0s f0_t]','pchip','EndValues','extrap');
%         f0_t = f0_t(end);      

        % store
        f0s(cnt) = f0_t;
        amps(cnt) = amp_t;
        pdcs(cnt) = pdc_t;
        f0cents(cnt) = f0_t/base_f0;
        
        % assign current values to previous value status
        amp_tm1 = amp_t;
        f0_tm1 = f0_t;
        pdc_tm1 = pdc_t;
        
        % iterate
        cnt = cnt+1;
        
    end
    
    release(afr);
    
end