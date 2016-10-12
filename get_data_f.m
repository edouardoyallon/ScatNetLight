function w=get_data_f(x,train,test)
if(strcmp('train',x))
   w=train;
else
    w=test;
end