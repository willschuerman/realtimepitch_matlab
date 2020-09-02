    minF = round(1/tstep);
    maxF = 400;
    freqNums= minF:maxF;
    freqPrior = ones(length(freqNums),1)/length(freqNums);
    freqLik = ones(size(freqPrior));
    %%
    freqPost = freqPrior;
    for cand = 1:3
        cf = round(f0_t(cand));
        tmp_pdf = normpdf(smallf:largef,cf,fstd)*(pdc_t(cand)*100);
        plot(cf-49:cf+50,tmp_pdf);
        idx = find(freqNums == cf);
        starti = idx-49;
        
        stopi = 
        freqLik(smallf:largef) = normpdf(smallf:largef,cf,fstd).*pdc_t(1);

        
        idx = find(freqNums == cf);
        fstd = 10;
        smallf = cf-49;
        if smallf<1
            smallf =1;
        end
        largef = cf+50;
        if largef<1
            largef =1;
        end
        
        
        plot(normpdf(smallf:largef,mean([largef,smallf]),fstd))
        freqPost = freqLik.*freqPost' / sum(freqLik.*freqPost');
    end
    %%
    close all
    plot(freqNums,freqPrior,'linewidth',2)
    hold on
    plot(freqNums,freqPost,'-','linewidth',2) % need to normalize so sums to 1
