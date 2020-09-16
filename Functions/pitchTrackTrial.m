function [f0s,f0cents,userTime,modelF0s,modelTime,pitchScore,audio] = pitchTrackTrial(fname,model_pitch_lims,user_pitch_lims,model_amp_mod,user_amp_mod,plotCents)

    % record and Plot
    [modelF0s, modelTime, ~,~] = plotModelPitch_preload(fname,model_pitch_lims,model_amp_mod,10,plotCents);
    hold on
    pause(0.5)
    % user settings
    amp_mod = 10;
    [f0s,f0cents,userTime,~,~,pitchScore,audio] = plotUserPitch(3,user_pitch_lims,user_amp_mod,plotCents,modelF0s,10);
end