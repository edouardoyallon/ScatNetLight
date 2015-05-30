function option=create_config_caltech_101(serverName,date_exp)
if(strcmp(serverName,'my_server_name'))
    option.General.path2database='PATHS/Caltech101';
    option.General.path2outputs='PATHS/Output/';
    option.Classification.Threads_dim_red=10;
    option.Classification.Threads_classif=12;
else
    error('Server not recognized');
end


option.General.numJobPerWorker=128;

%%%% General options
option.Exp.Type='caltech101';
if(nargin==1)
    date_exp= num2str(clock);
    date_exp=strrep(date_exp,' ','');
    option.Exp.date_exp=date_exp;
else
    option.Exp.date_exp=date_exp;
end


option.Layers.color=1;
option.Layers.size=256;
option.Layers.size_color=64;
option.Layers.J=6;
option.Layers.Type_scattering='tr'

option.Classification.n_run=5;
option.Classification.random_generator_key=10;
option.Classification.C=50;
option.Classification.D=30;
option.Classification.nAverageKernel=5;
option.Classification.SIGMA_v=1;
end
