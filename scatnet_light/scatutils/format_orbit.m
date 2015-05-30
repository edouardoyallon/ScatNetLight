function new_orbit=format_orbit(orbit,cell_idx_new_orbits,dim_cat)
% cell_idx_new_orbits is the set of idx to concatenate
% concatenate together
% dim_cat, dimension along which concatenate


SIZE_MAX=max(ndims(orbit{1})+1,dim_cat);

% First, add the dimension of concatenation
tg_size=1:SIZE_MAX;
tg_size(end)=dim_cat;
tg_size(dim_cat)=SIZE_MAX;


new_orbit=cell(length(cell_idx_new_orbits),1);


for i=1:length(cell_idx_new_orbits)
   idx=cell_idx_new_orbits{i};
       new_orbit{i}= permute(cat(SIZE_MAX,orbit{idx}),tg_size);
   
   
end
end
