
function [f0 acp] = f0track(s,fs,f0Range)

      s = resample(s,44100,fs);
      fs = 44100;
    
    % general
      winLen = round(fs*0.04);                                      
      winOve = round(fs*0.03);                                     
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
           time(cnt) = ini/fs;
         
         % autocorrelation  
           [c lag] = xcorr(frame,'coeff');
           [c_win lag_win] = xcorr(win,'coeff');            
            c = c./c_win; 
       
         % remove second half of the autocrrelation function
           c(winLen:end) = [];                                         
           lag(winLen:end) = [];
         
         % search peaks in range Hz
           idx_minf = find(abs(fs./lag)<=f0Range(1),1,'last');         
           idx_maxf = find(abs(fs./lag)>=f0Range(2),1,'first');
        
         % select lags and cs within the interval
           interval = [idx_minf:idx_maxf];    
           c = c(interval(:));
           lag = lag(interval(:));
           
         % select max c within the interval
           [pk,idx] = max(c);
           f0(1,cnt) = abs(fs./lag(idx));
           acp(1,cnt) = pk;
         
         % update vars
           cnt = cnt+1;
           ini = ini+winSli;
           fin = ini+winLen;
                          
       end
        
end