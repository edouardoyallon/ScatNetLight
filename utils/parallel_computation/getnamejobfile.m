function filePath=getNameJobFile(opt,index,options)
path=opt.General.path2outputs;
s=options2str_tree(options);
filePath=[path s num2str(index) '.mat'];
end