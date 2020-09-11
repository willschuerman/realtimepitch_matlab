function findPitchLimits()
%% get a relaxed pitch estimate. 
    fs = 44100;
    
    minF = round(1/tstep)+1;
    maxF = 400;
    
    close all
    figure('Position',[450 450 1000 1000])
    pause(0.1);
    h = text(0.5,0.5,'Please say the days of the week quicky','FontSize',50,'HorizontalAlignment','center');
    axis off
    drawnow()
    audio = recordAudio(5);
    t = linspace(0,length(audio)/fs,length(audio));
    clf
    axis off
    h = text(0.5,0.5,'Please wait. Analyzing...','FontSize',50,'HorizontalAlignment','center');

    drawnow()
    audiowrite('tmp.wav',0.5*audio./max(abs(audio)),fs);
  
    % first, get an estimate of the amplitude modifier
    amp_mod = 0;
    [f0s,f0cents,tt,amps,pdcs] = trackPitch('tmp.wav',[minF maxF],amp_mod);
    cnt = 1;
    while max(abs(diff(f0s)))>=50
        amp_mod = amp_mod+1;
        [f0s,f0cents,tt,amps,pdcs] = trackPitch('tmp.wav',[minF maxF],amp_mod);
        cnt = cnt+1;
        if cnt>1000 || all(isnan(f0s))
            close all
            error('Please try again');
        end
    end
    meanF = nanmean(f0s);
    minF = meanF-100;
    maxF = meanF+100;
    if minF< round(1/tstep)+1
        minF = round(1/tstep)+1;
    end
    if maxF > 400
        maxF = 400;
    end
    
    % refine pitch range
    clf
    pause(0.1);
    h = text(0.5,0.5,'Listen and repeat','FontSize',50,'HorizontalAlignment','center');
    axis off
    drawnow()
    pause(1);
    clf
    set(gca,'YLim',[0 400], 'YTick',[]);
    set(gca,'Xlim',[-0.5 3.5],'XTick',[]);
    box off
    drawnow()

    %soundsc(y,fs);    
    fs = 44100;
    t = 0:1/fs:2;
    y = chirp(t,minF,2,maxF,'linear');
    
    y = [y fliplr(y)];
    win = hann(length(y));
    y = y.*win';

    t = linspace(0,length(y)/fs,length(y));
    model_lims = [minF maxF];
    user_lims = [minF maxF];

    
    [modelF0s, modelTime, ~,~] = plotModelSineWave(y',fs,model_lims,0.25,10);
    hold on
    [f0s,f0cents,userTime,~,~] = plotUserPitch(user_lims,3,0,modelF0s,10);
    
    minF = nanmin(f0s)-20;
    maxF = nanmax(f0s)+20;
    
    if minF< round(1/tstep)+1
        minF = round(1/tstep)+1;
    end
    if maxF > 400
        maxF = 400;
    end
    fprintf('Pitch limits are %d to %d',round(minF),round(maxF));
    close all
    
    

end