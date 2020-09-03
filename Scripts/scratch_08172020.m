clear; close all; clc;
set(0,'defaultfigurecolor',[1 1 1])
addpath(genpath('/Users/willschuerman/Documents/Research/Tasks/realtimepitch_matlab'));
%% Basic pitch tracking
stimdir = '/Users/willschuerman/Documents/Research/Tasks/realtimepitch_matlab/files/stimuli';

files = dir(fullfile(stimdir,'*aN.wav'));
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
%     [s,fs] = audioread(fname);
%     soundsc(s,fs)
    % Testing incremental tracker against PRAAT

    [f0s, fts, amps,pdcs] = trackPitch(fname,pitch_lims,amp_mod);
    plot(fts,f0s,'b','linewidth',2);
    title(files(sf).name)
end


%% play and draw model sound
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
[f0s, fts, amps,pdcs,myFig] = plotModelPitch(fname,pitch_lims,amp_mod,10);


