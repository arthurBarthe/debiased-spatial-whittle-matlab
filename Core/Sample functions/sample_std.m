function [ std_sample ] = sample_std( sample )
%Returns the point-wise absolute value of the sample
std_sample = std(sample.get_values());
end

