%
% Skeleton code for COSE490 Fall 2022 Assignment 4
%
% Won-Ki Jeong (wkjeong@korea.ac.kr)
%

clear all;
close all;

%
% Loading input image
%
I=imread('building-600by600.tif');
% I=imread('checkerboard-noisy2.tif');
% I=imread('church.jpeg');
Img=double(I(:,:,1));

%
% ToDo: Compute R
%

sobelX = [-1,0,1; -2,0,2; -1,0,1];
sobelY = [1,2,1; 0,0,0; -1,-2,-1];

Ix = conv2(Img, sobelX, 'same');
Iy = conv2(Img, sobelY, 'same');

h = fspecial('gaussian',7,2.0);

Ix2 = conv2(Ix.^2, h, 'same');
Iy2 = conv2(Iy.^2, h, 'same');
Ixy = conv2(Ix.*Iy, h, 'same');

det = Ix2.*Iy2 - Ixy.^2;
trace = Ix2 + Iy2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% k는 sensitivity factor로 이미지에 따라 적절한 값으로 설정
k = 0.04;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R = det - k*(trace.^2);     % R value 구함

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 이미지 전체로 봤을 때 맨 끝의 4개 corners는 
% 이미지 내의 feature가 아니기 때문에 R value를 0으로 설정
[dimX, dimY] = size(R); 

R(1:4, 1:4) = 0;
R(1:4, dimY-3:dimY) = 0;
R(dimX-3:dimX, 1:4) = 0;
R(dimX-3:dimX, dimY-3:dimY) = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Example of collecting points and plot them
%
% (10,1), (15,2), (20,3)
%

% location = [10 15 20; 1 2 3]'
% points = cornerPoints(location);
% plot(points)


%
% ToDo: Visualize R values using jet colormap
%

% R value를 visualize 하고싶다면 true
% Corner points를 visualize 하고싶다면 false
visualization_R = false;

if visualization_R
    imshow(R);
    colormap("jet");
    clim("auto");
    colorbar;

%
% ToDo: Threshold R & Collect Local Maximum Points
%
else
    [dimX, dimY] = size(R); 
    location=[];    % Corner points를 넣을 배열
    window = 10;    % Local patch의 window size
    sz = [window window];   % Local patch의 2D size
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    threshold=0.1e+9;   % 이미지 별로 적절한 threshold 값 사용
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    x_cnt = window;     % Local patch를 구하기 위한 변수
    y_cnt = window;     % Local patch를 구하기 위한 변수

    for x=1:dimX
        % Window size에 따른 local patch를 구하는 코드
        if(x_cnt < window)
            x_cnt = x_cnt+1;
            continue
        end
        x_cnt=1;

        for y=1:dimY
            % Window size에 따른 local patch를 구하는 코드
            if(y_cnt < window)
                y_cnt = y_cnt+1;
                continue
            end
            y_cnt=1;

            % Boundary index error 처리
            % Local patch를 구하는 코드
            if x+(window-1) > dimX 
                local=R(x:dimX, y:y+(window-1));
            elseif  y+(window-1) > dimY
                local=R(x:x+(window-1), y:dimY);
            else
                local=R(x:x+(window-1), y:y+(window-1));
            end 

            % Local maxima
            [local_maxima, max_index]=max(local(:));

            % 앞서 설정한 threshold 보다 local maxima가 더 높을 때 corner point로 넣음
            if local_maxima >= threshold
                [r, c] = ind2sub(sz,max_index);     % 1D index -> 2D index
                location=[location; y+c-1, x+r-1];  % Push corner point
            end
        end
    end
     
    points= cornerPoints(location);

%
% Visualize corner points over the input image
%

    imshow(I)
    
    hold on
    
    plot(points)
    
    hold off
end
