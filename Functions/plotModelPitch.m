function [f0s,t,amps,pdcs,myFig] = plotModelPitch(fname,pitch_lims,amp_mod,barwidth,plotCents)
    
    [s,fs] = audioread(fname);
    
    tone = str2double(fname(end-7));
    ncandidates = 5;
    
    % set up audio extraction
    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    afr = dsp.AudioFileReader('Filename',fname,'PlayCount',1,'SamplesPerFrame',spf);
    adw = audioDeviceWriter('SampleRate', afr.SampleRate);
    nframes = ceil(length(s)/spf);
    
    
    % Initialize figure
    myFig = figure('Position',[350,500,1000,600]);
    box off
    hold on
    xlim([-0.1,nframes*tstep]);
    ylim(pitch_lims);
    
    % get first audio frame (which we do not store)
    frame = afr();
    amp_tm1 = max(frame); 
    t(1) = -tstep;
    
    % set first sample to NaN
    pdc_tm1 = NaN;
    f0_tm1 = NaN;
    base_f0 = NaN;
    
    % initialize matrix with NaN
    f0s(1) = NaN;
    pdcs(1) = NaN;
    f0cents(1) = NaN;

    % set amplitude threshold
    amp_threshold = amp_tm1*amp_mod; % set threshold for sound
    if tone == 3
        pitch_lims(1) = ceil(1/tstep)+1;
        amp_threshold = 0;
    end
    
    % initialize timer
    readTimer = tic;
    maxT = 0;
    
    
    % get subsequent audio frames
    cnt = 2;
    
    % get audio
    %frame = afr();
    while cnt < nframes-2
        amp_t = max(frame); 
        %t(cnt) = t(cnt-1)+tstep;
        twin = linspace(maxT,maxT+(spf/fs)+1/fs,spf);
        t(cnt) = twin(round(length(twin)/2));

        [f0_t,pdc_t,base_f0] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims);

        % extrapolate missing values
        f0_t = fillmissing([f0s f0_t]','pchip','EndValues','extrap');
        f0_t = f0_t(end);      
        f0cents_t = f0_t/base_f0;

        % set up for plotting segment
        x = t([cnt-1, cnt]);
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
        % store
        f0s(cnt) = f0_t;
        amps(cnt) = amp_t;
        pdcs(cnt) = pdc_t;

        % assign current values to previous value status
        amp_tm1 = amp_t;
        f0_tm1 = f0_t;
        pdc_tm1 = pdc_t;

        % update counters
        cnt = cnt+1;
        maxT = max(twin);

         % update time
        rt = toc(readTimer);
        timeDiff = maxT-rt;

        % plot when hits right stime stamp
        WaitSecs(timeDiff);
        drawnow    

        % play audio
        adw(frame);

        % load next audio sample 
        frame = afr();        

    end
    while cnt < nframes+10
        cnt = cnt+1;
         % play audio
        adw(frame);

        % load next audio sample 
        frame = afr();  
    end
     
   
    release(afr);
    release(adw);
    
end