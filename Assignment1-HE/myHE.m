function output = myHE(input)

dimX = size(input,1);
dimY = size(input,2);

output = uint8(zeros(dimX,dimY));

% ToDo
L=256;
S=zeros(256, 1);
cdf=myCDF(input);

for i = 1:L
    S(i)=(L-1) * cdf(i);
end

for x = 1:dimX
    for y = 1:dimY
        output(x, y)=S(input(x, y) + 1);
    end
end
end

