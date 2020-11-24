function tu = matlab2unix(tm)
    tu = round(864e5 * (tm - datenum('1970', 'yyyy')));
end