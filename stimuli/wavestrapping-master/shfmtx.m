function f=shfmtx(mtx,nz);
%  Randomly shuffles the entries of a matrix only at locations specified by nz
%  Written by M.B. 

if nargin<2, nz=find(mtx); end
a=zeros(length(nz),2);
a(:,1)=nz;
a(:,2)=randperm(length(nz))';
a=sortrows(a,2);
mtx(nz)=mtx(a(:,1));
f=mtx;