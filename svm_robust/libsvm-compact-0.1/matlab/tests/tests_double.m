train_f = @(y,x,p,prt,fun)(svmtrain(y(prt),fun(x(prt,:)),p));
predict_f = @(y,x,p,prt)(svmpredict(y(prt),x(prt,:),p));
do_sparse = 1;

tests
