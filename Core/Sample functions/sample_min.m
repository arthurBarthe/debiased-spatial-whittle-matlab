function [ min_sample ] = sample_min( sample )
%Returns the point-wise absolute value of the sample
min_sample = min(sample.get_values());
end
