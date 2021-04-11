function [estimated_models, s] = fitMaternToTopoData(data_matrix, ...
    estimators, estimator_factory)
%Fits a Matern process to a real data sample from Venus' topography. The
%data is in the form of a matrix, representing the observations obtained on
%a regular and rectangular grid.
%Args
%data_matrix: double[N][M] The data.
%estimators: ParameterEstimator list of estimators to be used on the data.

%We first start by putting the data in the form of a sample.
%We create a rectangular grid
[N, M] = size(data_matrix);
g_rect = RectangularGrid([N, M]);
%We define a sample on that grid (all points observed here)
s = Sample(g_rect);
s = SampleOnRectangularGrid(s);
%We now define the valued sample and sets is data using the provided data.
%We remove the mean and make the data have unit variance.
flat_values = data_matrix(:);
s.set_values(flat_values);

%We apply a differencing operator and then normalize the data
diff_op = DifferencingOperator();
standardize_op = StandardizeOperator();

%We rescale the data to give it variance one
final_op =  standardize_op;
% s = final_op.apply(s);

% s = sample_to_standard_normal(s);
s = s / sample_std(s);

s_complete = s.missing_values_to_zero();
s_complete.plot();

%We now define the model whose parameters we will estimate
model_family = MaternModelFamily([0 0 0]);
% model_family.set_fixed_parameter_values([1]);
estimated_models = cell(length(estimators), 1);

for i_estimator = 1 : length(estimators)
    estimated_model_i = Model(model_family);
    current_estimator = estimator_factory.get_estimator(s.grid, ...
        estimators{i_estimator});
    current_estimator.estimate(s, estimated_model_i);
    estimated_models{i_estimator} = estimated_model_i;
end
end

