function [f0_praat, t_praat] = extractPitchWithPraat(fname)

%% set global parameters
pitch_time_step = 0.0;
no_candidates = 10;
silence_threshold = 0.03; % frames that do not contain amplitudes above this threshold 
% (relative to the global maximum amplitude), are probably silent. (default
% is 0.03);
voicing_threshold = 0.005; % the strength of the unvoiced candidate, relative to the maximum possible autocorrelation. 
% To increase the number of unvoiced decisions, increase this value.
% (default is 0.45);
very_accurate = 1; % default is 0
octave_jump_cost = 3; % default is 0.35
voiced_unvoiced_cost = 2; %default is 0.14
gender = 'm';

%% set pitch_lims based on sound file
% a and b are male
speaker_id = fname(end-5);
if any(strcmp(speaker_id,{'a','b'}))
    gender = 'm';
    pitch_lims = [70 350];
    octave_cost = 0.0001;
else
    gender = 'f';
    pitch_lims = [80 400];
    octave_cost = 0.1;
end

[x1,fs] = audioread(fname);

f0_praat = get_praat_pitch(x1,pitch_lims,fs,pitch_time_step,no_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voiced_unvoiced_cost);

% extract reading
t_praat = f0_praat.frame_taxis;
t_praat = t_praat - min(t_praat);
f0_praat = f0_praat.freq;