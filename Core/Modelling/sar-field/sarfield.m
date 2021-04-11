function Y=sarfield(n,ksq)
%n is one side of a 2d swaure plot
%ksq is the parameter of the SARfield
% this function makes a SARfield
% details in Wiens, Nychka, and Kleiber, Environmetrics 2020, vol 31

B=Bmatrix(n,ksq);

Z=inv(B);

eps1=randn(n^2,1);

Y1=Z*eps1;

Y=reshape(Y1,[n,n]);
