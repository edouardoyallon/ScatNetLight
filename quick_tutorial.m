% You can type:
% option=create_config_cifar_10('nameofserver');
%
% OR
%
% option=create_config_cifar_100('nameofserver');
%
% OR
%
% option=create_config_caltech_101('nameofserver');
%
% OR
%
% option=create_config_caltech_256('nameofserver');
%
% option is a structure such that :
%
% option.General: define path to the datasets, the outputs and the size of the
% minibatchs 
% option.General.path2database : path to the dataset
% option.General.path2outputs : outputs folder that will contain all the
% coefficients
% option.General.numJobPerWorker : number of workers to use for minibatch

% option.Exp: define parameters related to the current experiment
% option.Exp.Type : the dataset that is processed
% option.Exp.date_exp : Unix timestamp of the time of the experiment: it
% allows you to avoid to reconstruct the features if you already processed
% them, by using option=create_config_*****('nameofserver','timestamp')

% option.Layers : a few parameters related to the scattering features
% option.Layers.color : color in the representation?
% option.Layers.size : size of the input images in Y
% option.Layers.size_color : size of the input images in UV
% option.Layers.J : invariance to 2^J

% option.Classification : the most complicated part. The classification
% framework used a lot of resources, and has several parameters that are
% not crossvalidated, but are shared across the dataset since they are
% extremely time consuming.
% option.Classification.Threads_dim_red : the number of workers to use
% during the dimension_redution step
% option.Classification.Threads_classif : the number of workers to use
% when using the SVM
% option.Classification.n_run : number of random run to perform on a
% dataset
% option.Classification.random_generator_key : random number generator
% seed, when there are random splits
% option.Classification.C : margin parameter of the SVM
% option.Classification.D : number of feature per class selected by OLS
% option.Classification.nAverageKenerl : number of kernels we averaged per
% class
% option.Classification.SIGMA_v : parameters of the bandwith of the RBF
% kernel

% This will create an option, configuration that you can precisely define.
% Observe that the parameters of classification are the same for the 4
% datasets except the parameter (D,nAverageKernel), because the number of samples is
% different on Caltech or CIFAR datasets. However, they are hard to
% crossvalidate because the OLS algorithm is SLOW.

% Example of usage:
option=create_config_cifar10('my_server')
scatnet_representation_main
