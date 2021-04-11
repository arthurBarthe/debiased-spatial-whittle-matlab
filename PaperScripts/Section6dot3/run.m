% Script parameters
addpath('subgrid_selection');
load GEBCO2014_Arthur
grid_sizes = [256] ;
delta = 1;
generator = RandomGenerator(1712);
n_simulations = 500;
% Change the length scale here. Paper values: 20, 50
length_scale = 20;


model_family = MaternModelFamily([1 1 0]);
model_family.set_fixed_parameter_values([1 0.5]);
model_family2 = MaternModelFamily([1 1 0]);
model_family2.set_fixed_parameter_values([1 1.5]);
model = Model(20, model_family);

p = Periodogram();
taper = Taper(@(x) hanning(x), 'hanning');
p_tapered = TaperedPeriodogram(p, taper);


%Estimator factories
initEstimatorFactory = ConstantEstimatorFactory();
%back to 100
initEstimatorFactory.constants = 100;
initEstimatorFactory.range_param_id = 1;

lkhd_estimator_factory = LikelihoodEstimatorFactory(initEstimatorFactory);

whittle_type_factory = WhittleTypeEstimatorFactory();
whittle_type_factory.fit_zero_frequency = true;
whittle_type_factory.periodogram = p;

whittle_type_factory2 = WhittleTypeEstimatorFactory();
whittle_type_factory2.fit_zero_frequency = true;
whittle_type_factory2.periodogram = p_tapered;

debiased_factory = DebiasedWhittleFactory();
fuentes_factory = FuentesWhittleFactory();

whittle_type_factory.add_sub_factory('Debiased', debiased_factory);
whittle_type_factory2.add_sub_factory('Fuentes', fuentes_factory);

lkhd_estimator_factory.add_sub_factory('Debiased', whittle_type_factory);
lkhd_estimator_factory.add_sub_factory('Fuentes', whittle_type_factory2);


zp = zp > 0 & zp < 4000;
% zp = zp > 0;
estimates = zeros(n_simulations, length(grid_sizes));
estimates_f = zeros(n_simulations, length(grid_sizes));
nb_points = zeros(n_simulations, length(grid_sizes));

lkhs = zeros(n_simulations, length(grid_sizes));
lkhs2 = zeros(n_simulations, length(grid_sizes));

lkhs_f = zeros(n_simulations, length(grid_sizes));
lkhs2_f = zeros(n_simulations, length(grid_sizes));


% Runs
for i_grid_size = 1 : length(grid_sizes)
    grid_size = grid_sizes(i_grid_size);
    % Grid
    g_rect = RectangularGrid([grid_size grid_size], [delta delta]);
    % Select a mask using Frederik's code to ensure that the selected
    % subgrid has similar sparsity properties to those of the whole grid
    [zp_cropped, ~, ~] = similargrid(zp, grid_size, 0);
    
    for i_run = 1 : n_simulations
        disp((i_grid_size - 1) * n_simulations + i_run);
        grid_i = SubRectangularGrid(g_rect);
        nb = sum(sum(zp_cropped));
        nb_points(i_run, i_grid_size) = nb;

        grid_i.set_mask(reshape(zp_cropped, grid_size^2, 1));

        % Debiased Whittle estimator
        estimator = lkhd_estimator_factory.get_estimator(grid_i, 'Debiased');
        % Fuentes Whittle estimator
        estimator_f = lkhd_estimator_factory.get_estimator(grid_i, 'Fuentes');
        
        % Generate sample
        sample = grid_i.simulate(model, generator);
        %Debiased estimation
        estimated_model = Model(model_family);
        lkhs(i_run, i_grid_size) = estimator.estimate(sample, estimated_model);
        disp(estimated_model.getParameters());
        estimates(i_run, i_grid_size) = estimated_model.getParameters();
        %
        estimated_model2 = Model(model_family2);
        lkhs2(i_run, i_grid_size) = estimator.estimate(sample, estimated_model2);
        %Fuentes estimation
        estimated_model = Model(model_family);
        lkhs_f(i_run, i_grid_size) = estimator_f.estimate(sample, estimated_model);
        disp(estimated_model.getParameters());
        estimates_f(i_run, i_grid_size) = estimated_model.getParameters();
        estimated_model2 = Model(model_family2);
        lkhs2_f(i_run, i_grid_size) = estimator.estimate(sample, estimated_model2);
        % Saving
        if mod(i_run, 100) == 0
            save('estimates_frederik_grid');
        end
    end
end

