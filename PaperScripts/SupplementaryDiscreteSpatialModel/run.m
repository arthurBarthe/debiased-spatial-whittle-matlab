%In this script we compare the de-biased Whittle likelihood to the
%classical Whittle likelihood for estimation of the Matérn process with a
%fixed nu parameter, with nu taking values 1/2, 3/2, and 5/2.
clear all; close all;
nu_values = 0.5;
theta_x = 3;
n_min = 2;
n_max = 7;
%n_min = 4;
%n_max = 9;
grid_sizes = 4.^(n_min:n_max);
%grid_sizes = 2.^(n_min:n_max);
delta = 1;
nb_simulations = 500;
generator = RandomGenerator(1712);
model_family = DiscreteModel1([1 0]);
model_family.set_fixed_parameter_values([1. ]);

%We define the periodogram and a tapered periodogram
P = Periodogram();
taper_ = Taper(@hann, 'Hann taper');
tapered_P = TaperedPeriodogram(P, taper_);

%Estimator factories
initEstimatorFactory = ConstantEstimatorFactory();
initEstimatorFactory.constants = [0.2];
%initEstimatorFactory.range_param_id = 1;

lkhd_estimator_factory = LikelihoodEstimatorFactory(initEstimatorFactory);

whittle_type_factory = WhittleTypeEstimatorFactory();
whittle_type_factory.fit_zero_frequency = true;
whittle_type_factory.periodogram = P;

whittle_t_type_factory = WhittleTypeEstimatorFactory();
whittle_t_type_factory.fit_zero_frequency = true;
whittle_t_type_factory.periodogram = tapered_P;

whittle_factory = WhittleFactory();
whittle_factory.sum_truncation = 1;
debiased_factory = DebiasedWhittleFactory();

whittle_type_factory.add_sub_factory('Whittle', whittle_factory);
whittle_type_factory.add_sub_factory('Debiased', debiased_factory);
whittle_t_type_factory.add_sub_factory('Tapered Whittle', whittle_factory);
whittle_t_type_factory.add_sub_factory('Tapered debiased', ...
    debiased_factory);

lkhd_estimator_factory.add_sub_factory('Whittle', whittle_type_factory)
lkhd_estimator_factory.add_sub_factory('Debiased', whittle_type_factory)
lkhd_estimator_factory.add_sub_factory('Tapered Whittle', ...
    whittle_t_type_factory);
lkhd_estimator_factory.add_sub_factory('Tapered debiased', ...
    whittle_t_type_factory);

%We list the estimators to be used
estimators_list = {'Debiased', 'Tapered debiased', ...
    'Whittle', 'Tapered Whittle'};

%savearray
results = zeros(length(nu_values), length(grid_sizes), ...
    length(estimators_list), nb_simulations);

for i=1:length(nu_values)
    disp(['Running simulations for nu = ' num2str(nu_values(i))]);
    %Model with fixed parameters
    model = Model([theta_x] , model_family);
    for j = 1 : length(grid_sizes)
        grid_size = grid_sizes(j);
        disp(['Running simulations for size = ' num2str(grid_size)]);
        %Rectangular grid with spacing delta in both directions.
        g_rect = RectangularGrid([16 grid_size], [delta delta]);
        estimators = cellfun(@(x) lkhd_estimator_factory.get_estimator(...
            g_rect, x), estimators_list, 'UniformOutput', false);
        for i_sim = 1 : nb_simulations
            disp(['Running simulations nb ' num2str(i_sim)]);
            %Simulate a random field
            sample = g_rect.simulate(model, generator);
            for k = 1 : length(estimators_list)
                estimator_name = estimators_list(k);
                disp(['Running estimator: ' estimator_name{1}]);
                estimator = estimators{k};
                estimated_model = Model(model_family);
                estimator.estimate(sample, estimated_model);
                est_params = estimated_model.getParameters();
                results(i, j, k, i_sim) = est_params(1);
                disp(estimated_model.getParameters());
            end
        end
        % save(date());
    end
end

%Post-processing of simulations
mean_estimates = mean(results, 4);
biases = mean_estimates - theta_x;
variances = var(results,[], 4);
rmse = sqrt(biases.^2 + variances);

%Plots
nu_id = 1;
rmse_plot = transpose(squeeze(rmse(nu_id, :,:)));
biases_plot =  abs(transpose(squeeze(biases(nu_id, :,:))));
stds_plot =  sqrt(transpose(squeeze(variances(nu_id, :,:))));

figure
subplot(131);
plot(log(2.^(n_min:n_max)), 10*log10(biases_plot), '-*');
hold on
%line 1/sqrt(data size)
line1 = sqrt(10)./sqrt(2.^(2*(n_min:0.1:n_max)));
plot(log(2.^(n_min:0.1:n_max)), 10*log10(line1), '--');
axis('tight');
legend({estimators_list{:}, '$\frac{\cdot}{\sqrt(|n|)}$'}, 'Interpreter', 'latex');
xlabel('side length (number of points)');
ylabel('dB');
title('Bias');

subplot(132);
plot(log(2.^(n_min:n_max)), 10*log10(stds_plot), '-*');
hold on
%line 1/sqrt(data size)
line1 = sqrt(10)./sqrt(2.^(2*(n_min:0.1:n_max)));
plot(log(2.^(n_min:0.1:n_max)), 10*log10(line1), '--');
axis('tight');
% legend({estimators_list{:}, '$\frac{\cdot}{\sqrt(|n|)}$'}, 'Interpreter', 'latex');
xlabel('side length (number of points)');
% ylabel('dB');
title('Standard Deviation');

subplot(133);
plot(log(2.^(n_min:n_max)), 10*log10(rmse_plot), '-*');
hold on
%line 1/sqrt(data size)
line1 = sqrt(10)./sqrt(2.^(2*(n_min:0.1:n_max)));
plot(log(2.^(n_min:0.1:n_max)), 10*log10(line1), '--');
axis('tight');
% legend({estimators_list{:}, '$\frac{\cdot}{\sqrt(|n|)}$'}, 'Interpreter', 'latex');
xlabel('side length (number of points)');
% ylabel('dB');
title('Root Mean Square Error');


createfigure4(log(2.^(n_min:n_max)), 10*log10(biases_plot), log(2.^(n_min:0.1:n_max)), 10*log10(line1), ...
10*log10(stds_plot), 10*log10(rmse_plot))