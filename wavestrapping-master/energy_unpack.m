%% unpack scales bit

X=mean(X,3); %get rid of colour
X=X./mean(mean(X));  %normalize across images
clear r,
nscales=8;
nreps=500;
%X=waveorder2(X,1:8);
figure, imagesc(X), colormap ('gray'), drawnow
for j=1:8
    for i=1:nreps
        Y=waveswap2(X,j);
        r(i,j)=rms(X(:)-Y(:));
    end 
end
figure(1), hold on, plot(1:j,r,'m')
figure(1), plot(1:j,mean(r),'k'),
ylim([0 0.5])

save wombat X r

%% heating and cooling bit

load wombat
m=[0:5:100];
nreps=100;
nscales=8;
sh=zeros(nscales,length(m));

for n=1:nscales;
    for j=2:length(m),
        clear YY
        for i=1:nreps,
            Y=waveswap2(X,n,'db4',m(j));
            YY(:,i)=Y(:);
        end
        sh(n,j)=mean(std(YY'));
    end
end
figure, imagesc(m,1:n,sh)
figure, plot(m,sh)

sc=zeros(nscales,length(m));
for n=1:8;
    for j=2:length(m),
        clear YY
        for i=1:nreps,
            Y=waveorder2(X,n,'db4',m(j));
            YY(:,i)=Y(:);
        end
        sc(n,j)=mean(std(YY'));
    end
end
figure, imagesc(m,1:n,sc)
figure, plot(m,sc)

save wombat X r m n sh sc

%% Movie bit
clims = [min(min(X)) max(max(X))];
loops=0:1:100;
%F(length(loops)) = struct('cdata',[],'colormap',[]);
v=VideoWriter('order_wombat');
v.FrameRate=10;
open(v)
for i=1:length(loops), 
    Y=waveorder2(X,1:8,'db4',loops(end)-loops(i),1);
    %Y=waveswap2(X,1:8,'db4',loops(end)-loops(i));
    
    %figure(11), image(uint8(Y),clims), xticks([]), yticks([]), drawnow,
    figure(11), imagesc(Y,clims), colormap(gray), xticks([]), yticks([]), drawnow,
    frame=getframe(gcf);
    writeVideo(v,frame);
end
close(v)