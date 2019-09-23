function source_used=calcu_sourceUsage(NNF,source_used)
source_used=zeros(size(source_used));
[m,n]=size(NNF(:,:,1));

for i=1:m
    for j=1:n
        source_used(NNF(i,j,1),NNF(i,j,2))=source_used(NNF(i,j,1),NNF(i,j,2))+1;

    
    end
end
end