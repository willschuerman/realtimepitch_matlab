function [f0s, fs, fts, amps,pdcs] = playModelSound(filename,pitch_lims)

    % frame size of 0.05 = 2205? 0.02 = 882
    spf = 882;
    afr = dsp.AudioFileReader('Filename',filename,'PlayCount',1,'SamplesPerFrame',spf);
    adw = audioDeviceWriter('SampleRate', afr.SampleRate);

    % analysis settings
    fs = afr.SampleRate;
    max_jump = 10;
    base_size = 2;

    % recording settings
    recordTime = 1;
    leadIn=0;

    % data_storage
    f0s = zeros(500,1);
    amps = zeros(500,1);
    fts = zeros(500,1);
    pdcs = zeros(500,1);
    amp_baseline = zeros(base_size,1);
    periodicity_baseline = zeros(base_size,1);

    % counters
    maxT = 0;
    counter = 1;
    readTimer = tic;
    base_counter = 1;

    % initialize first variables
    t1 = -1*leadIn;
    t2 = -1*leadIn;
    f0_1 = 0;
    pitch_found = 0;

    % load first audio sample
    audio = afr();
    while t2<=recordTime-leadIn   

        % get amplitude
        amp = max(audio);
%       % get pitch and periodicity estimate
        [f0_2,~,periodicity] = myPitchCustom(audio,fs,'Method','NCF','Range',pitch_lims,'WindowLength',length(audio),'OverlapLength',0);    
        
        if base_counter <=base_size
            amp_baseline(base_counter)=0; % <- when reading sound files, assume 0
            periodicity_baseline(base_counter)=periodicity;
            amp_threshold = 10;
            periodicity_threshold = 10;
        else
            amp_threshold = mean(amp_baseline)*10;
            periodicity_threshold = mean(periodicity_baseline)*2;

        end
        base_counter = base_counter+1;

        % get time point
        twin = linspace(maxT,maxT+(spf/fs),spf);
        t2 = twin(round(length(twin)/2))-leadIn;

        if (f0_2 > pitch_lims(1) && f0_2 < pitch_lims(2)) && amp > amp_threshold && periodicity > periodicity_threshold

            if pitch_found==0
                pitch_found = 1;
                twin = twin - min(twin); % reset timer
                t2 = twin(round(length(twin)/2));
                t1 = 0;
                fts = fts-max(fts)-t2; % shift all the times counted so far
            else
                if f0_2 > f0_1+max_jump
                    f0_2 = f0_1+max_jump;
                elseif f0_2 < f0_1-max_jump
                    f0_2 = f0_1-max_jump;
                end
            end

            %plot([t1, t2],[f0_1,f0_2],'b-','linewidth',3);
            %Make the patch (the shaded error bar)
            y = [f0_1,f0_2];
            x = [t1, t2];
            uE=y+10;
            lE=y-10;
            yP=[lE,fliplr(uE)];
            xP=[x,fliplr(x)];
            H.patch=patch(xP,yP,1);

            set(H.patch,'facecolor','b', ...
                'edgecolor','none', ...
                'facealpha',0.2, ...
                'HandleVisibility', 'off', ...
                'Tag', 'shadedErrorBar_patch')               
            hold on
        else
            f0_2 = 0;
        end

        % update stored data
        f0s(counter) = f0_2;
        amps(counter) = amp;
        fts(counter) = t2;
        pdcs(counter) = periodicity;

        % update values
        f0_1 = f0_2;
        t1 = t2;
        maxT = max(twin);

        % update time
        rt = toc(readTimer);
        timeDiff = maxT-rt;

        % plot when hits right stime stamp
        WaitSecs(timeDiff);
        drawnow    

        % play audio
        adw(audio);

        % load next audio sample 
        audio = afr();
        counter = counter+1;
    end
    release(afr); 
    release(adw);

    % cut out remaining data
    f0s = f0s(1:counter-1);
    amps = amps(1:counter-1);
    fts = fts(1:counter-1);
    pdcs = pdcs(1:counter-1);
end