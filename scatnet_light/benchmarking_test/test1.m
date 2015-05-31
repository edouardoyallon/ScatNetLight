Wop=create_scattering_operators(N,N,'tr',4);
x=randn(N,N);
[S,U]=scat(x,Wop);
