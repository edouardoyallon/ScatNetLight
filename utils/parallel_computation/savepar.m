function save_par(name,namevariable,variable)
eval([namevariable '=variable;']);
save(name,namevariable);
end