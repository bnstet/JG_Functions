function new_order = sort_order(X)
%new_order = sort_order(X)
%   sort_order(X) returns index for re-ordering vectors in ascending order.
%
%   JG 2018

[~,idx] = sort(X);

for convert=1:length(X)
    new_order(convert) = find(idx == convert);
end