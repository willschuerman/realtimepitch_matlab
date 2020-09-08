function praat_pitch = get_praat_pitch(sig,pitch_lims,fs,pitch_time_step,no_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voiced_unvoiced_cost)

iarg = 1;
iarg = iarg + 1; if nargin < iarg || isempty(pitch_lims), pitch_lims = [50 350]; end
iarg = iarg + 1; if nargin < iarg || isempty(fs), fs = 44100; end
iarg = iarg + 1; if nargin < iarg || isempty(pitch_time_step), pitch_time_step = 0.01; end
iarg = iarg + 1; if nargin < iarg || isempty(no_candidates), no_candidates = 5; end
iarg = iarg + 1; if nargin < iarg || isempty(very_accurate), very_accurate = 1; end
iarg = iarg + 1; if nargin < iarg || isempty(silence_threshold), silence_threshold = 0.5; end
iarg = iarg + 1; if nargin < iarg || isempty(voicing_threshold), voicing_threshold = 0.1; end
iarg = iarg + 1; if nargin < iarg || isempty(octave_cost), octave_cost = 0.1; end
iarg = iarg + 1; if nargin < iarg || isempty(octave_jump_cost), octave_jump_cost = 3; end
iarg = iarg + 1; if nargin < iarg || isempty(voiced_unvoiced_cost), voiced_unvoiced_cost = 10; end
iarg = iarg + 1; if nargin < iarg || isempty(frame_adv), frame_adv = 1/400; end % in seconds, I think
iarg = iarg + 1; if nargin < iarg || isempty(voicing_thresh), voicing_thresh = 0.45; end % lower this to process Matt's pitch
iarg = iarg + 1; if nargin < iarg || isempty(yes_plot), yes_plot = 0; end

minimum_pitch = pitch_lims(1);
maximum_pitch = pitch_lims(2);

curdir = cd;
cd([curdir filesep 'Praat']);
audiowrite('s4p.wav',0.5*sig./max(abs(sig)),fs);

if ispc
    [status,result] = system(sprintf('sendpraat praat "execute "%s\\pitch_proc.praat\" %d, %d, %f, %d, %d, %f, %f, %f, %f, %f, %d"', ...
            curdir, pitch_time_step, pitch_lims(1), no_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voiced_unvoiced_cost, pitch_lims(2)));
elseif ismac
    [status,result] = system(sprintf('/Applications/Praat.app/Contents/MacOS/Praat --run pitch_proc.praat %d, %d, %f, %d, %d, %f, %f, %f, %f, %f, %d',...
        pitch_time_step, pitch_lims(1), no_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voiced_unvoiced_cost, pitch_lims(2)));
end
 
praat_pitch_file = 's4p.praat_pitch';
fid = fopen(praat_pitch_file,'r');
state = 0;
iframe = 0;
while 1
  tline = fgetl(fid);
  if ~ischar(tline), break, end
  textline = strtrim(tline);
  switch state
    case 0
      hdr_var_name = sscanf(textline,'%[^ ] =',1);
      switch hdr_var_name
        case 'xmin', praat_pitch.xmin = sscanf(textline,'xmin = %f');
        case 'xmax', praat_pitch.xmax = sscanf(textline,'xmax = %f');
        case 'nx',   praat_pitch.nx = sscanf(textline,'nx = %f');
        case 'dx',   praat_pitch.dx = sscanf(textline,'dx = %f');
        case 'x1',   praat_pitch.x1 = sscanf(textline,'x1 = %f');
        otherwise
          if strcmp(textline,'candidates [1]:')
             iframe = iframe + 1;
             state = 2;
          end
      end
    case 1
      if strcmp(textline,'candidates [1]:')
        iframe = iframe + 1;
        state = 2;
      else
        state = 1;
      end
    case 2
      praat_pitch.freq(iframe) = sscanf(textline,'frequency = %f');
      state = 3;
    case 3
      praat_pitch.strn(iframe) = sscanf(textline,'strength = %f'); 
      state = 1;
  end
end
fclose(fid);
praat_pitch.nframes = iframe;
praat_pitch.frame_taxis = praat_pitch.x1 + (0:(praat_pitch.nx - 1))*praat_pitch.dx;

if yes_plot
  hf = figure;
  nsp = 3; isp = 0;
  isp = isp + 1; hax(isp) = subplot(nsp,1,isp);
  lensig = length(sig);
  taxis = (0:(lensig-1))/fs;
  hpl = plot(taxis,sig);
  isp = isp + 1; hax(isp) = subplot(nsp,1,isp);
  hpl = plot(praat_pitch.frame_taxis,praat_pitch.freq);
  isp = isp + 1; hax(isp) = subplot(nsp,1,isp);
  hpl = plot(praat_pitch.frame_taxis,praat_pitch.strn);
end

cd(curdir); % return to original directory

end