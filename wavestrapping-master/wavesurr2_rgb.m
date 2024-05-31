function f=wavesurr2_rgb(s,n,wv,cz,st,m)
%  Creates surrogate data by permuting wavelet coefficents for 2-D RGB data
%  Permutes entire image but not across RGB channels. 

%  Written by M.B. - some modifications by J.A.R.  

% s = input image
% n = spatial scale
% wv = wavelet type
% cz = resampling scheme (1 = permute; 2 = rotate)
% st = seed for randomization state. 0 = random seed. Any other number will be seed. 
if nargin<2, n=8; end
if nargin<3, wv='db4'; end 
if nargin<4, cz=1; end    %choice of resampling scheme
if nargin<5, st = 0; end
if nargin<6, m=12; end % blkmtx MISSING
dim=1; N=max(n);
if ndims(s)>3, [rr,col,three,dim]=size(s); end  % if series of frames
for j=1:dim                    %jth row of c is the n-th timepoint of s
    [c(j,:),l]=wavedec2(s(:,:,:,j),N,wv);
end
cc=c;
for i=n, ch=[]; cv=[]; cd=[];
    if st == 0
       st=sum(100*clock);  %?reset random state
    end
    nl1=l(N+2-i,1); nl2=l(N+2-i,2);
    len=nl1*nl2*3; % number of elements in each ch, cv, cd matrix
    for j=1:dim
        ch=detcoef2('h',c(j,:),l,i);
        cv=detcoef2('v',c(j,:),l,i);
        cd=detcoef2('d',c(j,:),l,i);
        rand('state',st) 
        if cz==1   
          ch=permtx_2d(ch);
          rand('state',st) 
          cv=permtx_2d(cv);
          rand('state',st) 
          cd=permtx_2d(cd); 
        elseif cz==2
          ch=rotmtx_2d(ch); 
          rand('state',st) 
          cv=rotmtx_2d(cv);
          rand('state',st) 
          cd=rotmtx_2d(cd); 
        else
          ch=blkmtx(ch,m); 
          rand('state',st) 
          cv=blkmtx(cv,m); 
          rand('state',st) 
          cd=blkmtx(cd,m); 
        end
        % convert matrices back to row vectors for storage in c
        ch=reshape(ch,1,len);
        cv=reshape(cv,1,len);
        cd=reshape(cd,1,len);
        % put the row vectors in their proper places in c
        cho=l(1,1)*l(1,2)*3+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2)*3);  % ch offset
        cvo=cho+len;  % cv offset
        cdo=cvo+len;  % cd offset
        cc(j,cho+1:cho+len)=ch;
        cc(j,cvo+1:cvo+len)=cv;
        cc(j,cdo+1:cdo+len)=cd;
    end
end
for j=1:dim
   f(:,:,:,j)=waverec2(cc(j,:),l,wv);
end
end


function f=permtx_2d(mtx)
%Function to randomly permute a matrix in each of its dimensions
% from permtx.m
    sz=size(mtx); s1=sz(1); s2=sz(2);
    mtx(1:s1,:,:)=mtx(randperm(s1),:,:);
    mtx(:,1:s2,:)=mtx(:,randperm(s2),:);
    % % commented, not touching 3rd dimension
    % if ndims(mtx)>2,  s3=sz(3);  
    %    mtx(:,:,1:s3)=mtx(:,:,randperm(s3));
    % end
    f=mtx;
end

function f=rotmtx_2d(mtx)
%Function to randomly cycle a matrix through each of its dimensions
% from rotmtx.m
    sz=size(mtx); s1=sz(1); s2=sz(2);
    mtx(1:s1,:,:)=mtx(mod((1:s1)+ceil(rand*s1),s1)+1,:,:);
    mtx(:,1:s2,:)=mtx(:,mod((1:s2)+ceil(rand*s2),s2)+1,:);
    % % commented, not touching 3rd dimension
    % if ndims(mtx)>2,  s3=sz(3);
    %    mtx(:,:,1:s3)=mtx(:,:,mod((1:s3)+ceil(rand*s3),s3)+1);
    % end
    f=mtx;
end
