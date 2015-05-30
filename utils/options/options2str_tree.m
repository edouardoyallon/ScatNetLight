function s=options2str_tree(options)
%this function takes an options with field and put it into vec
%%
fn=fieldnames(options);
s=[];
for i=1:numel(fn)
    if ~strcmp(fn{i},'null')
        s=sprintf('%s/%s_',s,fn{i});
        val=eval(['options.',fn{i}]);
        switch class(val)
            case 'double'
                switch (numel(val))
                    case 1
                        s=sprintf('%s%d_',s,floor(val));
                    case 2
                        s=sprintf('%s%d_%d_',s,floor(val(1)),floor(val(2)));
                end
            case 'char'
                s=sprintf('%s%s_',s,val);
            case 'cell'
                c1 = val{1};
                switch class(c1)
                    case 'char'
                        for j = 1:numel(val)
                            s=sprintf('%s%s_',s,val{j});
                        end
                end
            case 'struct'
                s=sprintf('%s/%s',s,options2str_tree(val));
                
        end
    end
end
s = [s(2:end),'/'];
end