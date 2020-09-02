function [f0, time] = f0track2(s,sr,range)
    % resample
      s = resample(s,44100,sr);
      sr = 44100;
    % general
      winLen = round(sr*0.04);
      winOve = round(sr*0.03);
      winSli = winLen-winOve;
      if size(s,1)==1
      s=s';
      end
    % init loop
      ini = 1;
      fin = winLen;
      cnt = 1;
      while fin <= length(s)
         % frame
           frame = s(ini:fin);
           win = hann(length(frame));
           frame = detrend(frame.*win,'constant');
         % time
           time(cnt) = 1000*ini/sr;
         % autocorrelation
           [c lag] = xcorr(frame,'coeff');
         % remove negative lags
           c(1:winLen) = [];
           lag(1:winLen) = [];
         % find peaks
           [pks,locs] = findpeaks(c);
         % peaks in range
           temp = sr./lag(locs);
           idxs = find(temp>range(1) & temp<range(2));
         % max peak in range
           if isempty(idxs)==0
           [~,idx] = max(pks(idxs));
           f0(1,cnt) = temp(idxs(idx));
           else
           f0(1,cnt) = NaN;
           end
         % update vars
           cnt = cnt+1;
           ini = ini+winSli;
           fin = ini+winLen;
      end
      % correct jumps
      for i=1:length(f0)-1
          if isnan(f0(i))==0 & isnan(f0(i+1))==0 & abs(f0(i+1)-f0(i))>5
          f0(i) = f0(i+1);
          end
      end
      % smooth
      f0 = movmean(f0,5);
end