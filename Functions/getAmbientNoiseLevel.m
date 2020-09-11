function silence_level = getAmbientNoiseLevel()
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
    silence_level = amp_threshold;    
    
end