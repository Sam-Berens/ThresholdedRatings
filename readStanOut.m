function [thetaHat,stanOut] = readStanOut()
dirList = dir('output*.csv');
for iFile = 1:size(dirList,1)
    lines = readlines(dirList(iFile).name);
    s = false(size(lines,1),1);
    for ii = 1:numel(s)
        if ~isempty(lines{ii})
            c0 = lines{ii}(1);
            s(ii) = ~strcmp(c0,'#');
        end
    end
    lines = lines(s);
    tempFn = [tempname(pwd),'.csv'];
    writelines(lines,tempFn);
    T = readtable(tempFn);
    delete(tempFn);
    chain = ones(size(T,1),1).*iFile;
    T = [table(chain),T]; %#ok<AGROW>
    if iFile == 1
        stanOut = T;
    else
        stanOut = [stanOut;T]; %#ok<AGROW>
    end
end

%%
thetaHat = [...
    stanOut.theta_1,...
    stanOut.theta_2,...
    stanOut.theta_3,...
    stanOut.theta_4,...
    stanOut.theta_5,...
    stanOut.theta_6,...
    stanOut.theta_7];

%%
rng(1);
theta = randn(7,1);
figure;
scatter(theta,mean(thetaHat)');

return