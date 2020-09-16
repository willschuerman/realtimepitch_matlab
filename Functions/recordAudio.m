function audio = recordAudio(recordDuration,msg)
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
    msg_on = 0;

    while tend <= recordDuration
        frame = afr();
        audio = [audio; frame];
        
        if ~isempty(msg) > 0 && tstart > 0.1*recordDuration && msg_on == 0;
            h = text(0.5,0.5,msg,'FontSize',50,'HorizontalAlignment','center');
            axis off
            drawnow()
            msg_on = 1;
        end
        
        % update timer
        rt = toc(readTimer);
        timeDiff = tend-rt;
        tstart = tend+1/fs;
        tend = tstart + (spf/fs);
        
        % wait until the window is finished
        %WaitSecs(timeDiff);
    end
release(afr);
    
end