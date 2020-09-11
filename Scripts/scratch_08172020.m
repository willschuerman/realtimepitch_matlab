clear; close all; clc;
set(0,'defaultfigurecolor',[1 1 1])
curdir = cd;
addpath(genpath(curdir));
%% Basic pitch tracking
stimdir = 'Files/stimuli';

files = dir(fullfile([curdir filesep stimdir],'*iN.wav'));
num_files = size(files,1);

%% Use PRAAT as gold standard, compare with pitch tracking
close all
for sf = 1:20
    subplot(4,5,sf)
    fname = [stimdir filesep files(sf).name];
    speaker_id = fname(end-5);
    switch speaker_id % WORKS BEST FOR A and I
        case 'a' 
            gender = 'm';
            pitch_lims = [70 220];
            amp_mod = 1.1;   
        case 'i' 
            gender = 'f';
            pitch_lims = [80 350];
            amp_mod = 0.1;            
    end
    [f0_praat, t_praat] = extractPitchWithPraat(fname);
    plot(t_praat,f0_praat,'r','linewidth',2);
    ylim(pitch_lims)
    hold on
    % 
    %[s,fs] = audioread(fname);
    %     soundsc(s,fs)
    % Testing incremental tracker against PRAAT

    [f0s,f0cents, fts, amps,pdcs] = trackPitch(fname,pitch_lims,amp_mod);
    plot(fts,f0s,'b','linewidth',2);
    title(files(sf).name)
end
%% Use PRAAT as gold standard, compare with pitch tracking (cents)
close all
for sf = 1:20
    subplot(4,5,sf)
    fname = [stimdir filesep files(sf).name];
    speaker_id = fname(end-5);
    switch speaker_id % WORKS BEST FOR A and I
        case 'a' 
            gender = 'm';
            pitch_lims = [70 220];
            amp_mod = 1.1;   
        case 'i' 
            gender = 'f';
            pitch_lims = [80 350];
            amp_mod = 0.1;            
    end
    [f0_praat, t_praat] = extractPitchWithPraat(fname);
    plot(t_praat,f0_praat/f0_praat(1),'r','linewidth',2);
    ylim([0 2])
    hold on
    % 
    %[s,fs] = audioread(fname);
    %     soundsc(s,fs)
    % Testing incremental tracker against PRAAT

    [f0s,f0cents, fts, amps,pdcs] = trackPitch(fname,pitch_lims,amp_mod);
    plot(fts,f0cents,'b','linewidth',2);
    title(files(sf).name)
end



%% play and draw model sound - Herz
close all
stimdir = '/Users/willschuerman/Documents/Research/Tasks/realtimepitch_matlab/files/stimuli';
files = dir(fullfile(stimdir,'*aN.wav'));
num_files = size(files,1);
sf = 3;
fname = [stimdir filesep files(sf).name];
speaker_id = fname(end-5);
switch speaker_id % WORKS BEST FOR A and I
    case 'a' 
        gender = 'm';
        pitch_lims = [70 220];
        amp_mod = 1.1;   
    case 'i' 
        gender = 'f';
        pitch_lims = [80 350];
        amp_mod = 0.1;            
end
[f0s,f0cents, fts, amps,pdcs] = trackPitch(fname,pitch_lims,amp_mod);
plot(fts,f0s,'r','linewidth',2);
hold on
[f0s, t, amps,pdcs] = plotModelPitch_preload(fname,pitch_lims,amp_mod,10,0);
%Files/stimuli/bu3-aN.wav is having difficulties, but it works fine with
%the trackPitch method.
%% play and draw model sound - Cents
close all
stimdir = '/Users/willschuerman/Documents/Research/Tasks/realtimepitch_matlab/files/stimuli';
files = dir(fullfile(stimdir,'*aN.wav'));
num_files = size(files,1);
sf = 1;
fname = [stimdir filesep files(sf).name];
speaker_id = fname(end-5);
switch speaker_id % WORKS BEST FOR A and I
    case 'a' 
        gender = 'm';
        pitch_lims = [70 220];
        amp_mod = 1.1;   
    case 'i' 
        gender = 'f';
        pitch_lims = [80 350];
        amp_mod = 0.1;            
end
[f0s, fts, amps,pdcs,myFig] = plotModelPitch(fname,pitch_lims,amp_mod,10,1);
%% record Pitch 
close all
gender = 'm';
pitch_lims = [70 220];
amp_mod = 10;
[f0s,f0cents,fts,amps,pdcs,sig] = recordPitch(pitch_lims,amp_mod);
disp('stop');

% plot results, compare with offline tracking
audiowrite('Praat/s4p.wav',0.5*sig./max(abs(sig)),44100);
subplot(3,1,1)
plot(sig)
title('extracted sound')
subplot(3,1,2)
[f0_praat, t_praat] = extractPitchWithPraat('Praat/s4p.wav');
plot(t_praat,f0_praat,'r','linewidth',3);
hold on
[testf0,~, testt, ~,~] = trackPitch('Praat/s4p.wav',pitch_lims,0.5);
plot(testt,testf0,'b','linewidth',2);
ylim(pitch_lims)
title('offline tracking')
legend('praat','my tracker')
subplot(3,1,3)
plot(fts,f0s,'b','linewidth',2);
hold on
plot(testt,testf0,'k--','linewidth',2);
yyaxis right
plot(fts,f0cents,'-.','linewidth',2);

legend('online Hz','offline Hz','online cents');
title('comparison ')


%% record and Plot
close all
stimdir = '/Users/willschuerman/Documents/Research/Tasks/realtimepitch_matlab/files/stimuli';
files = dir(fullfile(stimdir,'*aN.wav'));
num_files = size(files,1);
sf = 2;
fname = [stimdir filesep files(sf).name];
speaker_id = fname(end-5);
switch speaker_id % WORKS BEST FOR A and I
    case 'a' 
        gender = 'm';
        pitch_lims = [70 220];
        amp_mod = 1.1;   
    case 'i' 
        gender = 'f';
        pitch_lims = [80 350];
        amp_mod = 0.1;            
end
[modelF0s, fts, amps,pdcs,myFig] = plotModelPitch(fname,pitch_lims,0,10,1);
hold on
pause(1)
% user settings
gender = 'm';
pitch_lims = [70 220];
amp_mod = 10;
[f0s,f0cents,t,amps,pdcs] = plotUserPitch(pitch_lims,amp_mod,1,modelF0s,10);
%% make a trial wrapper

close all
stimdir = '/Users/willschuerman/Documents/Research/Tasks/realtimepitch_matlab/files/stimuli';
files = dir(fullfile(stimdir,'*aN.wav'));
num_files = size(files,1);
sf = 2;
fname = [stimdir filesep files(sf).name];
speaker_id = fname(end-5);
plotCents = 1;
showScore = 1;

switch speaker_id % WORKS BEST FOR A and I
    case 'a' 
        gender = 'm';
        pitch_lims = [70 220];
        model_amp_mod = 1.1;   
    case 'i' 
        gender = 'f';
        pitch_lims = [80 350];
        model_amp_mod = 0.1;            
end
[f0s,f0cents,userTime,modelF0s,modelTime] = pitchTrackTrial(fname,pitch_lims,model_amp_mod,user_amp_mod,plotCents);
if showScore
    plotPitchScore(f0s,f0cents,modelF0s,user_amp_mod,plotCents);
end
%%
runPitchExpr('test','m')
