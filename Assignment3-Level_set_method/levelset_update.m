%
% Skeleton code for COSE490 Fall 2022 Assignment 3
%
% Won-Ki Jeong (wkjeong@korea.ac.kr)
%

function phi_out = levelset_update(phi_in, g, c, timestep)
phi_out = phi_in;

%
% ToDo
%

% Gradient of phi
[phi_dx, phi_dy] = sobel_filter(phi_in);
dPhi = sqrt(phi_dx.^2 + phi_dy.^2); % mag(grad(phi))

% Use eps(epsilon) to prevent division by zero
% Generally use 1e-4 ~ 1e-8 at deep learning. So I use 1e-8 in this assignment.
eps = 1e-8;

% --------------------------------------------------------------------
% 좀 더 정확한 구현
% --------------------------------------------------------------------

[phi_dxx, phi_dyy] = second_derivative(phi_in);
phi_dxy = cross_second_derivative(phi_in);
div = (phi_dxx.*(phi_dy.^2) - phi_dx.*phi_dy.*phi_dxy + phi_dyy.*(phi_dy.^2)) ./ (dPhi.^3 + eps);
kappa = div; % curvature

% ---------------------------------------------------------------------
% 간단한 구현
% --------------------------------------------------------------------

% normalize_phi = (phi_dx + phi_dy)./(dPhi+eps);
% [divergence_x, divergence_y] = sobel_filter(normalize_phi);
% kappa =  divergence_x + divergence_y; % curvature

% --------------------------------------------------------------------

smoothness = g.*kappa.*dPhi;
expand = c*g.*dPhi;

phi_out = phi_out + timestep*(expand + smoothness);

% Sobel filter for derivative
function [dx, dy] = sobel_filter(input)
% Get size
dimX = size(input,1);
dimY = size(input,2);
% Initalize
dx = zeros(dimX,dimY);
dy = zeros(dimX,dimY);

% Calculate
for x=2:dimX-1
    for y=2:dimY-1
        dx(x,y) = (input(x+1, y-1) + 2*input(x+1, y) + input(x+1, y+1) - (input(x-1, y-1) + 2*input(x-1, y) + input(x-1, y+1)))./9;
        dy(x,y) = ((input(x-1, y+1) + 2*input(x, y+1) + input(x+1, y+1)) - (input(x-1, y-1) + 2*input(x, y-1) + input(x+1, y-1)))./9;
    end
end

function [dxx, dyy] = second_derivative(input)
% Get size
dimX = size(input,1);
dimY = size(input,2);
% Initalize
dxx = zeros(dimX,dimY);
dyy = zeros(dimX,dimY);
% Calculate
for x=2:dimX-1
    for y=2:dimY-1
        dxx(x,y) = (input(x+1, y) - 2*input(x, y) + input(x-1, y))/4;
        dyy(x,y) = (input(x, y+1) - 2*input(x, y) + input(x, y-1))/4;
    end
end

function [dxy] = cross_second_derivative(input)
% Get size
dimX = size(input,1);
dimY = size(input,2);
% Initalize
dxy = zeros(dimX,dimY);
% Calculate
for x=2:dimX-1
    for y=2:dimY-1
        dxy(x,y) = (input(x+1, y-1) - input(x+1, y+1) - input(x-1, y-1) + input(x-1, y+1))/4;
    end
end