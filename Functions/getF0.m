function [f0_t,pdc_t,base_f0] = getF0(base_f0,amp_t,amp_threshold,frame,fs,pitch_lims)
    if amp_t >= amp_threshold
        [f0_cand,pdc_cand] = getCandidateF0(frame,fs,pitch_lims);
        if isempty(f0_cand) && isnan(f0_tm1)
            pdc_t = NaN;
            f0_t = NaN;
        elseif isempty(f0_cand) % if the current value is nan
            pdc_t = NaN;
        else
            f0_t = f0_cand(1); % using best candidate gives best results
            pdc_t = pdc_cand(1);
            if isnan(base_f0)
                base_f0 = f0_t;
            end
        end
    else
        pdc_t = NaN;
        f0_t = NaN; 
    end


end