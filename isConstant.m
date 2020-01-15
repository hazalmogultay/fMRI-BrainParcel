function returnval = isConstant(X)
    firstval = X(1);
    for i = 2:length(X)
        if X(i)~= firstval
            returnval = 1;
            return
        end
    end
 returnval = 0;
 return


end