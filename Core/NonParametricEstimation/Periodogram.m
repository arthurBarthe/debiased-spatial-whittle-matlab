classdef Periodogram < Estimator
    %This class represents the periodogram in its classical form. 
    
    properties
    end
    
    methods
        function obj = Periodogram(name)
            switch nargin
                case 0
                    name = 'Periodogram';
            end
            obj@Estimator(name);
        end
        
        function P = compute(obj, sample)
            %This method computes the periodogram in its classical form;
            %Note that missing values are replaced with
            %zeroes.
            assert(isa(sample.grid, 'SubGrid'), ...
                ['The sample passed to the periodogram should be ' ...
                'a sample on a SubRectangularGrid.']);
            %Convert the sample to a full sample by replacing missing
            %values by zeros.
            %TODO(speed)
            sample = sample.missing_values_to_zero();
            delta = sample.grid.deltas_product() / ...
                sample.grid.shapes_product();
            delta = delta / (4 * pi^2);
            P = (sample_abs(sample_fft(sample))).^2 * delta ;
        end
        
        function expected_P = compute_expectation(obj, model, sample)
            if isa(sample, 'Sample')
                grid = sample.grid;
            elseif isa(sample, 'Grid')
                grid = sample;
            end
            [kernel1, kernel2] = obj.get_kernels(grid);
            Pbar = compute_expectation_from_kernels(obj, model, ...
                grid, kernel1, kernel2);
            frequency_grid = grid.grid.get_fourier_grid();
            expected_P = Sample(frequency_grid);
            expected_P = SampleOnFourierGrid(expected_P);
            expected_P.set_values(Pbar(:));
        end
        
        function expected_dP = compute_expected_derivative(...
                obj, model, sample, mat1, mat2)
                        if isa(sample, 'Sample')
                grid = sample.grid;
            elseif isa(sample, 'Grid')
                grid = sample;
                        end
            [kernel1, kernel2] = obj.get_kernels(grid);
            Pbar = compute_expectation_from_kernels(obj, model, ...
                grid, kernel1, kernel2,1, mat1, mat2);
            frequency_grid = grid.grid.get_fourier_grid();
            expected_dP = Sample(frequency_grid);
            expected_dP = SampleOnFourierGrid(expected_dP);
            expected_dP.set_values(Pbar(:));
        end
    end
        
    methods 
        function Pbar = compute_expectation_from_kernels(obj, model, ...
                grid, kernel1, kernel2, m, mat1, mat2)
            %Covariance matrix corresponding to the distances grid y
            use_input_matrices = false;
            rect_grid = grid.grid;
            switch nargin
                case 5
                    m = 1;
                case 8
                    use_input_matrices = true;
            end
            if use_input_matrices
                cov_mat_1 = mat1;
                cov_mat_2 = mat2;
            else
%                 cov_mat_1 = rect_grid.get_covariances_sample(model);
%                 cov_mat_1 = cov_mat_1.get_values_matrix();
                cov_mat_1 = model.covariances_on_positive_grid(rect_grid);
                cov_mat_2 = model.covariances_on_negative_grid(rect_grid);
            end
            [~, ~, n_dims] = size(cov_mat_1);
            N = rect_grid.N * m;
            M = rect_grid.M * m;
            Pbar = zeros(N,M,n_dims);
            for i_dim = 1 : 1
                cov_mat_1 = cov_mat_1 .* kernel1;
                cov_mat_2 = cov_mat_2 .* kernel2;
                %Calculations
                q1 = fft2(cov_mat_1, N, M);
                q2 = fft2(cov_mat_2, N, M);
                q2(:,2:end) = fliplr(q2(:,2:end));
                q3 = q1+q2;
                q4 = q3 - fft(cov_mat_1(:,1), N) * ones(1, M);
                sdf_i = 2*real(q4)-ones(N, 1)*(2 * real(fft(cov_mat_2(1,:), M))-cov_mat_2(1,1));
                sdf_i = 1/(4*pi^2) * rect_grid.deltas_product() * sdf_i;
                Pbar(:,:,i_dim) = fftshift(sdf_i);
            end
            Pbar = squeeze(Pbar);
        end
        
        function [kernel1, kernel2] = get_kernels(obj, grid)
            assert(isa(grid, 'SubGrid'));
            %TODO replace get_mask, which should become obsolete.
            modulation_sample = grid.get_mask_new();
            [kernel1, kernel2] = modulation_sample.get_kernels();
        end
    end
end