function [labels,getImageFun,score_function,split_function,Wop,Wop_color,filt_opt,scat_opt]=recover_dataset(option)
% Function that gives labels, a function to access to the image according
% to a number, a split function in a testing and training set, operator for
% Y channel, operator for UV channel, the filter option and scattering
% option

if(strcmp(option.Exp.Type,'cifar100'))
    
    S=load([option.General.path2database '/train.mat'],'data','fine_labels');
    data=S.data;
    labels=S.fine_labels;
    
    S=load([option.General.path2database '/test.mat'],'data','fine_labels');
    
    data=[data;S.data];
    labels=[labels;S.fine_labels];
    
    getImageFun=@(n)double(reshape(data(n,:),[32,32,3]));
    
    
    score_function=@(x) score_1VSALL_multiclass(x);
    split_function=@(x) split_fun_cifar();
    [Wop,Wop_color,filt_opt,scat_opt]=create_config_layer_per_layer_cifar(option);
    
elseif(strcmp(option.Exp.Type,'cifar10'))
    data=[];
    labels=[];
    dataset={'data_batch_1.mat','data_batch_2.mat','data_batch_3.mat','data_batch_4.mat','data_batch_5.mat','test_batch'};
    
    for i=1:6
        S=load([option.General.path2database '/' dataset{i}],'data','labels');
        data=[data;S.data];
        labels=[labels;S.labels];
    end
    
    getImageFun=@(n)double(reshape(data(n,:),[32,32,3]));
    
    
    score_function=@(x) score_1VSALL_multiclass(x);
    split_function=@(x) split_fun_cifar();
    [Wop,Wop_color,filt_opt,scat_opt]=create_config_layer_per_layer_cifar(option);
    
    
elseif(strcmp(option.Exp.Type,'cifar10_PCA'))
    data=[];
    labels=[];
    dataset={'data_batch_1.mat','data_batch_2.mat','data_batch_3.mat','data_batch_4.mat','data_batch_5.mat','test_batch'};
    
    for i=1:5
        S=load([option.General.path2database '/' dataset{i}],'data','labels');
        data_train=[data;S.data];
        labels=[labels;S.labels];
    end
    S=load([option.General.path2database '/' dataset{6}],'data','labels');
        data_test=S.data;
        labels=[labels;S.labels];
    
    getImageFun=arrayfun(@(x) if(strcmp(x,'train')) data_train else data_test);
    
    
    
    score_function=@(x) score_1VSALL_multiclass(x);
    split_function=@(x) split_fun_cifar();
    [Wop,Wop_color,filt_opt,scat_opt]=create_config_layer_per_layer_cifar_PCA(option);
    
    
elseif(strcmp(option.Exp.Type,'caltech101'))
    
    
    subfolders = dir(option.General.path2database);
    subfolders=subfolders([subfolders.isdir]);
    subfolders=subfolders(~ismember({subfolders.name}',{'.','..'}));
    
    nClass=length(subfolders);
    labels=0;
    % We look up each folder
    k=1;
    for i = 1:nClass
        subname = subfolders(i).name;
        frames = dir(fullfile(option.General.path2database, subname, '*.jpg'));
        cNum = length(frames);
        RP=1:cNum;
        for j = 1:cNum
            [pdir, fname] = fileparts(frames(j).name);
            images(k).class=i;
            labels(k)=i;
            images(k).path=fullfile(option.General.path2database,subname,[fname '.jpg']);
            images(k).positionIntraClass=RP(j);
            k=k+1;
        end
    end
    
    score_function=@(x) score_1VSALL_multiclass(x);
    split_function=@(x) split_fun_caltech_101(labels');
    getImageFun=@(n)imread(images(n).path);
    [Wop,Wop_color,filt_opt,scat_opt]=create_config_layer_per_layer_caltech(option);
    
    
elseif(strcmp(option.Exp.Type,'caltech256'))
    
    subfolders = dir(option.General.path2database);
    subfolders=subfolders([subfolders.isdir]);
    subfolders=subfolders(~ismember({subfolders.name}',{'.','..'}));
    labels=0;
    nClass=length(subfolders);
    
    % We look up each folder
    k=1;
    for i = 1:nClass
        subname = subfolders(i).name;
        frames = dir(fullfile(option.General.path2database, subname, '*.jpg'));
        cNum = length(frames);
        RP=1:cNum;
        for j = 1:cNum
            [pdir, fname] = fileparts(frames(j).name);
            images(k).class=i;
            labels(k)=i;
            images(k).path=fullfile(option.General.path2database,subname,[fname '.jpg']);
            images(k).positionIntraClass=RP(j);
            k=k+1;
        end
    end
    score_function=@(x) score_1VSALL_multiclass(x);
    split_function=@(x) split_fun_caltech_256(labels',30);
    getImageFun=@(n)imread(images(n).path);
    [Wop,Wop_color,filt_opt,scat_opt]=create_config_layer_per_layer_caltech(option);    
end
end