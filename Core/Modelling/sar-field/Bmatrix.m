function B=Bmatrix(n,ksq)

B=zeros(n^2,n^2);

B(1,1)=4+ksq;
B(1,2)=-1;
B(2,1)=-1;
B(2,2)=4+ksq;
B(2,3)=-1;
B(3,2)=-1;


B(n^2,n^2)=4+ksq;
B(n^2,n^2-1)=-1;
B(n^2-1,n^2)=-1;

for i=1:n
    for j=1:n
        count = 0;
        if i>=2
        B((i-1)*n+j,(i-2)*n+j)=-1;
        count = count + 1;
        end
         if i*n+j<=n^2
        B((i-1)*n+j,i*n+j)=-1;
        count = count + 1;
         end
        if (i-1)*n+j-1>0
        B((i-1)*n+j,(i-1)*n+j-1)=-1;
        count = count + 1;
        end
         if (i-1)*n+j+1<=n^2
        B((i-1)*n+j,(i-1)*n+j+1)=-1;
        count = count + 1;
         end
        B((i-1)*n+j,(i-1)*n+j)=4+ksq;
    end
end


