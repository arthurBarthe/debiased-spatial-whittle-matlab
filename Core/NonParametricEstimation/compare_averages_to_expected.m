function [p_samples, expected, averaged, cov_mat] = ...
                compare_averages_to_expected(model, sample, operator, ...
                nb_avg, results_folder, format_figs)
            %Runs a test on the computation of the expected
            %periodogram by coputing the periodogram for nb_avg independent
            %samples and averaging them. This is then compared to the
            %expectation of the periodogram. This method also provides with
            %the covariance matrix of the computed periodograms.
            close all
            switch nargin
                case 4
                    save_figs = false;
                case 5
                    save_figs = true;
                    format_figs = '.fig';
                otherwise
                    save_figs = true;
            end
            disp('Running test...');
            %We start by computing the expected periodogram
            disp('Computing the expected periodogram');
            P = TaperedPeriodogram(Periodogram(), Taper(@hanning, 'h'));
            P = Periodogram();
            expected = P.compute_expectation(DifferencedModel(model), DifferencedSample(sample));
            expected = expected(:);
            expected = expected';
            %We average periodogram from indepedent samples. Each
            %periodogram will be stored as a row vector in a matrix.
            disp('Running simulations...');
            N = sample.grid.N; M = sample.grid.M;
            %TODO change to account for the operator
            p_samples = zeros(nb_avg, sample.grid.get_nb_points());
            p_samples = zeros(nb_avg, 31*31);
            h = waitbar(0,'Starting computations...');
            for i= 1 : nb_avg
                waitbar(i/nb_avg,h, 'Running...');
                valued_sample = sample.simulate(model);
                valued_sample = operator.apply(valued_sample);
                p = P.compute(valued_sample);
                p_samples(i,:) = p(:)';
            end
            %We transform the data using the CDF of the exponential
            %distribution. We expect the transformed data to be
            %approximately following a uniform distribution over the [O,1]
            %interval.
            %TODO change to adapt to grid AND operator
            for k = 1 : 31*31
                p_samples(:,k) = 1 - exp(-1./expected(k) .* p_samples(:,k));
            end
            close(h);
            averaged = mean(p_samples, 1);
            %TODO change to adapt to operator
            averaged = reshape(averaged, N-1, M-1);
            expected = reshape(expected, N-1, M-1);
            %Compute the covariance matrix of the periodogram, and then the
            %correlation. 
            cov_mat = cov(p_samples);
            corr_mat = cov_mat ./ sqrt((diag(cov_mat)*diag(cov_mat)'));
            %Plot the average matrix
            h(1) = figure;
            imagesc(averaged);
            colorbar
            %Plot the histograms for 9 samples
            h(2) = figure;
            for i = 1 : 3
                for j = 1 : 3
                    subplot(330 + (i-1)*3 + j);
                    histogram(p_samples((i-1)*3+j,:), 'binwidth', 0.1);
                end
            end
            if save_figs
                for i=1:4
                    saveas(h(i), [results_folder '/' sample.getName() ...
                        'fig' num2str(i) format_figs]);
                end
            end
end