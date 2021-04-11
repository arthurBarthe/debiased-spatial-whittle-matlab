%Script corresponding to Section 5.2 of the paper
%We study the performance of our estimator in the situation of a general
%boundary.
%For this we consider an isotropic exponential covariance function with
%amplitude parameter \sigma = 1 and range parameter \rho = 5. 
%We consider two regular grids. One which is circular, and another one
%which is the largest rectangular grid in that circle.
close all; clear all;

%Script parameters
SAVE_SIMULATIONS = true;


%Define the model
model_family = MaternModelFamily([0 1 0]);
model_family.set_fixed_parameter_values(0.5);
model = Model([1 5], model_family);

%Define a larger grid
grid = RectangularGrid([97, 97]);

%Define the rectangular grid
rect_grid = grid.filter_leq([49 49], 32, 'max');


%Define the circular grid
circ_grid = grid.filter_leq([49 49], 48, 'euclidean');

%Plot the grids
rect_grid.plot()
circ_grid.plot()

%We define the periodograms
P = Periodogram();
tapered_P = TaperedPeriodogram(P, Taper(@hanning, 'hanning'));
Fuentes_P = FuentesPeriodogram();

%Estimator factories

%Define an initial guess. The second parameter, which corresponds to the
%range, will be initizalized as the grid size divided by two.
initEstimatorFactory = ConstantEstimatorFactory();
initEstimatorFactory.constants = 2;
initEstimatorFactory.range_param_id = 2;

lkhd_estimator_factory_1 = LikelihoodEstimatorFactory(initEstimatorFactory);

whittle_type_factory = WhittleTypeEstimatorFactory();
whittle_type_factory.fit_zero_frequency = true;
whittle_type_factory.periodogram = P;

% whittle_t_type_factory = WhittleTypeEstimatorFactory();
% whittle_t_type_factory.fit_zero_frequency = true;
% whittle_t_type_factory.periodogram = tapered_P;

fuentes_factory = FuentesWhittleFactory(1);
debiased_factory = DebiasedWhittleFactory();


whittle_type_factory.add_sub_factory('Fuentes', fuentes_factory);
whittle_type_factory.add_sub_factory('Debiased', debiased_factory);
% whittle_t_type_factory.add_sub_factory('Tapered Whittle', whittle_factory);
% whittle_t_type_factory.add_sub_factory('Tapered debiased', ...
%     debiased_factory);

lkhd_estimator_factory_1.add_sub_factory('Fuentes', whittle_type_factory)
lkhd_estimator_factory_2 = LikelihoodEstimatorFactory(lkhd_estimator_factory_1, 'Fuentes');
lkhd_estimator_factory_2.add_sub_factory('Debiased', whittle_type_factory)


%We define our estimators
dW = lkhd_estimator_factory_2.get_estimator(circ_grid, 'Debiased');
fuentes_W = lkhd_estimator_factory_1.get_estimator(circ_grid, 'Fuentes');

%Random numbers generator
r = RandomGenerator(randi(1000));

%number of simulations
nb_samples = 100;

%arrays used to store estimates
estimates_rect = zeros(nb_samples, 2, 2);
estimates_circ = zeros(nb_samples, 2, 2);
cpu_rect = zeros(nb_samples, 2);
cpu_circ = zeros(nb_samples, 2);
tic
for i_sample = 1 : nb_samples
    disp(['Sample nb ' num2str(i_sample)]);
    %simulation of a sample
    sample_i = grid.simulate(model, r);
    %Subsampling over these two grids
    sample_i_rect = sample_i.subsample(rect_grid);
    sample_i_circ = sample_i.subsample(circ_grid);
    
    %estimation using our method
%     estimate_rect = Model(model_family);
    estimate_circ = Model(model_family);
%     tic
%     dW.estimate(sample_i_rect, estimate_rect);
%     cpu_rect(i_sample, 1) = toc;
    tic
    dW.estimate(sample_i_circ, estimate_circ);
    cpu_circ(i_sample, 1) = toc;
    disp(cpu_circ(i_sample, 1));
    %estimation using the Fuentes method (uniform rescaling of the
    %periodogram + standard Whittle likelihood)
    %estimate_rect_Fuentes = Model(model_family);
    estimate_circ_Fuentes = Model(model_family);
    tic
    fuentes_W.estimate(sample_i_circ, estimate_circ_Fuentes);
    cpu_circ(i_sample, 2) = toc;
%     tic
%     fuentes_W.estimate(sample_i_rect, estimate_rect_Fuentes);
%     cpu_rect(i_sample, 2) = toc;
    %Display the estimated parameters
%     disp(estimate_rect.getParameters());
    disp(estimate_circ.getParameters());
%     disp(estimate_rect_Fuentes.getParameters());
    disp(estimate_circ_Fuentes.getParameters());
    %Store the estimated parameters in the corresponding arrays.
%     estimates_rect(i_sample, :, 1) = estimate_rect.getParameters();
    estimates_circ(i_sample, :, 1) = estimate_circ.getParameters();
%     estimates_rect(i_sample, :, 2) = estimate_rect_Fuentes.getParameters();
    estimates_circ(i_sample, :, 2) = estimate_circ_Fuentes.getParameters();
    %Save the data for future use by Guinnes method
    values = sample_i.get_values();
    z = reshape(values, sample_i.grid.N, sample_i.grid.M);
    if SAVE_SIMULATIONS
        save(['simdataArthur/data_' num2str(i_sample)], 'z');
    end
end
inds_rect = rect_grid.mask;
inds_circ = circ_grid.mask;
save('simdataArthur/inds_rect', 'inds_rect', 'inds_circ');

if SAVE_SIMULATIONS
    save(['incompleteSims' num2str(fix(clock))]);
    disp('Simulation data saved.');
end