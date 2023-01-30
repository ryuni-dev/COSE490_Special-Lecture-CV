input=imread('racing-noisy.png');

figure,imshow(input);
title('Input Image');

% Get size
dimX = size(input,1);
dimY = size(input,2);

% Convert pixel type to float
[f, revertclass] = tofloat(input);

% Determine good padding for Fourier transform
PQ = paddedsize(size(input));

% Fourier tranform of padded input image
F = fft2(f,PQ(1),PQ(2));
F = fftshift(F);
figure,imshow(log(1+abs((F))), []);

% -------------------------------------------------------------------------

%
% Creating Frequency filter and apply - High pass filter
%

%
% ToDo
%
G = F;
D = zeros(PQ(1), PQ(2));
H = zeros(PQ(1), PQ(2));
centerP = PQ(1)/2;
centerQ = PQ(2)/2;

D0=50;
n=2;

for x=1:PQ(1)
    for y=1:PQ(2)
        D(x,y)= sqrt((x-centerP)^2 + (y-centerQ)^2);
        H(x,y)=1/(1+(D(x,y)/D0)^(2*n));
    end
end
G= G.*H;

figure,imshow(log(1+abs((G))), []);

% -------------------------------------------------------------------------

% Inverse Fourier Transform
G = ifftshift(G);
g = ifft2(G);

% Revert back to input pixel type
g = revertclass(g);

% Crop the image to undo padding
g = g(1:dimX, 1:dimY);

figure,imshow(g, []);
title('Result Image');