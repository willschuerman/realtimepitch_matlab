function runPitchExpr(subjID,gender)
    %% setup for exper
    close all; clc;
    set(0,'defaultfigurecolor',[1 1 1])
    curdir = cd;
    addpath(genpath(curdir));
    %% hardcoded values
    plotCents = 1;
    showScore = 1;
    user_amp_mod = 10;

    %% set up directories and pitch limits
    stimdir = 'Files/stimuli';
    if strcmpi(lower(gender(1)),'f')
        pitch_lims = [80 350];
        model_amp_mod = 0.1;
        files = dir(fullfile([curdir filesep stimdir],'*iN.wav'));
    else
        pitch_lims = [70 220];
        model_amp_mod = 1.1;
        files = dir(fullfile([curdir filesep stimdir],'*aN.wav'));
    end

    %% randomize stimuli
    num_files = size(files,1);
    trialOrder = randperm(num_files);

    %% initialize figure
    % Initialize figure
    myFig = figure('Position',[350,500,1000,600]);
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
        [f0s,f0cents,userTime,modelF0s,modelTime] = pitchTrackTrial(fname,pitch_lims,model_amp_mod,user_amp_mod,plotCents);
        if showScore
            pitchScore = plotPitchScore(f0s,f0cents,modelF0s,user_amp_mod,plotCents);
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
    end
    scoreTracker(tr) = pitchScore;
    axis off
    title(sprintf('Total Score = %g',mean(scoreTracker)),'FontSize',50)
end