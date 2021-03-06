function fZ = alignpulses2model(Z,M)
% [poolavail,isOpen] = check_open_pool;
[n_samples,total_length] = size(Z);

for n = 1:n_samples;
    C = xcorr(M,Z(n,:),'unbiased');
    [~,tpeak] = max(C);
    tpeak = tpeak - total_length;
    Z(n,:) = circshift(Z(n,:),[1 tpeak]);
%    a = mean(M.*Z(n,:))/mean(Z(n,:).^2);
%    Z(n,:) = a*Z(n,:);
end


%rescale data to mean
%equivalent to following, on whole array
%a = mean(M.*Z(n,:))/mean(Z(n,:).^2);
%Z(n,:) = a*Z(n,:);

% Ma = repmat(M,n_samples,1);
% num = mean(Ma'.*Z');
% den = mean(Z'.^2);
% a = num./den;
% ar = repmat(a',1,total_length);
% Z = ar.* Z;
%M = mean(Z);
% 
% scale = sqrt(mean(M.^2));
% fM = M/scale;
% fZ = Z/scale;

fZ = Z;
% check_close_pool(poolavail,isOpen);
