function [ to_standard_normal_sample ] = sample_to_standard_normal( sample )
%This functions transforms the sample to make it Gaussian
y = sample.get_values();
[f,x] = ecdf(y);
y2 = zeros(length(y), 1);
for i = 1 : length(y2)
    indexes = find(x <= y(i));
    y2(i) = f(indexes(end));
end
new_values = norminv(y2);
new_values(new_values == inf) = max(new_values(new_values < inf));
to_standard_normal_sample = sample.new();
to_standard_normal_sample.set_values(new_values(:));
end

