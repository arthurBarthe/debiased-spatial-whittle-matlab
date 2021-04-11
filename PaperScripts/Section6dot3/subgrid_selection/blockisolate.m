function [bloke,i,j]=blockisolate(matrix,nmsize,indo)
% [bloke,i,j]=BLOCKISOLATE(matrix,[n m],indo)
%
% Isolates the 'indo'-th RECTANGULAR block matrix 
% of size nXm out of a 'matrix'
%
% EXAMPLE:
%
% mat=peaks(64);
% subplot(221) ; imagesc(blockisolate(mat,[32 32],1))
% subplot(222) ; imagesc(blockisolate(mat,[32 32],3))
% subplot(223) ; imagesc(blockisolate(mat,[32 32],2))
% subplot(224) ; imagesc(blockisolate(mat,[32 32],4))
%
% See also BLOCKTILE, BLOCKISOLATE2
%
% Written by fjsimons-at-mit.edu, 11/20/2015

[n,m]=deal(nmsize(1),nmsize(2));

if any(mod(size(matrix),nmsize))
  error('Matrix size not a multiple of n or m')
end

muln=size(matrix,1)/n;
mulm=size(matrix,2)/m;

% The "column" index in the blockmatrix
jindo=ceil(indo/muln);
iindo=indo-(jindo-1)*muln;

i=(iindo-1)*n+1:iindo*n;
j=(jindo-1)*m+1:jindo*m;

bloke=matrix(i,j);
