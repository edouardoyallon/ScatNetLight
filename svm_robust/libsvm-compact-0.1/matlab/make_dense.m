% This make.m is for MATLAB and OCTAVE under Windows, Mac, and Unix

CompFiles = { ... Files to compile
    {'libsvmread.c'} ...
    {'libsvmwrite.c'} ...
    {'svmtrain.c'           '../svm.cpp' 'svm_model_matlab.c'} ...
    {'svmpredict.c'         '../svm.cpp' 'svm_model_matlab.c'} ...
    {'svmtrain_inplace.c'   '../svm.cpp' 'svm_model_matlab.c'} ...
    {'svmpredict_inplace.c' '../svm.cpp' 'svm_model_matlab.c'} ...
    };

MEXOPTS = { ... Mex options
    '-g' ...
    '-largeArrayDims' ...
    };

try
    Type = ver;
    % This part is for OCTAVE
    if (strcmp(Type(1).Name, 'Octave') == 1)
        
        for f = 1:4
            mex( CompFiles{f}{:} )
        end
        
    % This part is for MATLAB
    % Add -largeArrayDims on 64-bit machines of MATLAB
    else
                
        cc = mex.getCompilerConfigurations; % Get default compiler configurations used by the mex command
        if ispc && strcmp(cc(1).Manufacturer, 'Microsoft')
            FLAGS = {'COMPFLAGS="$COMPFLAGS /D _DENSE_REP"'};
        else
            FLAGS = {'CFLAGS="\$CFLAGS -D _DENSE_REP -std=c99"' ...
                     'CXXFLAGS="\$CXXFLAGS -D _DENSE_REP"'};
        end
        
        for f = 1:numel(CompFiles)
            mex( MEXOPTS{:}, FLAGS{:}, CompFiles{f}{:} )
        end
        
    end
catch
    fprintf('If make.m fails, please check README about detailed instructions.\n');
end
