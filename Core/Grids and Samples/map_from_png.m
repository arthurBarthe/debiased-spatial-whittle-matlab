function [ map ] = map_from_png( filename,  N )
%This function returns a map based on the png file passed as an argument.
data = imread(filename);
data = data>0;
[N0,M0] = size(data);
M = round(N/N0*M0);
map = data(round(linspace(1,N0, N)),... 
    round(linspace(1,M0,M)));
map=double(map);
end