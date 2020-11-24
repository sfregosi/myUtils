function [peta]=findpeaksholdoff(arr,thr,post)
L=length(arr);
m=1;np=0;
p(round(L/post))=0;
a(round(L/post))=0;
while m<=L
    if arr(m)<thr
        m=m+1;
    else
        np=np+1;
        try
        [a(np) p(np)]=max(arr(m:m+post));
        catch
        [a(np) p(np)]=max(arr(m:end));
        end;
        p(np)=p(np)+m-1;
        m=m+post;
    end;
end;

a(np+1:end)=[];
p(np+1:end)=[];
peta=[a;p]';