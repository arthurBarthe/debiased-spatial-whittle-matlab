function [ fft_sample ] = sample_fft( sample )
%Returns the FFT sample of a sample defined on a rectangular grid.
grid = sample.grid;
assert(isa(grid, 'RectangularGrid'));
fft_grid = FourierGrid(grid);
spatial_values = grid.values_to_matrix_form(sample.get_values());
fft_sample = Sample(fft_grid);
frequency_values = fft2(spatial_values);
frequency_values = fftshift(frequency_values);
frequency_values = frequency_values(:);
fft_sample.set_values(frequency_values);
end

