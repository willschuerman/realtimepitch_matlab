clear; close all; clc;
set(0,'defaultfigurecolor',[1 1 1])
curdir = cd;
addpath(genpath(curdir));
%% Basic pitch tracking
logdir = 'Logs/';
logs = dir(logdir);
logs(1:3) = [];
logname = logs(1).name;
[f0s,f0cents,userTime,modelF0s,modelTime,tone,syll,speaker,audio,user_pitch_lims] = loadPitchData([curdir filesep logdir filesep logname]);
ntrials = size(f0s,1);

%%
tmp = f0cents;
tmp(tmp==0) = NaN;
for tonr = 1:4
    subplot(2,2,tonr)
    plot(userTime,tmp(tone==tonr,:),'o-')
    title(sprintf('tone %d',tonr))
end

%%
tmp = f0s;
tmp(tmp==0) = NaN;
for tonr = 1:4
    subplot(2,2,tonr)
    plot(userTime,tmp(tone==tonr,:),'o-')
    hold on
    title(sprintf('tone %d',tonr))
end
%%
tmp = round(f0s);
tmp(tmp<=user_pitch_lims(1))=NaN;
tmp(tmp>=user_pitch_lims(2))=NaN;
tmp = fillmissing(tmp','pchip','EndValues','none')';
for tonr = 1:4
    subplot(2,2,tonr)
    plot(userTime,tmp(tone==tonr,:),'o-')
    title(sprintf('tone %d',tonr))
end

%% scroll through each file
% 1. model pitch cents and user pitch cents
% 2. model pitch, user pitch  (online), user pitch (offline)
close all
for tr = 1:ntrials
    subplot(2,2,1)
    plot(modelTime,modelF0s(tr,:),'r-','linewidth',1.5)
    hold on
    plot(userTime,f0s(tr,:),'b-','linewidth',1.5)
    % offline tracking
    [f0s_offline,f0cents_offline,tt,~,~] = trackPitch_noread(audio(tr,:)',tone(tr),user_pitch_lims,2);
    plot(tt,f0s_offline,'g-','linewidth',1.5);
    
    title(sprintf('%s - %d, Hz',syll{tr},tone(tr)));
    subplot(2,2,2)
    plot(modelTime,modelF0s(tr,:)./modelF0s(tr,1),'r-','linewidth',1.5)
    hold on
    plot(userTime,f0cents(tr,:),'b-','linewidth',1.5)
    plot(tt,f0cents_offline,'g-','linewidth',1.5);
    title(sprintf('%s - %d, Cents',syll{tr},tone(tr)));
    
    
    subplot(2,2,1)
    plot(modelTime,modelF0s(tr,:),'r-','linewidth',1.5)
    hold on
    plot(userTime,f0s(tr,:),'b-','linewidth',1.5)
    % offline tracking
    [f0s_offline,f0cents_offline,tt,~,~] = trackPitch_noread(audio(tr,:)',tone(tr),user_pitch_lims,2);
    plot(tt,f0s_offline,'g-','linewidth',1.5);
    
    
    waitforbuttonpress
    clf
    
    
end