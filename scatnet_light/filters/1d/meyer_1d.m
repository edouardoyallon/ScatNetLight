function [psi,phi]=meyer_1d(N,sigma)

phi=zeros(N,1);



w=linspace(-pi,pi,N+1);
w=w(1:N)*sigma;

phi=zeros(N,1);
phi(abs(w)<=4*pi/3)=2^(-1/2)*conj_mirror_filter(w(abs(w)<=4*pi/3)/2);

psi=zeros(N,1);
idx1=abs(w)>=2*pi/3 & abs(w)<=4*pi/3;

psi(idx1)=2^(-1/2)*exp(-1i*w(idx1)/2).*conj(conj_mirror_filter(w(idx1)/2+pi));
idx2=abs(w)>=4*pi/3 & abs(w)<=8*pi/3;

psi(idx2)=2^(-1/2)*exp(-1i*w(idx2)/2).*conj_mirror_filter(w(idx2)/4);


psi(w<0)=0;


    function y=conj_mirror_filter(w_f)

f=@(x)(x.^4.*(35-84.*x+70.*x.^2-20.*x.^3));

w_f=mod(w_f+pi,2*pi)-pi;

y=zeros(size(w_f));

%abs(w)>=pi/3   & abs(w)<=2*pi/3
idx1t=abs(w_f)>=pi/3 & abs(w_f)<=2*pi/3;
idx2t=abs(w_f)<=pi/3;

y(idx2t)=sqrt(2);
y(idx1t)=sqrt(2)*cos(pi/2*f(3*abs(w_f(idx1t))/pi-1));

    end
end