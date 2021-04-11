clear all; close all;
%Script to fit the real data from Venus
load 'Topodata/NewFrederikData/Frederik51'
topodata1 = topodata;
load 'Topodata/NewFrederikData/Frederik52'
topodata2 = topodata;
load 'Topodata/NewFrederikData/Frederik53'
topodata3 = topodata;
load 'Topodata/NewFrederikData/Frederik54'
topodata4 = topodata;
%We define the periodogram and a tapered periodogram
P = Periodogram();
taper_ = Taper(@hann, 'Hann taper');
tapered_P = TaperedPeriodogram(P, taper_);

initEstimatorFactory = ConstantEstimatorFactory();
initEstimatorFactory.constants = [1 1.5 0];
initEstimatorFactory.range_param_id = 3;

lkhd_estimator_factory = LikelihoodEstimatorFactory(initEstimatorFactory);

whittle_type_factory = WhittleTypeEstimatorFactory();
whittle_type_factory.fit_zero_frequency = true;
whittle_type_factory.circle_diameter = 1 * pi;

whittle_t_type_factory = WhittleTypeEstimatorFactory();
whittle_t_type_factory.fit_zero_frequency = true;
whittle_t_type_factory.circle_diameter = 1 * pi;
whittle_t_type_factory.periodogram = tapered_P;

whittle_factory = WhittleFactory();
debiased_factory = DebiasedWhittleFactory();
exact_factory = ExactLikelihoodFactory();

whittle_type_factory.add_sub_factory('Whittle', whittle_factory);
whittle_type_factory.add_sub_factory('Debiased', debiased_factory);
whittle_t_type_factory.add_sub_factory('Tapered Whittle', whittle_factory);

lkhd_estimator_factory.add_sub_factory('Whittle', whittle_type_factory)
lkhd_estimator_factory.add_sub_factory('Debiased', whittle_type_factory)
lkhd_estimator_factory.add_sub_factory('Exact', exact_factory);
lkhd_estimator_factory.add_sub_factory('Tapered Whittle', ...
    whittle_t_type_factory);

%We list the estimators to be used
estimators = {'Debiased', 'Whittle', 'Tapered Whittle'};

%We will store exact lkh values at estimated parameters for each patch and
%each method
exact_likelihood_values = zeros(4, length(estimators));


for i = 1 : 4
    disp('------------------');
    data = eval(['topodata' num2str(i)]);
    [results{i}, samples{i}] = fitMaternToTopoData(data, estimators, ...
        lkhd_estimator_factory);
    res = results{i};
    for j_est = 1 : length(estimators)
        model = res{j_est};
        p = model.getParameters();
        disp(p);
        ExactLKH = lkhd_estimator_factory.get_estimator(samples{i}.grid,...
            'Exact');
        lkh = ExactLKH.compute_likelihood(samples{i}, model);
        exact_likelihood_values(i, j_est) = lkh;
        disp(['Exact lkh for these parameters:' num2str(lkh)]);
    end
end

%Plot


rg = RandomGenerator(610);
rg2 = RandomGenerator(610);
rg3 = RandomGenerator(610);

groups = [GroupImagesc()];
for i = 1 : 4
    groups(i) = GroupImagesc();
end

for i = 1 : 4
    figure
    subplot(2,2, 1)
    realSample = samples{i};
    realSample.plot(false, ['Real Sample n°' num2str(i)], groups(i));
    g = realSample.grid;
    WSample = g.simulate(results{i}{2}, rg);
    dWSample = g.simulate(results{i}{1}, rg2);
    tWSample = g.simulate(results{i}{3}, rg3);
    subplot(2, 2, 3)
    WSample.plot(false, "Whittle",groups(i));
    subplot(2, 2, 4)
    tWSample.plot(false, "Tapered Whittle",groups(i));
    subplot(2, 2, 2)
    dWSample.plot(false, 'Debiased',  groups(i));
end
    


