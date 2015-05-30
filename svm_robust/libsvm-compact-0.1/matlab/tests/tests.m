if ~exist('train_f')
	train_f = @(y,x,p,prt)(libsvmtrain(y(prt),x(prt,:),p));
end

if ~exist('predict_f')
	predict_f = @(y,x,p,prt)(libsvmpredict(y(prt),x(prt,:),p));
end

if ~exist('do_sparse')
	do_sparse = 1;
end

y = [1; 1; 1; 1; 2; 2; 2; 2;];
x = [0 1; 1 0; 1 1; 0.2 0.2; 0 -1; -1 0; -1 -1; -0.2 -0.2];

prt_train = [1 2 3 5 6 7];
prt_test = [4 8];

rho = 0;
sv_coef = [0.5 0.5 -0.5 -0.5];
SVs = [1 2 5 6];

rbf_rho = 0;
rbf_sv_coef = [0.5 0.5 0.5 -0.5 -0.5 -0.5];
rbf_SVs = [1 2 3 5 6 7];

% what happens when C = 1?
model = train_f(y,x,'-c 0.5 -t 0',prt_train,@(x)(x));
[labels,accuracy,decision_values] = predict_f(y,x,model,prt_test);

if norm(full(model.SVs)-x(SVs,:),'fro')<1e-6
	fprintf('SVs OK\n');
else
	error('SVs BAD');
end

if norm(model.sv_coef-sv_coef.','fro')<1e-6
	fprintf('sv_coefs OK\n');
else
	error('sv_coefs BAD');
end

if norm(model.rho-rho)<1e-6
	fprintf('rho OK\n');
else
	error('rho BAD');	
end

if norm(decision_values'-sv_coef*x(SVs,:)*x(prt_test,:)')<1e-6
	fprintf('decision_values OK\n');
else
	error('decision_values BAD');
end

model = train_f(y,x,'-c 0.5 -t 2 -g 0.1',prt_train,@(x)(x));
[labels,accuracy,decision_values] = predict_f(y,x,model,prt_test);

if norm(full(model.SVs)-x(rbf_SVs,:),'fro')<1e-6
	fprintf('SVs OK\n');
else
	error('SVs BAD');
end

if norm(model.sv_coef-rbf_sv_coef.','fro')<1e-6
	fprintf('sv_coefs OK\n');
else
	error('sv_coefs BAD');
end

if norm(model.rho-rbf_rho)<1e-6
	fprintf('rho OK\n');
else
	error('rho BAD');	
end

if norm(decision_values'-rbf_sv_coef*exp(-0.1*(bsxfun(@plus,sum(abs(x(rbf_SVs,:)).^2,2),sum(abs(x(prt_test,:)).^2,2)')-2*x(rbf_SVs,:)*x(prt_test,:)')))<1e-6
	fprintf('decision_values OK\n');
else
	error('decision_values BAD');
end

model = train_f(y,[[1:size(x,1)]' x*x'],'-c 0.5 -t 4',prt_train,@(x)(x));
[labels,accuracy,decision_values] = predict_f(y,[[1:size(x,1)]' x*x'],model,prt_test);

if norm(model.SVs-SVs','fro')<1e-6
	fprintf('SVs OK\n');
else
	error('SVs BAD');
end

if norm(model.sv_coef-sv_coef.','fro')<1e-6
	fprintf('sv_coefs OK\n');
else
	error('sv_coefs BAD');
end

if norm(model.rho-rho)<1e-6
	fprintf('rho OK\n');
else
	error('rho BAD');	
end

if norm(decision_values'-sv_coef*x(SVs,:)*x(prt_test,:)')<1e-6
	fprintf('decision_values OK\n');
else
	error('decision_values BAD');
end

model = train_f(y,[[1:size(x,1)]' x*x'],'-c 0.5 -t 5',prt_train,@auglt);
[labels,accuracy,decision_values] = predict_f(y,[[1:size(x,1)]' x*x'],model,prt_test);

if norm(model.SVs-SVs','fro')<1e-6
	fprintf('SVs OK\n');
else
	error('SVs BAD');
end

if norm(model.sv_coef-sv_coef.','fro')<1e-6
	fprintf('sv_coefs OK\n');
else
	error('sv_coefs BAD');
end

if norm(model.rho-rho)<1e-6
	fprintf('rho OK\n');
else
	error('rho BAD');	
end

if norm(decision_values'-sv_coef*x(SVs,:)*x(prt_test,:)')<1e-6
	fprintf('decision_values OK\n');
else
	error('decision_values BAD');
end

model = train_f(y,[[1:size(x,1)]' bsxfun(@plus,sum(abs(x).^2,2),sum(abs(x).^2,2)')-2*x*x'],'-c 0.5 -t 6 -g 0.1',prt_train,@(x)(x));
[labels,accuracy,decision_values] = predict_f(y,[[1:size(x,1)]' bsxfun(@plus,sum(abs(x).^2,2),sum(abs(x).^2,2)')-2*x*x'],model,prt_test);

if norm(full(model.SVs)-rbf_SVs','fro')<1e-6
	fprintf('SVs OK\n');
else
	error('SVs BAD');
end

if norm(model.sv_coef-rbf_sv_coef.','fro')<1e-6
	fprintf('sv_coefs OK\n');
else
	error('sv_coefs BAD');
end

if norm(model.rho-rbf_rho)<1e-6
	fprintf('rho OK\n');
else
	error('rho BAD');	
end

if norm(decision_values'-rbf_sv_coef*exp(-0.1*(bsxfun(@plus,sum(abs(x(rbf_SVs,:)).^2,2),sum(abs(x(prt_test,:)).^2,2)')-2*x(rbf_SVs,:)*x(prt_test,:)')))<1e-6
	fprintf('decision_values OK\n');
else
	error('decision_values BAD');
end

if do_sparse
	model = train_f(y,sparse([[1:size(x,1)]' x*x']),'-c 0.5 -t 4',prt_train,@(x)(x));
	[labels,accuracy,decision_values] = predict_f(y,sparse([[1:size(x,1)]' x*x']),model,prt_test);

	if norm(model.SVs-SVs','fro')<1e-6
		fprintf('SVs OK\n');
	else
		error('SVs BAD');
	end

	if norm(model.sv_coef-sv_coef.','fro')<1e-6
		fprintf('sv_coefs OK\n');
	else
		error('sv_coefs BAD');
	end

	if norm(model.rho-rho)<1e-6
		fprintf('rho OK\n');
	else
		error('rho BAD');	
	end

	if norm(decision_values'-sv_coef*x(SVs,:)*x(prt_test,:)')<1e-6
		fprintf('decision_values OK\n');
	else
		error('decision_values BAD');
	end
	
	model = train_f(y,sparse([[1:size(x,1)]' bsxfun(@plus,sum(abs(x).^2,2),sum(abs(x).^2,2)')-2*x*x']),'-c 0.5 -t 6 -g 0.1',prt_train,@(x)(x));
	[labels,accuracy,decision_values] = predict_f(y,sparse([[1:size(x,1)]' bsxfun(@plus,sum(abs(x).^2,2),sum(abs(x).^2,2)')-2*x*x']),model,prt_test);

	if norm(full(model.SVs)-rbf_SVs','fro')<1e-6
		fprintf('SVs OK\n');
	else
		error('SVs BAD');
	end

	if norm(model.sv_coef-rbf_sv_coef.','fro')<1e-6
		fprintf('sv_coefs OK\n');
	else
		error('sv_coefs BAD');
	end

	if norm(model.rho-rbf_rho)<1e-6
		fprintf('rho OK\n');
	else
		error('rho BAD');	
	end

	if norm(decision_values'-rbf_sv_coef*exp(-0.1*(bsxfun(@plus,sum(abs(x(rbf_SVs,:)).^2,2),sum(abs(x(prt_test,:)).^2,2)')-2*x(rbf_SVs,:)*x(prt_test,:)')))<1e-6
		fprintf('decision_values OK\n');
	else
		error('decision_values BAD');
	end
	
	model = train_f(y,[[1:size(x,1)]' x*x'],'-c 0.5 -t 5',prt_train,@(x)(sparse(auglt(x))));
	[labels,accuracy,decision_values] = predict_f(y,[[1:size(x,1)]' x*x'],model,prt_test);

	if norm(model.SVs-SVs','fro')<1e-6
		fprintf('SVs OK\n');
	else
		error('SVs BAD');
	end

	if norm(model.sv_coef-sv_coef.','fro')<1e-6
		fprintf('sv_coefs OK\n');
	else
		error('sv_coefs BAD');
	end

	if norm(model.rho-rho)<1e-6
		fprintf('rho OK\n');
	else
		error('rho BAD');	
	end

	if norm(decision_values'-sv_coef*x(SVs,:)*x(prt_test,:)')<1e-6
		fprintf('decision_values OK\n');
	else
		error('decision_values BAD');
	end
end