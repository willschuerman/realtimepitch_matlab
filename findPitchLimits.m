function findPitchLimits()
    %% setup for exper
    close all; clc;
    set(0,'defaultfigurecolor',[1 1 1])
    curdir = cd;
    addpath(genpath(curdir));
    %% get a relaxed pitch estimate. 
    fs = 44100;
    tstep = 0.025;
    minF = ceil(1/tstep)+1;
    maxF = 400;
    
    close all
    figure('Position',[450 450 1000 600])
    pause(0.1);
    msg = 'Please say the days of the week quicky';
    audio = recordAudio(5,msg);
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
    if minF< ceil(1/tstep)+1
        minF = ceil(1/tstep)+1;
    end
    if maxF > 400
        maxF = 400;
    end
    
    % refine pitch range
    clf
    pause(0.1);
    h = text(0.5,0.5,{'When you see the words SPEAK', 'try to sing the tone'},'FontSize',50,'HorizontalAlignment','center');
    axis off
    drawnow()
    pause(2);
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

    amp_mod = 0;
    str = 'o';
    while ~strcmpi(str,'y')
        amp_mod = amp_mod + 2;
        [modelF0s, modelTime, ~,~] = plotModelSineWave(y',fs,model_lims,0.25,10);
        hold on
        pause(1);
        [f0s,f0cents,userTime,~,~] = plotUserPitch(4,user_lims,amp_mod,0,modelF0s,10);
        prompt = {'Press "y" if your pitch line is smooth no quick jumps.','Especially at the beginning and end.','Otherwise press "n"'};
        yyaxis right
        h = text(1,0.8,prompt,'FontSize',30,'HorizontalAlignment','center');
        axis off
        drawnow()
        w = waitforbuttonpress;
        if w
           str = get(gcf, 'CurrentCharacter');
        end
        clf
        set(gca,'YLim',[0 400], 'YTick',[]);
        set(gca,'Xlim',[-0.5 3.5],'XTick',[]);
        box off
        drawnow()

    end

    
    % save values
    minF = nanmin(f0s)-20;
    maxF = nanmax(f0s)+20;
    
    if minF< ceil(1/tstep)+1
        minF = ceil(1/tstep)+1;
    end
    if maxF > 400
        maxF = 400;
    end
    fprintf('Pitch limits are %d to %d, amplitude modifieir is %d',round(minF),round(maxF), amp_mod);
    
    title(sprintf('Pitch limits are %d to %d, , amplitude modifieir is %d',round(minF),round(maxF),amp_mod));


end