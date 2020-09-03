function [f0s,t,amps,pdcs] = trackPitch(fname,pitch_lims)
    %%
    myLines = [];
    [~,fs] = audioread(fname);
    tone = str2double(fname(end-7));
    ncandidates = 5;
    

    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    afr = dsp.AudioFileReader('Filename',fname,'PlayCount',1,'SamplesPerFrame',spf);
    adw = audioDeviceWriter('SampleRate', afr.SampleRate);
    
    % get first audio frame (which we do not store)
    frame = afr();
    amp_tm1 = max(frame); 
    t(1) = 0;
    
    pdc_tm1 = NaN;
    f0_tm1 = NaN;
    
    f0s(1) = NaN;
    pdcs(1) = NaN;

    if tone == 3
        pitch_lims(1) = ceil(1/tstep)+1;
        amp_threshold = 0;
    else
        amp_threshold = amp_tm1*0.5; % set threshold for sound

    end
    
    
    % get subsequent audio frames
    cnt = 2;
    while ~isDone(afr)
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
            elseif isnan(f0_tm1) % the previous value is nan
                f0_t = f0_cand(1);
                pdc_t = pdc_cand(1); % easy for first sample... unless nan...
            else % actually extract f0
                % modify the probabilities of a pitch by 1) distance from previous
                % pitch, 2) tone type (i.e., we should penalize
                % decreases for tone 2 and increases for tone 4, and not penalize
                % very low pitches for tone, and 3) periodicity a.k.a.
                % confidence in measurement (literally xcorr peak height).
                
                % 1) get difference betweeen current and previous candidates (need
                % to fix so that matrices are always same size
                f0diff = f0_cand-f0_tm1;
                
                % 2) modulate differences depending on tone type
                [f0diff] = modProbs(f0diff,tone); 
                
                % 3) scale by strength of periodicity
                f0diff = f0diff.*(1-pdc_cand);
                
                % 4) select tracked pitch
                [~,idx]= min(f0diff);
                f0_t = f0_cand(idx);
                pdc_t = pdc_cand(idx);

            end
        else
            pdc_t = NaN;
            f0_t = NaN; 
        end
        
        % smooth values and extrapolate NaNs
        x = t([cnt-1, cnt]);
        y = [f0_tm1 f0_t];
        y = fillmissing(y','pchip','EndValues','extrap');
        
        
        hold on
        myLines(1) = plot(x,y,'b','linewidth',2);

        
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
        
        % plot when hits right time stamp
        drawnow  
        WaitSecs(tstep/2);
    end
    
    release(afr);
    release(adw);
    
end