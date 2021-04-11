function [ tenlogten_sample ] = sample_10log10( sample )
%This functions returns 10*log10(sample)
values = sample.get_values();
new_values = 10*log10(values);
tenlogten_sample = sample.new();
tenlogten_sample.set_values(new_values);
end

