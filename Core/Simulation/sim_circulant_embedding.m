function [ Hx1, Hx2, N ] = sim_circulant_embedding( N, M, N2, M2, cov )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
try
    [Hx1, Hx2] = stationary_Gaussian_process(N2,M2, cov);
    Hx1 = Hx1(1:N,1:M);
    Hx2 = Hx2(1:N,1:M);
catch error
    if N2>=1024
        disp(['Circulant embedding did not work: ' error.message])
        disp(['This error usually might occur if ' ...
            'You have not completely defined the parameter vector.']);
        return
    else
        [Hx1, Hx2] = sim_circulant_embedding(N,M,2*N2, 2*M2, cov);
    end
end
M = N2;
end

