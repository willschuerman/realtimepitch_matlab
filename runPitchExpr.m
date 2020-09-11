function runPitchExpr(subjID,gender,user_pitch_lims)
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
    if strcmpi(gender(1),'f')
        model_pitch_lims = [80 350];
        model_amp_mod = 0.1;
        files = dir(fullfile([curdir filesep stimdir],'*iN.wav'));
    else
        model_pitch_lims = [70 220];
        model_amp_mod = 1.1;
        files = dir(fullfile([curdir filesep stimdir],'*aN.wav'));
    end

    %% randomize stimuli
    num_files = size(files,1);
    trialOrder = randperm(num_files);

    %% initialize figure
    % Initialize figure
    pitch_lims = [min([user_pitch_lims(1) model_pitch_lims(1)]) max([user_pitch_lims(2) model_pitch_lims(2)])];
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
        [f0s,f0cents,userTime,modelF0s,modelTime] = pitchTrackTrial(fname,model_pitch_lims,user_pitch_lims,model_amp_mod,user_amp_mod,plotCents);
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
    text(0.5,0.5,sprintf('Total Score = %g',round(mean(scoreTracker)),2)*100,'FontSize',50,'HorizontalAlignment',center)
end