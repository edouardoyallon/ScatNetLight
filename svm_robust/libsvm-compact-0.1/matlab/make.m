% This make.m is for MATLAB and OCTAVE under Windows, Mac, and Unix

try
	Type = ver;
	% This part is for OCTAVE
	if(strcmp(Type(1).Name, 'Octave') == 1)
		mex libsvmread.c
		mex libsvmwrite.c
		mex svmtrain.c ../svm.cpp svm_model_matlab.c
		mex svmpredict.c ../svm.cpp svm_model_matlab.c
	% This part is for MATLAB
	% Add -largeArrayDims on 64-bit machines of MATLAB
	else
		mex -g CFLAGS="\$CFLAGS -D _DENSE_REP -D _FLOAT_REP -std=c99" CXXFLAGS="\$CXXFLAGS -D _DENSE_REP -D _FLOAT_REP" -largeArrayDims libsvmread.c
		mex -g CFLAGS="\$CFLAGS -D _DENSE_REP -D _FLOAT_REP -std=c99" CXXFLAGS="\$CXXFLAGS -D _DENSE_REP -D _FLOAT_REP" -largeArrayDims libsvmwrite.c
		mex -g CFLAGS="\$CFLAGS -D _DENSE_REP -D _FLOAT_REP -std=c99" CXXFLAGS="\$CXXFLAGS -D _DENSE_REP -D _FLOAT_REP  " LDFLAGS="\$LDFLAGS  " -largeArrayDims svmtrain.c ../svm.cpp svm_model_matlab.c
		mex -g CFLAGS="\$CFLAGS -D _DENSE_REP -D _FLOAT_REP -std=c99" CXXFLAGS="\$CXXFLAGS -D _DENSE_REP -D _FLOAT_REP  " LDFLAGS="\$LDFLAGS  " -largeArrayDims svmtrain_inplace.c ../svm.cpp svm_model_matlab.c
		mex -g CFLAGS="\$CFLAGS -D _DENSE_REP -D _FLOAT_REP -std=c99" CXXFLAGS="\$CXXFLAGS -D _DENSE_REP -D _FLOAT_REP  " LDFLAGS="\$LDFLAGS  " -largeArrayDims svmpredict.c ../svm.cpp svm_model_matlab.c
		mex -g CFLAGS="\$CFLAGS -D _DENSE_REP -D _FLOAT_REP -std=c99" CXXFLAGS="\$CXXFLAGS -D _DENSE_REP -D _FLOAT_REP  " LDFLAGS="\$LDFLAGS  " -largeArrayDims svmpredict_inplace.c ../svm.cpp svm_model_matlab.c
	end
catch
	fprintf('If make.m failes, please check README about detailed instructions.\n');
end
