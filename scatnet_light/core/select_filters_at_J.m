function filters_j = select_filters_at_J (filters, J)
    J = J -1;

    filters_j{1} = struct;
    filters_j{1}.meta = filters.meta;
    filters_j{1}.meta.J=J;
    
    filters_j{1}.phi=filters.phi;
    
    
    index_leq = find (filters.psi.meta.j <= J);
    
    for i = 1:length(index_leq)
       filters_j{1}.psi.meta.theta(i)=filters.psi.meta.theta(index_leq(i));
       filters_j{1}.psi.meta.j(i)=filters.psi.meta.j(index_leq(i));
       filters_j{1}.psi.filter{i}=filters.psi.filter{index_leq(i)};
    end
    
  
    filters_j{2} = struct;
    filters_j{2}.meta = filters.meta;
    filters_j{2}.meta.J=J;
    filters_j{2}.phi=filters.phi;
    
    index_eq = find (filters.psi.meta.j == J);
    
    for i = 1:length(index_eq)
       filters_j{2}.psi.meta.theta(i)=filters.psi.meta.theta(index_eq(i));
       filters_j{2}.psi.meta.j(i)=filters.psi.meta.j(index_eq(i));
       filters_j{2}.psi.filter{i}=filters.psi.filter{index_eq(i)};
    end
    
    
end