function f=permtx(mtx);
%  Function to randomly permute a matrix in each of its dimensions
%  Written by M.B. 

sz=size(mtx); s1=sz(1); s2=sz(2);
mtx(1:s1,:,:)=mtx(randperm(s1),:,:);
mtx(:,1:s2,:)=mtx(:,randperm(s2),:);
if ndims(mtx)>2,  s3=sz(3);
   mtx(:,:,1:s3)=mtx(:,:,randperm(s3));
end
f=mtx;