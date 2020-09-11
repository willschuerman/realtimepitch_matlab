function audio = recordAudio(recordDuration)
    %%    
    fs = 44100; % hard code sample rate
    tstep = 0.025; % minimum frequency is 1/tstep
    spf = ceil(tstep*fs); % will need to edit this
    afr = audioDeviceReader('NumChannels',1,'SampleRate',fs,'SamplesPerFrame',spf);
    audio = [];
    
    % start recording
    tstart = 0;
    tend = tstart + (spf/fs);
    readTimer = tic;

    while tend <= recordDuration
        frame = afr();
        audio = [audio; frame];
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