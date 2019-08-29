function props = customParametrizeToProps(viewOrderAll, props, dataParams)

% make a copy to make modificiations on propsCopy but read from props, so
% that if there are multiple instances of viewOrder and a repitition on
% some property, the override will be according to the original
propsCopy = props;

for v = 1 : numel(viewOrderAll)
    viewOrder = viewOrderAll{v};
    
    % example for viewOrder parameter that changes plotting style for different plots:
    % 'viewOrder' {{'time' 'well'} {'style' 'color' 'LineWidth'} {{0 2} {1 2} {2 3}}} 'style' {'-' '--' '-.'} 'color' {[18/255 110/255 20/255] 'r' 'k'} 'LineWidth' 3
    % ///above is the syntax that is used to apply this for parametrization,
    % the input for the current function is only the cell part of {{'time' 'well'} {'style' 'color' 'LineWidth'} {{0 2} {1 2} {2 3}}}
    % - as a cell it should be added to viewOrderAll for each 'viewOrder'
    % parameter, like this: 
    %    elseif (strcmpi(v{i}, 'viewOrder'))
    %    viewOrderAll = [viewOrderAll, {v{i+1}}];
    % and then viewOrderAll is passed to this function along with the
    % default props and the data parameters///
    % the above uses the 'time' and 'well' properties designated by {0 2},
    % {1 2} and {2 3} (in that order) and chooses the style properties
    % specified by 'style', 'color' and 'LineWidth' by the index that
    % corresponds to that matched by the current plot properties of
    % 'time' and 'well'; LineWidth will stay 3 because there is one
    % option only
    % note: there can be multiple 'viewOrder' for different style
    % properties that use different 'time' and 'well' properties, etc.
    % dataParams - this is the specifications for the current well, etc. to
    % know the order the current calling function should be using
    
    if (~isempty(viewOrder) && exist('dataParams', 'var'))
        dataParamsNames = viewOrder{1};
        dataParamsOpts = viewOrder{3};
        propsToChange = viewOrder{2};
        isCurParamsEq = zeros(numel(dataParamsOpts), numel(dataParamsOpts{1}));
        for i = 1 : numel(dataParamsNames)
            parName = dataParamsNames{i};
            if (isfield(dataParams, parName))
                curParam = dataParams.(parName);
                for ii = 1 : numel(dataParamsOpts)
                    specParam = dataParamsOpts{ii}{i};
                    isEq = 0;
                    if (isnumeric(curParam))
                        isEq = curParam == specParam;
                    else
                        isEq = strcmp(curParam, specParam);
                    end
                    isCurParamsEq(ii, i) = any(isEq);
                end
                
            end
        end
        
        pos = [];
        isCurParamsEq = all(isCurParamsEq, 2);
        posCurParamsEq = find(isCurParamsEq);
        pos = posCurParamsEq(1);
        if (~isempty(pos))
            for i = 1 : numel(propsToChange)
                curProp = propsToChange{i};
                if (isfield(props, curProp))
                    curPropVal = props.(curProp);
                    if (iscell(curPropVal))
                        if (pos <= numel(curPropVal))
                            curPropVal = curPropVal{pos};
                        else
                            curPropVal = curPropVal{1};
                        end
                    end
                    propsCopy.(curProp) = curPropVal;
                end
            end
        end
        
    end

end

props = propsCopy;

end