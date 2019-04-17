function which_sig = Holm_Bonferroni(dFsig,alpha)

if nargin<2
    alpha = 0.05;
end

m = size(dFsig,2);
[sortlist,idx] = sort(dFsig);

i = 0;
result  = 0;
num_comparisons = length(sortlist);

while result <1
    i = i+1;
    if i<=num_comparisons
        result = HB_comparison(sortlist(i),alpha,m,i);
    else
        break
    end
    which_sig = idx(1:i-1);
end

    function result = HB_comparison(pvalue,alpha,m,k)
        result=pvalue>(alpha/(m+1-k));
    end
end