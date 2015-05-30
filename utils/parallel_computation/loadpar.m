function v=loadpar(path,nameOfVariable)
a=load(path,nameOfVariable);
v=eval(['a.' nameOfVariable]);
end