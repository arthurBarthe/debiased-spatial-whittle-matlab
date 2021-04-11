function [ exp_sample ] = sample_exp( sample )
%Returns the point-wise exponential value of the sample
exp_sample = sample.new();
exp_sample.set_values(exp(sample.get_values()));
end
