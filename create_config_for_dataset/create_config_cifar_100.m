function option=create_config_cifar_100(serverName,date_exp)
if(strcmp(serverName,'my_server_name'))
    option.General.path2database='PATHS/cifar-100-matlab';
    option.General.path2outputs='PATHS/Output/';
    option.Classification.Threads_dim_red=0;
    option.Classification.Threads_classif=10;
else
    error('Server not recognized');
end



option.General.numJobPerWorker=512;

%%%% General options
option.Exp.Type='cifar100';
if(nargin==1)
    date_exp= num2str(clock);
    date_exp=strrep(date_exp,' ','');
    option.Exp.date_exp=date_exp;
else
    option.Exp.date_exp=date_exp;
end


option.Layers.color=1;
option.Layers.size=64;
option.Layers.size_color=64;
option.Layers.J=4;

option.Classification.n_run=1;
option.Classification.random_generator_key=10;
option.Classification.C=50;
option.Classification.D=20;
option.Classification.nAverageKernel=2;
option.Classification.SIGMA_v=1;
end
