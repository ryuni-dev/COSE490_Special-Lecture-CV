input_file_names = {'cat-halftone.png', 'text-sineshade.tif', 'saturn-rings-sinusoidal-interf.tif'};

for file_idx=1:3
    input=imread(string(input_file_names(file_idx)));
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
    H = ones(PQ(1), PQ(2));
    
    % 이미지의 중심 좌표 저장
    centerP = PQ(1)/2;
    centerQ = PQ(2)/2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % cat-halfone notches...
    if file_idx==1
        D0=30;
        n=4;
        notch_x=[212, -212, -259, 0, 266, -266, 44, -44, 211, 211];
        notch_y=[319, 319, 0, 387, 387, 387, 320, 320, 63, -63];
    
    % text-sineshade notches...        
    elseif file_idx==2
        D0=5;
        n=4;
        notch_x=[0];
        notch_y=[14.5];

    % saturn-rings-sinusoidal-interf notches...
    % 마지막 이미지는 상당한 시간이 소요됩니다.
    elseif file_idx==3
        D0=3;
        n=2;
        idx = 1;
        for i=45:6776
            notch_x(idx)=i;
            notch_y(idx)=0;
            idx = idx +1;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Q = length(notch_x);
    
    for x=1:PQ(1)
        for y=1:PQ(2)
            for k=1:Q
                u=notch_x(k);
                v=notch_y(k);
                D_1= sqrt((x-centerP-u)^2 + (y-centerQ-v)^2);
                D_2= sqrt((x-centerP+u)^2 + (y-centerQ+v)^2);
                H1=1/(1+(D0/D_1)^(2*n));
                H2=1/(1+(D0/D_2)^(2*n));
                if k == 1
                    H(x,y)=H1*H2;
                else
                    H(x,y)=H(x,y)*H1*H2;
                end
            end
        end
    end
    
    G=G.*H;
    
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
end