function [data, data_te, shift, scale] = standardize(data, data_te, shift, scale)
% [DATA, SHIFT, SCALE] = STANDARDIZE(DATA) Standardizes the data (makes it
%   zero-mean, unit standard deviation) given in DATA. Data vectors are rows of
%   DATA (columns are variables).
%
%   [DATA, SHIFT, SCALE] = STANDARDIZE(DATA, SHIFT, SCALE) If shift, and scale
%   are already given, then these are applied to the data. 
%

if nargin==2
    % then compute the shift/scale vectors
    shift = mean(data,1);
    scale = std(data,1);
end

% apply the transformation
for f=1:size(data,2)
    if scale(f)<eps
       data(:,f) = (data(:,f)-shift(f));
    else
        data(:,f) = (data(:,f)-shift(f))/scale(f);
    end
end


% apply the transformation
for f=1:size(data_te,2)
    if scale(f)<eps
       data_te(:,f) = (data_te(:,f)-shift(f));
    else
        data_te(:,f) = (data_te(:,f)-shift(f))/scale(f);
    end
end
