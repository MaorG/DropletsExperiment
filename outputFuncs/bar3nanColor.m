function [ h ] = bar3nanColor( z, c )


h = bar3(z);
for i = 1:numel(h)
  index = logical(kron(-Inf ==(z(:,i)),ones(6,1)));
  zData = get(h(i),'ZData');
  zData(index,:) = nan;
  set(h(i),'ZData',zData);
end

for k = 1:length(h)
    zdata = h(k).ZData;
    crow = c(:,k);
    cdata = zeros(6*numel(crow),4);
    for i = 1:numel(crow)
       cdata((6*i - 5):(6*i),:) = crow(i); 
    end
    h(k).CData = cdata;
    %h(k).FaceColor = 'interp';
end

end