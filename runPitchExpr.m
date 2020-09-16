function runPitchExpr(subjID,gender,user_pitch_lims,user_amp_mod)
    %% setup for exper
    close all; clc;
    set(0,'defaultfigurecolor',[1 1 1])
    curdir = cd;
    addpath(genpath(curdir));
    %% hardcoded values
    plotCents = 1;
    showScore = 1;

    %% set up directories and pitch limits
    stimdir = 'Files/stimuli';
    if strcmpi(gender(1),'f')
        model_pitch_lims = [80 350];
        model_amp_mod = 0.1;
        files = dir(fullfile([curdir filesep stimdir],'*iN.wav'));
    else
        model_pitch_lims = [70 220];
        model_amp_mod = 1.1;
        files = dir(fullfile([curdir filesep stimdir],'*aN.wav'));
    end

    logdir = sprintf('Logs/%s',subjID);
    if ~exist(logdir,'dir')
        mkdir(logdir)
    end
    %% randomize stimuli
    num_files = size(files,1);
    trialOrder = randperm(num_files);

    %% initialize figure
    % Initialize figure
    pitch_lims = [min([user_pitch_lims(1) model_pitch_lims(1)]) max([user_pitch_lims(2) model_pitch_lims(2)])];
    myFig = figure('Position',[350,500,1000,600]);
    
    %% show instructions
    text(0.5,0.8,'You are going to hear some words spoken in Mandarin Chinese.','FontSize',30,'HorizontalAlignment','center')
    text(0.5,0.7,'Each word has a specific "pitch contour" (the way the pitch changes)','FontSize',30,'HorizontalAlignment','center')
    text(0.5,0.6,'When you see the word "SPEAK" at the top of the screen','FontSize',30,'HorizontalAlignment','center')
    text(0.5,0.5,'Try to repeat the words as best you can','FontSize',30,'HorizontalAlignment','center')
    text(0.5,0.4,'with the same pitch and duration','FontSize',30,'HorizontalAlignment','center')
    text(0.5,0.1,'Press any key to start','FontSize',30,'HorizontalAlignment','center')
    axis off
    waitforbuttonpress;
    clf
    %% setup figure for actual experiment
    box off
    hold on
    xlim([-0.1,0.5]);
    if plotCents
        ylim([0 2]);
    else
        ylim(pitch_lims);
    end
    set(gca,'XTick',[],'YTick',[]);
    
    %% present stimuli
    for tr = 1:length(trialOrder)
        fname = [stimdir filesep files(trialOrder(tr)).name];
        disp(fname)
        [f0s,f0cents,userTime,modelF0s,modelTime,pitchScore,audio] = pitchTrackTrial(fname,model_pitch_lims,user_pitch_lims,model_amp_mod,user_amp_mod,plotCents);
        
        f0s = f0s(~isnan(f0s));
        userTime = userTime(1:length(f0s));
        f0cents = f0cents(~isnan(f0cents));
        modelF0s = modelF0s(~isnan(modelF0s));
        modelTime = modelTime(1:length(modelF0s));
        nsamples = max([length(f0s),length(modelF0s)]);
        pitchScore = pitchScore(1:nsamples);
        
        % debug
%         close all
%         plot(modelTime,modelF0s,'o-')
%         hold on
%         plot(userTime,f0s,'ro-')
%         scatter(userTime(logical(pitchScore)),f0s(logical(pitchScore)),'go','filled')

        if showScore
            title(sprintf('Score = %g',round(mean(pitchScore)*100)),'FontSize',30)
            drawnow()
            scoreTracker(tr) = round(mean(pitchScore)*100);
        end
        % reset figure
        pause(1.5);
        clf;
        pause(0.5);
        box off
        hold on
        xlim([-0.1,0.5]);
        if plotCents
            ylim([0 2]);
        else
            ylim(pitch_lims);
        end
        set(gca,'XTick',[],'YTick',[]);
        
        % save trial data
        save([logdir filesep sprintf('%s_tr%d.mat',subjID,tr)],'tr','fname','subjID','user_pitch_lims','f0s','f0cents','userTime','modelF0s','modelTime','pitchScore','audio');
        
    end
    clf
    axis off
    if showScore
        text(0.5,0.5,sprintf('Total Score = %g',round(mean(scoreTracker))),'FontSize',50,'HorizontalAlignment','center')
    end
    
end