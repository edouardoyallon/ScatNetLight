function option=create_config_caltech_256(serverName,date_exp)
if(strcmp(serverName,'my_server_name'))
    option.General.path2database='PATHS/Caltech256';
    option.General.path2outputs='PATHS/Output/';
    option.Classification.Threads_dim_red=10;
    option.Classification.Threads_classif=12;
else
    error('Server not recognized');
end



option.General.numJobPerWorker=128;%128;
%%%% General options



option.Exp.Type='caltech256';

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

% Classification options
option.Classification.n_run=5;
option.Classification.random_generator_key=10;
option.Classification.C=50;
option.Classification.D=30;
option.Classification.nAverageKernel=5;
option.Classification.SIGMA_v=1;
end
