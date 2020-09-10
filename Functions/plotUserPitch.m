function [f0s,f0cents,t,amps,pdcs,audio] = plotUserPitch(pitch_lims,amp_mod,plotCents,modelF0s,barwidth)
    % set up recording device   
    fs = 44100; % hard code sample rate
    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    afr = audioDeviceReader('NumChannels',1,'SampleRate',fs,'SamplesPerFrame',spf);
    audio = [];
    
    % adjust barwidth depending on plottype
    if ~isempty(barwidth)
        if plotCents
            barwidth = barwidth/100;
        end
    end
    if ~isempty(modelF0s)
        if plotCents
            modelF0s = modelF0s/modelF0s(1);
        end
    end    
    % set up for baseline
    title('#####','FontSize',30)
    drawnow()
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
    
    % set recording duration
    recordDuration = 3;
    
    % initialize variables
    pdc_tm1 = NaN;
    f0_tm1 = NaN;
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
    
    % start recording period
    title('SPEAK','FontSize',30)
    drawnow()
    while tend <= recordDuration
        frame = afr();
        amp_t = max(frame);

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
                
                % set up first value for plotting
                f0_tm1 = f0_t;
                
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
        
        % store
        f0s(cnt) = f0_t;
        amps(cnt) = amp_t;
        pdcs(cnt) = pdc_t;
        f0cents(cnt) = f0_t/base_f0;
        t(cnt) = tstart;
        
        % plot segment
        x = [t(cnt) t(cnt)+tstep];
        if plotCents
            y = [f0_tm1/base_f0 f0_t/base_f0];  
        else
            y = [f0_tm1 f0_t];  
        end
        % if barwidth or modelF0s is unspecified, just plot a red line. 
        if isempty(barwidth) || isempty(modelF0s)
            plot(x,y,'r','linewidth',4);
        else
            % if modelF0s is specified, plot a green line when within
            % target boundaries.
            if cnt <= length(modelF0s)
                if y(2) >= modelF0s(cnt)-barwidth && y(2) <= modelF0s(cnt)+barwidth
                    plot(x,y,'g','linewidth',4);
                else
                    plot(x,y,'r','linewidth',4);
                end
            end
        end
        
        
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
        drawnow()
        WaitSecs(timeDiff);
    end
release(afr);
title('')

end