function [ inv_sample ] = sample_inv( sample )
%Returns the point-wise absolute value of the sample
inv_sample = sample.new();
inv_sample.set_values(1./(sample.get_values()));
end