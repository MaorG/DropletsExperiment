function disk = getDisk(radius)
dx = -radius:radius;
dy = -radius:radius;
[DX, DY] = meshgrid(dx,dy);
disk = (DX.*DX)+(DY.*DY) <= radius*radius;
end