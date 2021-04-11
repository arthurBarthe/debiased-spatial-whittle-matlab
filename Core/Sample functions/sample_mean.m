function [ mean_sample ] = sample_mean( sample )
%Returns the mean of the sample
mean_sample = mean(sample.get_values());
end

