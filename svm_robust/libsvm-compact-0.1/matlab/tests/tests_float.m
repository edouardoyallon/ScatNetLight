train_f = @(y,x,p,prt,fun)(svmtrain(y(prt),fun(single(x(prt,:))),p));
predict_f = @(y,x,p,prt)(svmpredict(y(prt),single(x(prt,:)),p));
do_sparse = 0;

tests