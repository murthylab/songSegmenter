function noise = EstimateNoise(xsong,ssf,param,low_freq_cutoff,high_freq_cutoff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Function runs MultiTaperFTest (multitaper spectral analysis) on recording
%%Finds putative noise by fitting a mixture model to the distribution of
%%power values (A) and taking the lowest mean (±var) as noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off','stats:gmdistribution:FailedToConverge')
%find freq range of ssf.A to analyze
low_freq_index = find(ssf.f>param.low_freq_cutoff,1,'first');
high_freq_index = find(ssf.f<param.high_freq_cutoff,1,'last');

%Test range of gmdistribution.fit parameters
Nmix = 10; % number of mixture components to test
AIC=nan(1,Nmix); % previous inf*zero equals NaN; hard-coded size 1x6 here conflicted with k=1:10 in the following loop
obj=cell(1,Nmix);
% sum 'power' over frequencies - yields envelope
% shouldn't we take the log to be more robust to outliers????
A_sums = sum(abs(ssf.A(low_freq_index:high_freq_index,:)));

for k=1:Nmix
   try % prevent failure in case of "ill-conditioned covariance matrices"
      obj{k}=gmdistribution.fit(A_sums',k);
      if obj{k}.Converged == 1 % keep AIC only for those that converged
         AIC(k)=obj{k}.AIC;
      end
   catch ME
      disp(ME.getReport())
   end
end
[~, numComponents] = min(AIC);%best fit model
%find the dist in the mixture model with the lowest mean - this is noise
noise_index = find(obj{numComponents}.mu == min(obj{numComponents}.mu));
presumptive_noise_mean = obj{numComponents}.mu(noise_index);
presumptive_noise_var = obj{numComponents}.Sigma(noise_index);
presumptive_noise_SD = sqrt(presumptive_noise_var);

%% Collect samples of noise (all segments with A = mean + SD * cutoff_sd) and concatenate
noise_cutoff = presumptive_noise_mean + (presumptive_noise_SD * param.cutoff_sd);
% get indices of ssf.A < noise_cutoff
A_noise_indices = find(A_sums<noise_cutoff);
% skip segment 1 and last because range overlaps extremes of sample. Could add code to handle these times.
A_noise_indices = A_noise_indices(2:end-1);

numevents = round(numel(A_noise_indices)* param.dS);
xempty = zeros(numevents * param.Fs,1);
noise_starts = zeros(numevents,1);
noise_stops = zeros(numevents,1);
dT2=round(param.dT*param.Fs);  % exactly as in MultiTaperFTest.m, line 33
dS2=round(param.dS*param.Fs);
for i = 1:length(A_noise_indices)
   segment = A_noise_indices(i);
   %start_sample=round((segment * ssf.dS - ssf.dS/2) * ssf.fs)+1;
   %stop_sample=round((segment * ssf.dS + ssf.dS/2) * ssf.fs);
   start_sample=(segment-1)*dS2+1;  % equivalent to MultiTaperFTest.m, lines 53 & 60
   stop_sample=start_sample+dT2;
   sample_noise = xsong(start_sample:stop_sample);
   start_in_noise = (i-1) * length(sample_noise) + 1;
   stop_in_noise = i *length(sample_noise);
   noise_starts(i) = start_in_noise;
   noise_stops(i) = stop_in_noise;
   xempty(start_in_noise:stop_in_noise) = sample_noise;
end
% noise_end = find(noise >0,1,'last');
% noise = noise(1:noise_end);

%get A_power from noise
low_freq_index = find(ssf.f>low_freq_cutoff,1,'first');
high_freq_index = find(ssf.f<high_freq_cutoff,1,'last');

A_noise_power = sum(abs(ssf.A(low_freq_index:high_freq_index,A_noise_indices)));

noise.d = xempty;
noise.sigma = std(xempty);
noise.starts = noise_starts;
noise.stops = noise_stops;
noise.A_indices = A_noise_indices;
noise.A_noise_power = A_noise_power;
