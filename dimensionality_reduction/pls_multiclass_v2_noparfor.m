
function [Feat_Tr, Feat_Te, meta] = pls_multiclass_v2( Data_Tr, Data_Te, Labels_Tr, K, D)
% concatenate K groups of features
%
% input: 
%       Data_Tr         p-by-NTr, original representation of training data
%       Data_Te         p-by-NTe
%       Labels_Tr       1-by-NTr, labels of training data, taking values 1, ..., K
%       K               number of class
%       D               intended reduced dimension per-class
%
% output:
%       Feat_Tr         Dall-by-NTr, Representation in reduced dimension,
%                           Dall is the total number of nonrepetitive
%                           selected indeces
%       Feat_Te         Dall-by-NTe
%       meta.D          dimension per-class
%
% OLS (Parital Least Square) supervised dimension reduction for K-classes
%
% train the selected subspace for each class in one-vs-all mode, and
% concatenate the features
%
% Xiuyuan CHENG 03/10/2014
%
%%%%%

%addpath ./olscode/

[p, NTr] = size( Data_Tr);
NTe = size( Data_Te, 2);


% OLS per class 

meta.select_index = cell(numel(K),1);

Feat_Tr = zeros( numel(K)*D, NTr);
Feat_Te = zeros( numel(K)*D, NTe);

Q_cell_tr=cell(numel(K),1);
Q_cell_te=cell(numel(K),1);

select_index2=cell(numel(K),1);

for icls = 1: numel(K)
    fprintf('PLS processing class %d:', icls);
    
    %%% linear regression: y = X * beta
     
    xtr = Data_Tr.'; % training data, N-by-p
    xte = Data_Te.'; %test data
    
    y = zeros( NTr, 1); y( Labels_Tr == K(icls) ) = numel(K); %training label, N-by-1 before it was K
    y=y-mean(y);
    %%% firstly select the bias term/the constant feature, equivalently remove the mean per-coordinate
    %xtr1 = bsxfun( @minus, xtr, mean( xtr, 1));
    xtr1 = xtr;
    
    %%% OLS on training data to learn the selected D indeces
    atom_ind = ols( y, xtr1, D);
    if numel( atom_ind) < D
        warning(sprintf('selected %d dimensions only.', numel( atom_ind) ));
        %pause();
    end
    select_index2{icls}=atom_ind;
    %meta.select_index{icls} = atom_ind;

    % The new representation is the Q_tr so that Q_tr*R_tr = (X_tr|_selected)
    % thus, Q_te = (X_te|_selected) * inv(R_tr)
    [Q,R] = qr( xtr(:, atom_ind), 0); %if N > D, then Q is N-by-D, and R is D-by-D

   % alpha=Q' * y;
    Q_tr = Q;
    Q_te = xte(:, atom_ind)/R;
    Q_cell_tr{icls}=Q_tr';
    Q_cell_te{icls}=Q_te.';
    %Feat_Tr( D*(icls-1)+1: D*icls, :) = Q_tr';
    %Feat_Te( D*(icls-1)+1: D*icls, :) = Q_te.';

end


k1=1;
k2=1;

meta.select_index=zeros(numel(K),D);
for icls=1:numel(K)
    meta.select_index(icls,1:numel(select_index2{icls}))=select_index2{icls};
     Feat_Tr(k1:(k1-1+size(Q_cell_tr{icls},1)), :) = Q_cell_tr{icls};
    Feat_Te( k2:(k2-1+size(Q_cell_te{icls},1)), :) = Q_cell_te{icls};
    k1=k1+size(Q_cell_tr{icls},1);
    k2=k2+size(Q_cell_tr{icls},1);
end


