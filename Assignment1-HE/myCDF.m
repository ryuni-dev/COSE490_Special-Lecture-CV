function output = myCDF(image)

output=zeros(256,1);

% todo
[M, N] = size(image);
MN = M * N;
hist=zeros(256,1);
for x=1:M
    for y=1:N
        hist(image(x, y)+1)= hist(image(x, y)+1)+1;
    end
end

P=hist(1)/MN;
output(1)=P;
for i = 2:256
    P=hist(i)/MN;
    output(i)=output(i-1)+P;
end
end
