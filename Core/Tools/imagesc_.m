function [ h ] = imagesc_(varargin)
%Re-implements imagesc, allowing for graph grouping.
switch (nargin)
    case 0
        hh = imagesc(varargin);
    case 1
        hh = imagesc(varargin);
    case 3
        hh = imagesc();
    otherwise
        group_graphs = [];
        % Determine if last input is clim
        if isequal(size(varargin{end}),[1 2])
            str = false(length(varargin),1);
            for n=1:length(varargin)
                str(n) = ischar(varargin{n});
            end
            str = find(str);
            if isempty(str) || (rem(length(varargin)-min(str),2)==0)
                clim = varargin{end};
                varargin(end) = []; % Remove last cell
            else
                clim = [];
            end
        else
            group_graphs = varargin{end};
        end
        if ~isempty(group_graphs)
            hh = image(varargin{1:end-1},'CDataMapping','scaled');
            group_graphs.add(hh);
        else
            hh = image(varargin{:},'CDataMapping','scaled');
        end
end
if nargout > 0
    h = hh;
end
end

