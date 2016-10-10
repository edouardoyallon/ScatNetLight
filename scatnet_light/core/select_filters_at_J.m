function filters_j = select_filters_at_J (filters, J)
    index_leq = find (filters.psi.meta.j > J);
    filters_leq = filters;
    for i = 1:len(index_leq)
        filters_leq.psi.filter{i} = [];
    end
    
    index_eq = find (filters.psi.meta.j ~= J);
    filters_eq = filters;
    for i = 1:len(index_eq)
        filters_eq.psi.filter{i} = [];
    end
    filters_j{1} = filters_leq;
    filters_j{2} = filters_eq;
end