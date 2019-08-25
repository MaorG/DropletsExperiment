% main function run from prep

function res = imageRegistration(data,parameters)

props = parseParams(parameters);

src = props.src;


end


function props = parseParams(v)
% default:
props = struct(...
    'src','regPoints'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};     
    end
    
end

end
