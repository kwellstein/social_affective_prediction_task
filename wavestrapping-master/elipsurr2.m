function f=elipsurr2(s,n,wv,cz,rad); 
%  Creates surrogate data by permuting wavelet coefficents for 2-D data
%  Permutes a central ellipitcal region. 

%  Written by M.B. - some commenting by A.M.P.  
% s = input image
% n = spatial scale
% wv = wavelet type
% cz = resampling scheme (1 = permute; 2 = rotate)
% rad = radius measures

% defaults
if nargin<3, wv='db2'; end, 
if nargin<2 n=8; end
if nargin<4, cz=1; end    %choice of resampling scheme
if nargin<5, rad=[0 0]; end		%size of resampling window
if length(rad)<2, rad(1,2)=rad(1,1); end
[rr,col] = size(s); dim=1; N=max(n);
if ndims(s)>2, [rr,col,dim]=size(s); end
for j=1:dim;
   [c(j,:),l]=wavedec2(s(:,:,j),N,wv); % perform 2-D wavelet decomposition
end
cc=c;

% wavestrap
for i=n, ch=[]; cv=[]; cd=[]; i;
   st=sum(100*clock);
   nl1=l(N+2-i,1); nl2=l(N+2-i,2); m1=ceil(nl1/2); m2=ceil(nl2/2);
   %r=zeros(1,nl2);
   for ii=1:nl1,						%Create mtx to be randomized
      r(i,ii)=floor(rad(1,1)/rad(1,2)*real(sqrt((rad(1,2)^2)/(2^(2*i))-(m1-ii)^2)));
   end   
   for j=1:dim;
      ch=detcoef2('h',c(j,:),l,i);
      cv=detcoef2('v',c(j,:),l,i);
      cd=detcoef2('d',c(j,:),l,i);
      rand('state',st); 
      if cz==1,     
         for ii=1:nl1, ch(ii,m1-r(i,ii):m1+r(i,ii))=permtx(ch(ii,m1-r(i,ii):m1+r(i,ii))); end
      elseif cz==2, 
         for ii=1:nl1, ch(ii,m1-r(i,ii):m1+r(i,ii))=rotmtx(ch(ii,m1-r(i,ii):m1+r(i,ii))); end
      else
         for ii=1:nl1, ch(ii,m1-r(i,ii):m1+r(i,ii))=blkmtx(ch(ii,m1-r(i,ii):m1+r(i,ii))); end
      end 
      %rand('state',st); 
      if cz==1,     
         for ii=1:nl1, cv(ii,m1-r(i,ii):m1+r(i,ii))=permtx(cv(ii,m1-r(i,ii):m1+r(i,ii))); end
      elseif cz==2, 
         for ii=1:nl1, cv(ii,m1-r(i,ii):m1+r(i,ii))=rotmtx(cv(ii,m1-r(i,ii):m1+r(i,ii))); end
      else
         for ii=1:nl1, cv(ii,m1-r(i,ii):m1+r(i,ii))=blkmtx(cv(ii,m1-r(i,ii):m1+r(i,ii))); end
      end 
      %rand('state',st); 
      if cz==1,     
         for ii=1:nl1, cd(ii,m1-r(i,ii):m1+r(i,ii))=permtx(cd(ii,m1-r(i,ii):m1+r(i,ii))); end
      elseif cz==2, 
         for ii=1:nl1, cd(ii,m1-r(i,ii):m1+r(i,ii))=rotmtx(cd(ii,m1-r(i,ii):m1+r(i,ii))); end
      else
         for ii=1:nl1, cd(ii,m1-r(i,ii):m1+r(i,ii))=blkmtx(cd(ii,m1-r(i,ii):m1+r(i,ii))); end
      end 
      ch=reshape(ch,1,nl1*nl2);
		cv=reshape(cv,1,nl1*nl2);
      cd=reshape(cd,1,nl1*nl2);
      cc(j,l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+1: ...
         l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+nl1*nl2)=ch;
      cc(j,l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+l(N+2-i,1)*l(N+2-i,2)+1:...
         l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+2*nl1*nl2)=cv;
      cc(j,l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+2*l(N+2-i,1)*l(N+2-i,2)+1:...
         l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+3*nl1*nl2)=cd;
   end
end
for j=1:dim
   f(:,:,j)=waverec2(cc(j,:),l,wv); % And finally perform multilevel 2-D wavelet reconstruction
end
