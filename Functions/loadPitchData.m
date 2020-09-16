function [f0s,f0cents,userTime,modelF0s,modelTime,tone,syll,speaker,audio,user_pitch_lims] = loadPitchData(path)
    % look at one experiment log
    tr_files = dir(fullfile(path,'*.mat'));
    % load data
    for tr = 1:size(tr_files,1)
        tmp = load(tr_files(tr).name);
        tmpf0s{tr} = tmp.f0s;
        tmpf0cents{tr} = tmp.f0cents;
        tmpuserTime{tr} = tmp.userTime;
        tmpmodelF0s{tr} = tmp.modelF0s;
        tmpmodelTime{tr} = tmp.modelTime;
        tmpaudio{tr} = tmp.audio;
        tmpStimulus{tr} = tmp.fname;
    end
    user_pitch_lims = tmp.user_pitch_lims;
    % convert to matrices 
    f0s = nan(size(tr_files,1),max(cellfun(@length,tmpf0s)));
    f0cents = nan(size(tr_files,1),max(cellfun(@length,tmpf0cents)));
    [~,idx] = max(cellfun(@length,tmpuserTime));
    userTime = tmpuserTime{idx};
    modelF0s = nan(size(tr_files,1),max(cellfun(@length,tmpmodelF0s)));
    [~,idx] = max(cellfun(@length,tmpmodelF0s));
    modelTime = tmpmodelTime{idx};
    audio = nan(size(tr_files,1),max(cellfun(@length,tmpaudio)));
    tone = zeros(size(tr_files,1),1);
    syll = cell(size(tr_files,1),1);
    speaker = cell(size(tr_files,1),1);
    
    % load data
    for tr = 1:size(tr_files,1)
        f0s(tr,1:length(tmpf0s{tr})) = tmpf0s{tr};
        f0cents(tr,1:length(tmpf0cents{tr})) = tmpf0cents{tr};
        modelF0s(tr,1:length(tmpmodelF0s{tr})) = tmpmodelF0s{tr};
        audio(tr,1:length(tmpaudio{tr})) = tmpaudio{tr};
        tmp = tmpStimulus{tr};
        tone(tr) = str2double(tmp(end-7));
        syll{tr} = tmp(end-9:end-8);
        speaker{tr} = tmp(end-5);
    end
end