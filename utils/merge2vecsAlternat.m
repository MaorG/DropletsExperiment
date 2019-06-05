function mergedVecs = merge2vecsAlternat(vec1, vec2)

% make vectors vertical
vec1 = vec1(:); 
vec2 = vec2(:);

vecs = [vec1, vec2];

mergedVecs = reshape(vecs', 1, numel(vecs));


end
