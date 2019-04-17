function SEM = standard_error(mu,observations)
%SEM = standard_error(mu,observations)
%   SEM Standard Error of the mean. This implementation uses the estimated
%   error variance suitable for comparing bootstrapped estimates to fit
%   model parameters. 
%   ref => http://www.stat.rutgers.edu/home/mxie/rcpapers/bootstrap.pdf
%   JG 2018
    N = size(observations,1);
    SEM = sqrt((1/N)*sum((mu-observations).^2));
end