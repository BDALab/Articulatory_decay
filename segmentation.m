function Y = segmentation(x, wind, winover, padd)

% Y = segmentation(x, wind, winover, padd)
% 
% This function segment the input column vector to segments. Segments are
% stored in MxN matrix where M is the length of segments and N number of
% segments.
% 
% x         - input column vector
% wind      - length of window in samples or window samples
% winover   - window overlapp in samples
% padd      - if set to 1, the last segment will be padded by zeros if
%             necessary (default: 0)
% Y         - output matrix with segments

%% Paths and variables
if((nargin < 4) || isempty(padd))
    padd = 0;
end

%% Check the input variables
if(length(wind) > 1)
    winlen = length(wind);
else
    winlen = wind;
end

if(winlen > length(x))
    warning(['Window is longer than sequence. Sequence will by padded ' ...
        'by zeros']);
    padd = 1;
end

if(winover >= winlen)
    error(['Cannot segment input vector. Window overlap is greater or' ...
        ' equal to the window length.']);
end

%% If necessary padd the signal by zeros
cols = (length(x) - winover)/(winlen-winover);

if(padd)
    if(cols - fix(cols) > 0)
        x = [x; zeros(winlen,1)];
        cols = ceil(cols);
    end
else
    cols = fix(cols);
end

%% Segment the sequence
Y = zeros(winlen,cols);

step = (0:(winlen-winover):(cols-1)*(winlen-winover));
seq = (1:winlen).';

Y = x(seq(:,ones(1,cols)) + step(ones(1,winlen),:));

%% Weight by window
if(length(wind) > 1)
    Y = Y.*wind(:,ones(1,cols));
end