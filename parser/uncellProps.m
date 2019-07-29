% this function merely replaces cells with their contents in the properties
% of a variable; if propNames is specified as a list of properties, such as
% {'prop1', 'prop2'} then it modifies only these props if needed

function props = uncellProps(props, propNames)

if (~exist('propNames', 'var'))
    propNames = fieldnames(props)
end

for i = 1 : numel(propNames)
    val = props.(propNames{i});
    if (iscell(val))
        val = val{1};
    end
    props.(propNames{i}) = val;
end

end