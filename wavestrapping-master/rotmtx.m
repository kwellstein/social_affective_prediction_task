function f=rotmtx(mtx);
%  Function to randomly cycle a matrix through each of its dimensions
%  Written by M.B. 

sz=size(mtx); s1=sz(1); s2=sz(2);
mtx(1:s1,:,:)=mtx(mod((1:s1)+ceil(rand*s1),s1)+1,:,:);
mtx(:,1:s2,:)=mtx(:,mod((1:s2)+ceil(rand*s2),s2)+1,:);
if ndims(mtx)>2,  s3=sz(3);
   mtx(:,:,1:s3)=mtx(:,:,mod((1:s3)+ceil(rand*s3),s3)+1);
end
f=mtx;


