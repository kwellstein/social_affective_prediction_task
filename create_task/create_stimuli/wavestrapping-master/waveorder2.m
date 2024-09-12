function f=waveorder2(s,n,wv,it,S);
%  Creates ordered image by manipulating wavelet coefficents for 2-D data
%  Can be used to "cool" image (iteratively order) 

%  Written by M.B.

if nargin<3, wv='db4'; end,
if nargin<2 n=8; end
if nargin<4, it=100; end
if nargin<5, S=sum(100*clock); end

[rr,col,dim] = size(s);
N=max(n);

for j=1:dim,
    ss=s(:,:,j);
    [cc,l]=wavedec2(ss,N,wv);
    for i=n, ch=[]; cv=[]; cd=[];
        rand('state',S);          %reset random state
        nl1=l(N+2-i,1); nl2=l(N+2-i,2);
        
        ch=detcoef2('h',cc,l,i);
        cv=detcoef2('v',cc,l,i);
        cd=detcoef2('d',cc,l,i);
        
        
        ch=reshape(ch,1,nl1*nl2);
        sch=sort(ch(:)); rch=ch;
        rch(1:2:end)=sch(1:ceil(end/2));
        rch(2:2:end)=sch(ceil(end/2)+1:end);
        
        cv=reshape(cv,1,nl1*nl2);
        sch=sort(cv(:)); rcv=cv;
        rcv(1:2:end)=sch(1:ceil(end/2));
        rcv(2:2:end)=sch(ceil(end/2)+1:end);
        
        cd=reshape(cd,1,nl1*nl2);
        sch=sort(cd(:)); rcd=cd;
        rcd(1:2:end)=sch(1:ceil(end/2));
        rcd(2:2:end)=sch(ceil(end/2)+1:end);
        
        if it==100,
            cd=rcd; ch=rch; cv=rcv;
        end
        
        if it<100,
            num=round(nl1.*nl2.*it/100); %num coeff's to permute
            p=randperm(nl1.*nl2);  %these are the ones to permute
            ch(p(1:num))=rch(p(1:num)); %swap 'em
            cv(p(1:num))=rcv(p(1:num)); %swap 'em
            cd(p(1:num))=rcd(p(1:num)); %swap 'em
        end
        
        cc(l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+1: ...
            l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+nl1*nl2)=ch;
        cc(l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+l(N+2-i,1)*l(N+2-i,2)+1:...
            l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+2*nl1*nl2)=cv;
        cc(l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+2*l(N+2-i,1)*l(N+2-i,2)+1:...
            l(1,1)*l(1,2)+3*sum(l(2:N+1-i,1).*l(2:N+1-i,2))+3*nl1*nl2)=cd;
        
        
    end
    
    ff(:,:)=waverec2(cc,l,wv);
    
    %option to give surrogate series the same amplitude distribution os
    %original image
    
    if dim==1, %amplitude adjustment but won;t work with colours
        f_vec=ff(:); s_vec=ss(:);
        z=zeros(length(f_vec),3);
        s_st=sortrows(s_vec);
        z(:,1)=f_vec; z(:,2)=[1:length(f_vec)];
        z=sortrows(z,1);
        z(:,3)=s_st;
        z=sortrows(z,2);
        f_vec=z(:,3);
        f=reshape(f_vec,rr,col);
    end
    f(:,:,j)=ff;
end

