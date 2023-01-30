function output = myAHE(input, numtiles)

dimX = size(input,1);
dimY = size(input,2);

output = uint8(zeros(dimX,dimY));

% ToDo
tileX=numtiles(1);
tileY=numtiles(2);
cdfs=zeros(256, tileX, tileY);
S=zeros(256, tileX, tileY);
spaceTileX=ceil(dimX/tileX);
spaceTileY=ceil(dimY/tileY);
spaceLastX=dimX - (tileX-1) * spaceTileX;
spaceLastY=dimY - (tileY-1) * spaceTileY;

for i=1:tileX
    for j=1:tileY
        if i==tileX && j==tileY
            cdfs(:,i,j)=myCDF(input((i-1) *spaceTileX + 1 : dimX, (j-1)*spaceTileY + 1 : dimY));
        elseif i==tileX && j~=tileY
            cdfs(:,i,j)=myCDF(input((i-1) *spaceTileX + 1 : dimX, (j-1)*spaceTileY + 1 : j*spaceTileY));
        elseif i~=tileX && j==tileY
            cdfs(:,i,j)=myCDF(input((i-1) *spaceTileX + 1 : i*spaceTileX, (j-1)*spaceTileY + 1 : dimY));
        else 
            cdfs(:,i,j)=myCDF(input((i-1) *spaceTileX + 1 : i*spaceTileX, (j-1)*spaceTileY + 1 : j*spaceTileY));
        end
        for k=1:256
            S(k,i,j)=255*cdfs(k,i,j);
        end         
    end
end

for x = 1:dimX
    for y = 1:dimY
        tX=floor((x-1)/spaceTileX)+1;    
        tY=floor((y-1)/spaceTileY)+1;

        if tX == tileX
            mX=mod((x-1) - (tileX-1) * spaceTileX, spaceLastX);
            spaceX=spaceLastX;
        else
            mX=mod((x-1), spaceTileX);
            spaceX=spaceTileX;
        end

        if tY == tileY
            mY=mod((y-1) - (tileY-1) * spaceTileY, spaceLastY);
            spaceY=spaceLastY;
        else
            mY=mod((y-1), spaceTileY);
            spaceY=spaceTileY;
        end
        mX=mX+1;
        mY=mY+1;

        if (tX==1) && (tY==1) && (mX <= (spaceX/2)) && (mY <= (spaceY/2)) 
                output(x, y)=S(input(x, y)+1, tX,tY);
        elseif (tX==tileX) && (tY==1) && (mX > (spaceX/2)) && (mY <= (spaceY/2))
                output(x, y)=S(input(x, y)+1, tX,tY);
        elseif (tX==1) && (tY==tileY) && (mX <= (spaceX/2)) && (mY > (spaceY/2))
                output(x, y)=S(input(x, y)+1, tX,tY);
        elseif (tX==tileX) && (tY==tileY) && (mX > (spaceX/2)) && (mY > (spaceY/2))
                output(x, y)=S(input(x, y)+1, tX,tY);
        
        elseif ((tY==1) && (mY <= (spaceY/2))) || ((tY==tileY) && (mY > (spaceY/2)))
            if mX <= (spaceX/2)
                leftRatio=(mX + floor(spaceX/2)) / spaceX;
                rightRatio=(floor(spaceX/2) - mX) / spaceX;
                output(x, y)=rightRatio * S(input(x, y)+1, tX-1, tY) + leftRatio * S(input(x, y)+1, tX, tY);
            else
                leftRatio=(floor(spaceX/2) - (spaceX - mX)) / spaceX;
                rightRatio=((spaceX - mX) + floor(spaceX/2)) / spaceX;
                output(x, y)=rightRatio * S(input(x, y)+1, tX, tY) + leftRatio * S(input(x, y)+1, tX+1, tY);
            end
          
        elseif ((tX==1) && (mX <= (spaceX/2))) || ((tX==tileX) && (mX > (spaceX/2)))
            if mY <= (spaceY/2)
                topRatio=(mY + floor(spaceY/2)) / spaceY;
                downRatio=(floor(spaceY/2) - mY) / spaceY;
                output(x, y)=downRatio * S(input(x, y)+1, tX, tY-1) + topRatio * S(input(x, y)+1, tX, tY);
            else
                topRatio=(floor(spaceY/2) - (spaceY - mY)) / spaceY;
                downRatio=((spaceY - mY) + floor(spaceY/2)) / spaceY;
                output(x, y)=downRatio * S(input(x, y)+1, tX, tY) + topRatio * S(input(x, y)+1, tX, tY+1);
            end

        elseif (mX <= (spaceX/2)) && (mY <= (spaceY/2))
            topRatio = (mY + floor(spaceY/2)) / spaceY;
            downRatio = (floor(spaceY/2) - mY) / spaceY;
            leftRatio = (mX + floor(spaceX/2)) / spaceX;
            rightRatio = (floor(spaceX/2) - mX) / spaceX;
            output(x, y) = downRatio * ((rightRatio * S(input(x, y)+1, tX-1, tY-1)) + (leftRatio * S(input(x, y)+1, tX, tY-1))) + topRatio * ((rightRatio * S(input(x, y)+1, tX-1, tY)) + (leftRatio * S(input(x, y)+1, tX, tY)));

        elseif (mX > (spaceX/2)) && (mY <= (spaceY/2))
            topRatio = (mY + floor(spaceY/2)) / spaceY;
            downRatio = (floor(spaceY/2) - mY) / spaceY;
            leftRatio = (floor(spaceX/2) - (spaceX - mX)) / spaceX;
            rightRatio = ((spaceX - mX) + floor(spaceX/2)) / spaceX;
            output(x, y) = downRatio * ((rightRatio * S(input(x, y)+1, tX, tY-1)) + (leftRatio * S(input(x, y)+1, tX+1, tY-1))) + topRatio * ((rightRatio * S(input(x, y)+1, tX, tY)) + (leftRatio * S(input(x, y)+1, tX+1, tY)));

        elseif (mX <= (spaceX/2)) && (mY > (spaceY/2))
            topRatio = (floor(spaceY/2) - (spaceY - mY)) / spaceY;
            downRatio = ((spaceY - mY) + floor(spaceY/2)) / spaceY;
            leftRatio = (mX + floor(spaceX/2)) / spaceX;
            rightRatio = (floor(spaceX/2) - mX) / spaceX;
            output(x, y) = downRatio * ((rightRatio * S(input(x, y)+1, tX-1, tY)) + (leftRatio * S(input(x, y)+1, tX, tY))) + topRatio * ((rightRatio * S(input(x, y)+1, tX-1, tY+1)) + (leftRatio * S(input(x, y)+1, tX, tY+1)));
                
        else
            topRatio = (floor(spaceY/2) - (spaceY - mY)) / spaceY;
            downRatio = ((spaceY - mY) + floor(spaceY/2)) / spaceY;
            leftRatio = (floor(spaceX/2) - (spaceX - mX)) / spaceX;
            rightRatio = ((spaceX - mX) + floor(spaceX/2)) / spaceX;
            output(x, y) = downRatio * ((rightRatio * S(input(x, y)+1, tX, tY)) + (leftRatio * S(input(x, y)+1, tX+1, tY))) + topRatio * ((rightRatio * S(input(x, y)+1, tX, tY+1)) + (leftRatio * S(input(x, y)+1, tX+1, tY+1)));
        end
    end
end
end