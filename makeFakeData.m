
rng(0);
N = 27;
K = 7;

theta = randn(K,1);

sel = nan(N,K);
rating = nan(N,K);
logistic = @(x) round(6./(1+exp(-x)) + 1);
for ii = 1:N
    noise = randn(7,1)*0.5;
    thetaPrime = theta + noise;
    s = thetaPrime' > 0;
    sel(ii,:) = double(s);
    rating(ii,s) = logistic(thetaPrime(s));

end

N_rate = sum(sel,'all');
[k_rate,i_rate] = meshgrid(1:K,1:N);
i_rate = i_rate(sel==1);
k_rate = k_rate(sel==1);
rating = rating(sel==1);

DataStruct = struct();
DataStruct.N = N;
DataStruct.K = K;
DataStruct.sel = sel;
DataStruct.N_rate = N_rate;
DataStruct.i_rate = i_rate;
DataStruct.k_rate = k_rate;
DataStruct.rating = rating;

DataStruct = jsonencode(DataStruct,...
    'PrettyPrint',true,'ConvertInfAndNaN',false);
fid = fopen('data.json','w');
fprintf(fid,'%s',DataStruct);
fclose(fid);
