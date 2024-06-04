function f=waveshuff2(s,n,wv,S); 
%Creates surrogate data by permuting wavelet coefficents for 2-D data
%Only shuffles wavelet coefficients where the data is non-zero.
%Written by M.B. 2002

if nargin<3, wv='db4'; end, if nargin<2 n=1:8; end
if nargin<4, S=sum(100*clock); end	%Randomizing seed
[rr,col] = size(s); dim=1; N=max(n);
if ndims(s)>2, [rr,col,dim]=size(s); end
rand('state',S);
st=floor(rand(1,length(n))*10^6); %A different seed for each level
fnd=find(ones(rr,col));
for j=1:dim;
   fnd=intersect(fnd,find(s(:,:,j)));
   [c(j,:),l]=wavedec2(s(:,:,j),N,wv); % perform 2-D wavelet decomposition
end
nzmtx=zeros(rr,col); nzmtx(fnd)=1;
cc=c; cnt=0;
for i=n, ch=[]; cv=[]; cd=[]; %Each scale
   nl1=l(N+2-i,1); nl2=l(N+2-i,2);
   ldr=floor(rr/(2^i));  fstr=ceil((nl1-ldr)/2);
   ldc=floor(col/(2^i)); fstc=ceil((nl2-ldc)/2);	
   zmtxi=[]; nzmtxi=[]; nmtxi=[];
   nmtxi=nzmtx(1:2^i:rr,1:2^i:col);
   zmtxi(fstr+1:fstr+ldr,:)=nmtxi;
   nzmtxi(:,fstc+1:fstc+ldc)=zmtxi;
   nzmtxi(fstr+ldr+1:nl1,:)=zeros(nl1-fstr-ldr,fstc+ldc);
   B=4; %Size of boundary to 'grab'
   nzbdy=circshift(nzmtxi,[0 -B])+circshift(nzmtxi,[0 B])+circshift(nzmtxi,[B])+circshift(nzmtxi,[-B]);
   %nzmtxi=nzmtxi+nzbdy;
   fndi=find(nzmtxi); fndb=find(nzbdy);
   if length(fndi)<2, break, end
   cnt=cnt+1;
   for j=1:dim;	%Each image
      ch=detcoef2('h',c(j,:),l,i);
      cv=detcoef2('v',c(j,:),l,i);
      cd=detcoef2('d',c(j,:),l,i);
      rand('state',st(cnt)); 
      ch=shfmtx(ch,fndi);
      ch=shfmtx(ch,fndb);
      rand('state',st(cnt)); 
      cv=shfmtx(cv,fndi);
      cv=shfmtx(cv,fndb);
      rand('state',st(cnt)); 
      cd=shfmtx(cd,fndi);  
      cd=shfmtx(cd,fndb);  
      ch=reshape(ch,1,l(N+2-i,1)*l(N+2-i,2));
		cv=reshape(cv,1,l(N+2-i,1)*l(N+2-i,2));
      cd=reshape(cd,1,l(N+2-i,1)*l(N+2-i,2));
      cc(j,l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+1: ...
         l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+nl1*nl2)=ch;
      cc(j,l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+l(N+2-i,1)*l(N+2-i,2)+1:...
         l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+2*nl1*nl2)=cv;
      cc(j,l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+2*l(N+2-i,1)*l(N+2-i,2)+1:...
         l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+3*nl1*nl2)=cd;
   end
end
f=zeros(size(s));
for j=1:dim
   ff(:,:,j)=waverec2(cc(j,:),l,wv); % perform multilevel 2-D wavelet reconstruction
end
f(find(s))=ff(find(s));
f=f*(mean(abs(s(find(s))))/mean(abs(f(find(f)))))^1.3; %Renormalize