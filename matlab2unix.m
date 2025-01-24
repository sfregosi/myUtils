function tu = matlab2unix(tm)
    tu = round(86400 * (tm - datenum('1970', 'yyyy')));
end