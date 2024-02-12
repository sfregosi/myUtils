function c1 = cat_cell(c1, c2)
% concatenate two cell arrays 'cause APPARENTLY THIS ISN'T EASY IN MATLAB
% originally found in Triton code. Extracted and added to myUtils 
% S. Fregosi 2021 08 11

for k = 1:size(c2, 2)
    c1{end+1} = c2{k};
end
end