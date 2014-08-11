function M = getLabelMatrix(polyg,w,h)
    M = zeros(h,w);
    for i=1:numel(polyg)
        if numel(polyg{i}) > 0
            M = M + i .* poly2mask(polyg{i}(:,1),polyg{i}(:,2),h,w);
        end
    end
end