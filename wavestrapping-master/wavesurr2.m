function f=wavesurr2(s,n,wv,cz,st,m); 
%  Creates surrogate data by permuting wavelet coefficents for 2-D data
%  Permutes entire image. 

%  Written by M.B. - some commenting by A.M.P.  

% s = input image
% n = spatial scale
% wv = wavelet type
% cz = resampling scheme (1 = permute; 2 = rotate)
% st = seed for randomization state. 0 = random seed. Any other number will be seed. 

if nargin<3, wv='db4'; end, if nargin<2 n=8; end
if nargin<4, cz=1; end    %choice of resampling scheme
if nargin<5, st = 0; end
if nargin<6, m=12; end
[rr,col] = size(s); dim=1; N=max(n);
if ndims(s)>2, [rr,col,dim]=size(s); end
for j=1:dim;  %jth row of c is the n-th timepoint of s
   [c(j,:),l]=wavedec2(s(:,:,j),N,wv); % perform 2-D wavelet decomposition
end
cc=c;
for i=n, ch=[]; cv=[]; cd=[];
   if st == 0
       st=sum(100*clock);  %?reset random state
   end
   
   nl1=l(N+2-i,1); nl2=l(N+2-i,2);
   for j=1:dim;
      ch=detcoef2('h',c(j,:),l,i);
      cv=detcoef2('v',c(j,:),l,i);
      cd=detcoef2('d',c(j,:),l,i);
      %rand(1,100);
      
      rand('state',st) 
      if cz==1,     ch=permtx(ch);
      %   for ii=1:length(ch); ch(ii,:)=permtx(ch(ii,:)); end
      elseif cz==2, ch=rotmtx(ch); 
      else         ch=blkmtx(ch,m); end 
      rand('state',st); 
      if cz==1,     cv=permtx(cv); 
      %    for ii=1:length(cv); cv(ii,:)=permtx(cv(ii,:)); end
      elseif cz==2, cv=rotmtx(cv); 
      else         cv=blkmtx(cv,m); end 
      rand('state',st); 
      if cz==1,     cd=permtx(cd); 
      %    for ii=1:length(cd); cd(ii,:)=permtx(cd(ii,:)); end
      elseif cz==2, cd=rotmtx(cd); 
      else         cd=blkmtx(cd,m); end 
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
for j=1:dim
   f(:,:,j)=waverec2(cc(j,:),l,wv); % perform multilevel 2-D wavelet reconstruction
end

