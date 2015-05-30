train_f = @(y,x,p,prt,fun)(svmtrain_inplace(y',fun(single(x))',p,prt));
predict_f = @(y,x,p,prt)(svmpredict_inplace(y',single(x'),p,'',prt));
do_sparse = 0;

tests