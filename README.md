ScatNet
-------

ScatNetLight is a MATLAB implementation of the Scattering Networks optimized for image classification.

See homepage of the Scattering Networks:

http://www.di.ens.fr/data/scattering

Author contact: Edouard Oyallon, edouard.oyallon@ens.fr


Install ScatNetLight + Classification pipeline
---------------

- launch 'load_path_software' from matlab shell

[optional] : add the following two lines to your startup.m file
so that matlab does the addpath automatically when it starts: 


    addpath /path/to/scatnet;
    load_path_software;

Quickstarts
-----------

See 'quick_tutorial.m' in the main folder or the 'tutorial' folder in scatnet_light.

You will have to modify the function 'create_config_caltech_101', 'create_config_caltech_256', 'create_config_cifar_10' and 'create_config_cifar_100'. The dataset will also have to be downloaded and put in separate folders. The software is outputting intermediary features that can take a consequent size on a harddriver. Also, a server with at least 256go of memory is recommended for most of the experiments, if you want to use the dimensionality reduction algorithm.(it can be removed by setting option.Classification.nAverageKernel equal to -1)

Copyright
----------

This code is mainly based on the implementation of ScatNet v0.2 done by Laurent Sifre and Joakim Anden

The code for the Selesnick wavelet filters was written by Shihua Cai, Keyong Li, and Ivan Selesnick. It has been included in ScatNet with their permission.

The supervised algorithm of feedforward selection based on OLS has been written by Xiu Cheng for the class specificic part, Matthew Hirn for the selection of variable algorithm.

The SVM's code is an extension of libsvm written by Joakim Anden.

The code to compute kernel has been written by Jordi and Gustavo Camps and is included with their permission.

