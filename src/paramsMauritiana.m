% custom parameters for segmenting MAURITIANA

Params.maxIPI = round(Params.Fs/5);   %if no other pulse within this many ticks, do not count as a pulse
Params.minIPI = round((Params.Fs/60)/2)*4;
% Params.frequency = 900;               %if best matched scale is greater than this frequency, do not count as a pulse

% Params.find_sine = false;              % yakuba and santomea do not produce sine song - makes song segmentation MUCH faster

% %estimating noise - yak/san song has much higher frequency
% Params.low_freq_cutoff = 100;         % exclude data below this frequency
% Params.high_freq_cutoff = 1000;        % exclude data above this frequency
% Params.cutoff_sd = 3;                 % exclude data above this multiple of the std. deviation - more restrictive now
% Params.pWid = round(Params.Fs/125)+1; % 4 * pWid is length of pulse kept in ticks ; approx pulse width
% Params.fc = [100:25:1000];             % wavelet scales, in Hertz

