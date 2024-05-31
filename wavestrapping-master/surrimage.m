function f=surrimage(s,nn,wv,chc,N); 
%  Function to create surrogate data in the time domain for a series of images
%  Written by M.B. 

if nargin<3, wv='db6'; end, 
if nargin<2 nn=1:3; end, n=max(nn);
[rr,col,nt] = size(s); 
if nargin<4, chc=3;	end						%Choice of scheme: 1=block; 2= cyclic; 3=random
if nargin<5, N=5;	end												%No. of blocks if block-resampling employed 
dim=1; if ndims(s)>3, [rr,col,nt,dim] = size(s); end
ff=reshape(s,rr*col,nt,dim);
fnd=zeros(rr*col,dim); fndi=zeros(1,dim);
%1. Find non-zero elements for each slice
for j=1:dim;
   fn=find(ones(rr*col,1));
   fn=intersect(fn,find(max(ff(:,:,j)'))'); 
   fndi(1,j)=length(fn);
   fnd(1:fndi(1,j),j)=fn;
   fff=ff(fnd(1:fndi(1,j),j),:,j);
   for i=1:fndi(1,j);
      [c(:,i,j),l]=wavedec(fff(i,:),n,wv);
  end
end
cc=zeros(size(c));
S=sum(100*clock);
%2. Now do wavelet surrogate algorithm on non-zero voxels;
for j=1:dim,
   rand('state',S)
   cc(:,:,j)=c(:,:,j);
   for i=nn,
     cp=[]; C=[];
     for jj=1:fndi(1,j);
        cp(:,jj)=(detcoef(c(:,jj,j),l,i)); 
     end
     if chc==1;
       L=l(n+2-i); M=ceil(L/N);															%block
       C(1,:)=randperm(M); for k=2:N, C(k,:)=C(1,:); end, C=reshape(C,1,N*M)';			%resampling
       C(L+1:N*M)=[];																	%technique
       cp(:,j+1)=C;																		%here
       %cp(:,j+1)=(1:l(n+2-i))';  													    %No permutation
     elseif chc==2;
       cp(:,j+1)=mod((1:l(n+2-i))+ceil(rand*l(n+2-i)),l(n+2-i))'+1; 	                 %Cyclic rotation
     else
       cp(:,j+1)=randperm(l(n+2-i))'; 											        %Random permutation
     end
     cp=sortrows(cp,j+1);
     cc(sum(l(1:n+1-i))+1:sum(l(1:n+2-i)),1:jj,j)=cp(:,1:jj);
  end
end
f=zeros(size(ff));
for j=1:dim,
   for i=1:fndi(1,j)
      f(fnd(i,j),:,j)=waverec(cc(:,i,j),l,wv);
   end
end
f=reshape(f,rr,col,nt,dim);
%f=f(find(s));