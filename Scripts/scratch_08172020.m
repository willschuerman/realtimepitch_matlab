clear; close all; clc;
set(0,'defaultfigurecolor',[1 1 1])
addpath(genpath('/Users/willschuerman/Documents/Research/Tasks/realtimepitch_matlab'));
%% Basic pitch tracking
stimdir = '/Users/willschuerman/Documents/Research/Tasks/realtimepitch_matlab/files/stimuli';

files = dir(fullfile(stimdir,'*iN.wav'));
num_files = size(files,1);

%% Use PRAAT as gold standard
close all

fname = [stimdir filesep files(20).name];
speaker_id = fname(end-5);
if any(strcmp(speaker_id,{'a','b'})) % works best for a
    gender = 'm';
    pitch_lims = [70 300];
else % h,i WORKS BEST FOR I
    gender = 'f';
    pitch_lims = [80 400];
end
[f0_praat, t_praat] = extractPitchWithPraat(fname);
plot(t_praat,f0_praat,'r','linewidth',2);
ylim(pitch_lims)
hold on

[s,fs] = audioread(fname);
%soundsc(s,fs)
% Testing incremental tracker against PRAAT
[f0s, fts, amps,pdcs] = trackPitch(fname,pitch_lims);

%% Test live pitch tracking against both

