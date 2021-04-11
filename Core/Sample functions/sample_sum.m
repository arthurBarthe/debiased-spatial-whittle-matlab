function [ sum_sample ] = sample_sum( sample )
%Returns the point-wise absolute value of the sample
sum_sample = sum(sample.get_values());
end

