function [ log_sample ] = sample_log( sample )
%Returns the point-wise absolute value of the sample
log_sample = sample.new();
log_sample.set_values(log(sample.get_values()));
end