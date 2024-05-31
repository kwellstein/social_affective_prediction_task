function f=rectsurr2(s,n,wv,cz,frac); 
%  Creates surrogate data by permuting wavelet coefficents for 2-D data
%  Permutes a central rectangular region. This is done as a fraction of the
%  image size - equal fraction in both x and y directions. This could be
%  easily changed if needed. 

%  Written by M.B. - some commenting by A.M.P.  

% s = input image
% n = spatial scale
% wv = wavelet type
% cz = resampling scheme (1 = permute; 2 = rotate)
% frac = fraction of image size to wavestrap

% defaults
if nargin<3, wv='db2'; end, 
if nargin<2 n=8; end
if nargin<4, cz=1; end    %choice of resampling scheme
if nargin<5, frac=2/3; end		%size of resampling window

[rr,col] = size(s); dim=1; N=max(n);
if ndims(s)>2, [rr,col,dim]=size(s); end
for j=1:dim;
   [c(j,:),l]=wavedec2(s(:,:,j),N,wv); % perform 2-D wavelet decomposition
end
cc=c;

% And now wavestrap
for i=n, ch=[]; cv=[]; cd=[]; i;
    st=sum(100*clock);
    nl1=l(N+2-i,1); nl2=l(N+2-i,2); 
    startRow = round((1-frac)/2*nl1)+1;
    endRow = round(frac*nl1)+startRow-1;
    startCol = round((1-frac)/2*nl2)+1;
    endCol = round(frac*nl2)+startRow-1;

   for j=1:dim;
      ch=detcoef2('h',c(j,:),l,i);
      cv=detcoef2('v',c(j,:),l,i);
      cd=detcoef2('d',c(j,:),l,i);
      rand('state',st); 
      if cz==1,     
         ch(startRow:endRow,startCol:endCol)=permtx(ch(startRow:endRow,startCol:endCol));
      elseif cz==2, 
         ch(startRow:endRow,startCol:endCol)=rotmtx(ch(startRow:endRow,startCol:endCol));
      else
         ch(startRow:endRow,startCol:endCol)=blkmtx(ch(startRow:endRow,startCol:endCol));
      end 
      %rand('state',st); 
      if cz==1,     
         cv(startRow:endRow,startCol:endCol)=permtx(cv(startRow:endRow,startCol:endCol));
      elseif cz==2, 
         cv(startRow:endRow,startCol:endCol)=rotmtx(cv(startRow:endRow,startCol:endCol));
      else
         cv(startRow:endRow,startCol:endCol)=blkmtx(cv(startRow:endRow,startCol:endCol));
      end 
      %rand('state',st); 
      if cz==1,     
         cd(startRow:endRow,startCol:endCol)=permtx(cd(startRow:endRow,startCol:endCol));
      elseif cz==2,
         cd(startRow:endRow,startCol:endCol)=rotmtx(cd(startRow:endRow,startCol:endCol));
      else
         cd(startRow:endRow,startCol:endCol)=blkmtx(cd(startRow:endRow,startCol:endCol));
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
