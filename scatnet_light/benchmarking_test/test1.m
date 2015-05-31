Wop=create_scattering_operators(N,N,'t',4);
x=randn(N,N);
[S,U]=scat(x,Wop);
