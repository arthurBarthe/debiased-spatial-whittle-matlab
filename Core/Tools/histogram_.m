function [h] = histogram_( varargin )
hh = histogram(varargin{1:end-1});
group = varargin{end};
group.add(hh);
if nargout > 0
    h = hh;
end
end

