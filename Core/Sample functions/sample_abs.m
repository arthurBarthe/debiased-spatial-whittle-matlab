function [ abs_sample ] = sample_abs( sample )
%Returns the point-wise absolute value of the sample
abs_sample = sample.new();
abs_sample.set_values(abs(sample.get_values()));
end




