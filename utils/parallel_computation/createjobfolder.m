function createjobfolder(opt,options)
s=options2str_tree(options);
folderPath=[opt.General.path2outputs s];

if ~exist(folderPath, 'dir')
mkdir(folderPath);
end
end