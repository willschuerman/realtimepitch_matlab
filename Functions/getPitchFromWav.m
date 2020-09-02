function [f0s] = getPitchFromWav(fname,newfs,pitch_lims)

    % import audio file
    [x,audiofs] = audioread(fname);
    audiott = linspace(0,length(x)/audiofs,length(x));

    % get timestep of the signal sampled at 50Hz    
    % so we can either first get the pitch at the optimal sampling rate, or
    % we can do it in smaller chunks that automatically correspond to the
    % lower sampling rate. 
  
    
    % get ratio of downsampled pitch
    [p,q] = rat(newfs/audiofs);
    
    % how many samples in the upsampled data correspond to 20ms of data?
    winsize = 0.05*audiofs; % 50ms window
    
    % get number of windows
    nframes = ceil(length(x)/winsize);
    
    % set storage
    f0high_fs = zeros(length(x),1);
    
    % start counter
    counter = 1;
    start_idx = 1;
    
    while counter < nframes && start_idx+winsize<length(x)
        %%% Get Audio Frame %%%
        audio = x(start_idx:start_idx+winsize-1);
        twin = audiott(start_idx:start_idx+winsize-1);    
        %%% Analyze audio sample %%%
        % get amplitude
        amp = max(audio);
        % get pitch and periodicity estimate
        [f0_2,~,periodicity] = myPitchCustom(audio,audiofs,'Method','NCF','Range',pitch_lims,'WindowLength',length(audio),'OverlapLength',0);    
        if counter == 1
            pdc_thresh = periodicity*1.1;
            amp_thresh = amp*1.1;
        end
        if periodicity > pdc_thresh && amp > amp_thresh
            f0high_fs(start_idx:start_idx+winsize-1) = f0_2;
        else
            f0high_fs(start_idx:start_idx+winsize-1) = 0;
        end
        fprintf('%g (%g) - %g (%g) - %g\n', amp, amp_thresh, periodicity, pdc_thresh, f0_2);
        
        % update counters
        counter = counter+1;
        start_idx = start_idx+winsize+1;
    
    end
    
    % downsample the pitch contour
    f0s = resample(movmean(f0high_fs,q*2),p,q);
        
end