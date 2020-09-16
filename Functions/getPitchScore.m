function pitchScore = getPitchScore(f0s,f0cents,modelF0s,barwidth,useCents)
    f0s = f0s(~isnan(f0s));
    f0cents = f0cents(~isnan(f0cents));
    modelF0s = modelF0s(~isnan(modelF0s));
    
    close all
    plot(f0s,'o-')
    hold on
    plot(modelF0s,'o-')
    
    
    nsamples = max([length(f0s),length(modelF0s)]);
    ntocount = min([length(f0s),length(modelF0s)]);
    if useCents
        barwidth_cents = barwidth/100;
        modelF0s_cents = modelF0s/modelF0s(1);
        inRange = zeros(nsamples,1);
        for cnt = 1:ntocount
            inRange(cnt) = f0cents(cnt) >= modelF0s_cents(cnt)-barwidth_cents && f0cents(cnt) <= modelF0s_cents(cnt)+barwidth_cents;
        end
    else
        modelF0s = modelF0s/modelF0s(1);
        inRange = zeros(nsamples,1);
        for cnt = 1:ntocount
            inRange(cnt) = f0s(cnt) >= modelF0s(cnt)-barwidth && f0s(cnt) <= modelF0s(cnt)+barwidth;
        end
    end
    pitchScore = sum(inRange)/length(inRange);
    disp(inRange');
end
        
        
