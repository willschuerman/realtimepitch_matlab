function [f0s,f0cents,t,amps,pdcs] = trackPitch_noread(s,tone,pitch_lims,amp_mod)
    %%
    fs = 44100;
    
    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    nframes = ceil(length(s)/spf);
    
    % get first audio frame (which we do not store)
    frame = s(1:spf);
    amp_tm1 = max(frame);     
    base_f0 = NaN;
    
    amp_threshold = amp_tm1*amp_mod; % set threshold for sound
    if tone == 3
        pitch_lims(1) = ceil(1/tstep)+1;
    end
    
    % initialize window and time
    sampstart = spf+1; % start on second frame
    sampend = sampstart+spf-1;
    curt = 0;
    
    % get subsequent audio frames
    cnt = 1;
    while cnt < nframes-1
        frame = s(sampstart:sampend);
        amp_t = max(frame); 
        
        [f0_t,pdc_t,base_f0] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims);

%         % extrapolate missing values
%         f0_t = fillmissing([f0s f0_t]','pchip','EndValues','extrap');
%         f0_t = f0_t(end);      

        % store
        f0s(cnt) = f0_t;
        amps(cnt) = amp_t;
        pdcs(cnt) = pdc_t;
        f0cents(cnt) = f0_t/base_f0;
        t(cnt) = curt;

        % iterate
        cnt = cnt+1;
        sampstart = sampstart+spf;
        sampend = sampstart+spf;
        curt = curt+tstep;
    end
        
end