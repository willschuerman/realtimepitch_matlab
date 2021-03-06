function [f0s, t, amps,pdcs] = plotModelSineWave(s,fs,pitch_lims,amp_mod,barwidth)
    
    
    % set up audio extraction
    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    %afr = dsp.AudioFileReader('Filename',fname,'PlayCount',1,'SamplesPerFrame',spf);
    %adw = audioDeviceWriter('SampleRate', fs);
    

    title('LISTEN','FontSize',30)   
    
    % set threshold for sound
    amp_threshold = 1*amp_mod;

    % initialize variables
    base_f0 = NaN;

    % start recording
    tstart = 0;
    tend = tstart + (spf/fs);
    sampstart = 1;
    sampend = sampstart+spf-1;
    readTimer = tic;
    cnt = 1;
    soundFound = 0;
    pitchFound = 0;
    
    % play sound
    soundsc(s,fs);
    
    % load first audio sample 
    frame = s(sampstart:sampend);
    while sampend < length(s)-2*spf
        amp_t = max(frame);
        %fprintf('%g ',t(cnt));

        % restart count once sound is found
        if amp_t >= amp_threshold
            [~,pdc_t,~] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims);
            f0_t = NaN;
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
            elseif pitchFound == 1 && pdc_t >= pdc_threshold*0 % lower threshold after first sample
                [f0_t,pdc_t,base_f0] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims);
            end            
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
        
        if pitchFound==0
            f0_tm1 = NaN;
        end
        
        % plot segment
        x = [t(cnt) t(cnt)+tstep];
        y = [f0_tm1 f0_t];  
        
        % generate patch
        uE=y+barwidth;
        lE=y-barwidth;
        yP=[lE,fliplr(uE)];
        xP=[x,fliplr(x)];
        H.patch=patch(xP,yP,1);

        set(H.patch,'facecolor','b', ...
            'edgecolor','none', ...
            'facealpha',0.2, ...
            'HandleVisibility', 'off', ...
            'Tag', 'shadedErrorBar_patch')               
        hold on        
        
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
        sampstart = sampstart+spf;
        sampend = sampstart+spf-1;
        
        % wait until the window is finished
        %WaitSecs(timeDiff);
        drawnow()
        
        % play audio
        %adw(frame);

        % load next audio sample 
        frame = s(sampstart:sampend);
    end
    
while sampend <= length(s)
     % play audio
    %adw(frame);

    % load next audio sample 
    frame = s(sampstart:sampend); 
    sampstart = sampstart+spf;
    sampend = sampstart+spf-1;
end    
%release(afr);
%release(adw);
end