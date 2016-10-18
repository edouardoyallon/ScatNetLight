%% Export features on CIFAR10

fprintf('loading options...\n');

load_path_software
option=struct;
option.Exp=struct;
option.Exp.Type='cifar10_PCA';
option.Exp.n_batches=1;
option.Exp.max_J=3;
option.Exp.log_features=false;
option.General.path2database='./cifar-10-batches-mat';
option.General.path2outputs='./Output/';

size_signal=32;

scat_opt.M=2;

debug_set = 0;

% First layer
filt_opt.layer{1}.translation.J=option.Exp.max_J;
filt_opt.layer{1}.translation.L=8;
scat_opt.layer{1}.translation.oversampling=0;
filt_opt.layer{1}.translation.n_wavelet_per_octave=1;

% Second layer
% Translation
filt_opt.layer{2}.translation.J=option.Exp.max_J;
filt_opt.layer{2}.translation.L=8;
scat_opt.layer{2}.translation.oversampling=0;
scat_opt.layer{2}.translation.type='t';

% Third layer(copy of the previous one)
filt_opt.layer{3}=filt_opt.layer{2};
scat_opt.layer{3}=scat_opt.layer{2};

%% wavelet filters and input data
[~,filters]=wavelet_factory_2d([size_signal,size_signal],filt_opt,scat_opt);

%x=rand(32,32);
filters=filters{1}.translation; 

% Create the config specific to the dataset023
[class,getImage,score_function,split_function,Wop,Wop_color,ds,filt_opt_color]=recover_dataset(option);

x_train=getImage('train');
x_test=getImage('test');

% traning set!
x_train = single(rgb2yuv(x_train));
x_test = single(rgb2yuv(x_test));

max_J=option.Exp.max_J;

q=split_function();
Y_train=q{1};
Y_test=q{2};

%% export

fprintf ('train = %s, test = %s\n\n', num2str(size(x_train)), num2str(size(x_test)))

fprintf('train data...\n');
U_j_train = cell(1, max_J);

for j=1:max_J
    fprintf ('compute scale %d...\n', j)
    U_j_train{j} = compute_J_scale(x_train, filters, j);
end

fprintf('test data...\n');
U_j_test = cell(1, max_J);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
for j=1:max_J
    fprintf ('compute scale %d...\n', j)
    U_j_test{j} = compute_J_scale(x_test, filters, j);
end


fprintf('saving data...\n');

save('x_train', 'x_train', '-v7.3') 
save('x_test', 'x_test', '-v7.3') 
save('Y_train', 'Y_train', '-v7.3')
save('Y_test','Y_test', '-v7.3')
save('U_j_train', 'U_j_train', '-v7.3')
save('U_j_test','U_j_test', '-v7.3')


%EOF
