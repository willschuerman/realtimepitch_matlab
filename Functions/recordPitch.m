function [f0s,f0cents,t,amps,pdcs,audio] = recordPitch(pitch_lims,amp_mod)
    %%    
    fs = 44100; % hard code sample rate
    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    afr = audioDeviceReader('NumChannels',1,'SampleRate',fs,'SamplesPerFrame',spf);
    audio = [];
    
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
    amp_threshold = amp_threshold*amp_mod;
    fprintf('start - amp_threshold = %g\n',amp_threshold);
    
    
    % set up for recording voice
    recordDuration = 2;
    base_f0 = NaN;


    amps(1) = amp_threshold;
    t(1) = -tstep;

    % start recording
    tstart = 0;
    tend = tstart + (spf/fs);
    readTimer = tic;
    cnt = 1;
    soundFound = 0;
    pitchFound = 0;
    while tend <= recordDuration
        frame = afr();
        amp_t = max(frame);
        %fprintf('%g ',t(cnt));

        % restart count once sound is found
        if amp_t >= amp_threshold
            [~,pdc_t,~] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims);
            if soundFound == 0
                pdc_threshold = pdc_t;
                soundFound = 1;
            end
            
            % reset once pitch is found
            if pitchFound == 0 && pdc_t > pdc_threshold
                [f0_t,pdc_t,base_f0] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims);
                cnt = 1;
                t = [];
                f0s = [];
                pdcs = [];
                amps = [];
                f0cents = [];         
                
                readTimer = tic;
                tstart = 0;
                tend = tstart + (spf/fs);
                pitchFound = 1;
            elseif pitchFound == 1 && pdc_t >= pdc_threshold*0.9 % lower threshold after first sample
                [f0_t,pdc_t,base_f0] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims);
            end            
            audio = [audio; frame];
        else
            f0_t = NaN;
            pdc_t = NaN;
        end
        

        % extrapolate missing values
        %f0_t = fillmissing([f0s f0_t]','pchip','EndValues','extrap');
        %f0_t = f0_t(end);      

        % store
        f0s(cnt) = f0_t;
        amps(cnt) = amp_t;
        pdcs(cnt) = pdc_t;
        f0cents(cnt) = f0_t/base_f0;
        t(cnt) = tstart;
        
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