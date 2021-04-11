function varargout=similargrid(grid1,sqsize,plotit)
% [grid2,spit2,spit1]=SIMILARGRID(grid1,sqsize,plotit)
%
% For a grid (ones/zeros) and a smaller target size finds a similar subgrid. 
%
% INPUT:
%
% grid1     An MxN matrix with a grid (ones/zeroes) 
% sqsize    m specifiying the square size of the mxm subgrid
% plotit    0 nutting 'appens
%           1 keep graphical tabs on how it's working while working
%           2 show the best solution at the very end only
%
% OUTPUT:
%
% grid2     The "best" subgrid, "matching" in the following sense:
% spit2     The sparsity of the returned grid
% spit1     The sparsity of the input grid
%
% Last modified by fjsimons-at-alum.mit.edu, 05/19/2020

% Some simple defaults
defval('grid1',(peaks(512)+2*randn(512,512))>1)
defval('sqsize',64)
defval('plotit',1)

% The skip, via the overlap percentage of the subgrid, which controls the
% number of possibilities that are being tried (more is more!)
% It is important to play with this parameter
operc=98;

% Calculate the sparsity of the grid
spit1=sum(grid1(:))/prod(size(grid1))*100;

% Make a picture of the first grid
if plotit
  plotthat(1,grid1,spit1)
end

% Find out how many possibile subgrids with this size/overlap
[nwy,nwx]=blocktile(grid1,sqsize,operc);
ndim=nwy*nwx;
% Prepare for the sparsity analysis
spit2=nan(ndim,1);
% For all tested subgrids
for index=1:ndim
  grid2=blocktile(grid1,sqsize,operc,index);

  % Calculate the sparsity of the grid
  spit2(index)=sum(grid2(:))/sqsize^2*100;

  % Make a picture of the second grids
  if plotit==1
    plotthat(2,grid2,spit2(index),index,ndim)
    pause
  end
end

% Now you have a lot of sparsities, find the best one
[a,index]=min(abs(spit2-spit1));
% Rerun that square and its sparsity
grid2=blocktile(grid1,sqsize,operc,index);
spit2=sum(grid2(:))/prod(size(grid2))*100;

% Should go fish out from BLOCKTILE where to begin and start
% But this doesn't really matter here if you just want the grid

% Make a picture of the second grids
if plotit==2
  plotthat(2,grid2,spit2,index,ndim)
end

% Optional output
varns={grid2,spit2,spit1};
varargout=varns(1:nargout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotthat(ahi,gridi,spiti,indi,inda)
ah=subplot(1,2,ahi);
image(gridi);
axis image
mi=size(gridi,1);
ni=size(gridi,2);

try
  t=title(sprintf('%ix%i subgrid %i/%i ; %8.4f%% sparse',...
		mi,ni,indi,inda,spiti));
catch
  t=title(sprintf('%ix%i master grid ; %8.4f%% sparse',...
		mi,ni,spiti));
end

% Cosmetics
longticks(ah)
set(t,'FontSize',16)
movev(t,-mi/32)
set(ah,'XTick',[1 ni],'YTick',[1 mi])
