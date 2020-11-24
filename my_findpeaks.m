function [pks,locs] = my_findpeaks(X)      
    M = numel(X);
    pks = [];
    locs = [];
    if (M < 4)
        datamsgid = generatemsgid('emptyDataSet');
        error(datamsgid,'Data set must contain at least 4 samples.');
    else
        for idx=1:M-3
            if X(idx)< X(idx+1) && X(idx+1)>=X(idx+2) && X(idx+2)> X(idx+3)
                pks = [pks X(idx)];
                locs = [locs idx];
            end

        end

    end
end