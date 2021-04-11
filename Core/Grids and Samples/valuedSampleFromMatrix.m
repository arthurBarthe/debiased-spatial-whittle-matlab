function [ sample ] = valuedSampleFromMatrix( mat )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
[M,N] = size(mat);
grid = RectangularGrid(N,M);
mat = mat';
sample = ValuedSample(Sample(grid), mat(:));
end

