%
% Skeleton code for COSE490 Fall 2022 Assignment 3
%
% Won-Ki Jeong (wkjeong@korea.ac.kr)
%

clear all;
close all;

%
% Loading input image
%
Img=imread('coins-small.bmp');
% Img=imread('test.jpg');

Img=double(Img(:,:,1));

%
% Parameter setting - modify as you wish
%
dt = 0.6;  % time step
c = 0.5;  % weight for expanding term
niter = 400; % max # of iterations


%
% Initializing distance field phi
%
% Inner region : -2, Outer region : +2, Contour : 0
%
[numRows,numCols] = size(Img);
phi=2*ones(size(Img));
phi(10:numRows-10, 10:numCols-10)=-2;

%
% Compute g (edge indicator, computed only once)
%

% ToDO ------------------------
% ------------------------------------------------
% Get smoothed version of the input Image
% ------------------------------------------------
% Use matlab function
 h = fspecial('gaussian',5,1.0);
 gaussian_blurred = imfilter(Img,h,'symmetric');
 I = gaussian_blurred;
% ------------------------------------------------
% Use LPF from assignment2
% Get size
% dimX = size(Img,1);
% dimY = size(Img,2);
% % Padding
% PQ = size(Img)*2;
% F = fft2(Img,PQ(1),PQ(2));
% F = fftshift(F);
% % figure,imshow(log(1+abs((F))), []);
% G = F;
% D = zeros(PQ(1), PQ(2));
% H = zeros(PQ(1), PQ(2));
% centerP = PQ(1)/2;
% centerQ = PQ(2)/2;
% 
% D0=30;
% n=1;
% 
% for x=1:PQ(1)
%     for y=1:PQ(2)
%         D(x,y)= sqrt((x-centerP)^2 + (y-centerQ)^2);
%         H(x,y)=1/(1+(D(x,y)/D0)^(2*n));
%     end
% end
% % Low pass filtering 
% G= G.*H;
% 
% % figure,imshow(log(1+abs((G))), []);
% G = ifftshift(G);
% I = ifft2(G);
% I = I(1:dimX, 1:dimY);
% I = real(I);
% figure,imshow(I, []);
% ------------------------------------------------
% Derivative code
% Get size
dimX = size(Img,1);
dimY = size(Img,2);
% Initalize
dx=zeros(dimX,dimY);
dy=zeros(dimX,dimY);
% Using sobel filter
for x=2:dimX-1
    for y=2:dimY-1
        dx(x,y) = (I(x+1, y-1) + 2*I(x+1, y) + I(x+1, y+1) - (I(x-1, y-1) + 2*I(x-1, y) + I(x-1, y+1)))./9;
        dy(x,y) = ((I(x-1, y+1) + 2*I(x, y+1) + I(x+1, y+1)) - (I(x-1, y-1) + 2*I(x, y-1) + I(x+1, y-1)))./9;
    end
end

% Calculate magnitude
magnitude = sqrt(dx.^2 + dy.^2);
p=2;    
g = 1./(1+magnitude.^p);

% -----------------------------

%
% Level set iteration
%
for n=1:niter
    
    %
    % Level set update function
    %
    phi = levelset_update(phi, g, c, dt);    

    %
    % Display current level set once every k iterations
	%
	% Modify k to adjust the refresh rate of the viewer
    %
    k = 10;
    if mod(n,k)==0
        figure(1);
        imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on; contour(phi, [0,0], 'r');
        str=['Iteration : ', num2str(n)];
        title(str);
        
    end
end


%
% Output result
%
figure(1);
imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
str=['Final level set after ', num2str(niter), ' iterations'];
title(str);

