function accuracy = evalScore(map, poly)
    accuracy = 0;
    n = size(map{1}, 1);
    for i = 1 : n
        gt = imread(sprintf('../dataset/gt/%s.png', map{1}{i}));
        
        [h, w] = size(gt);
        layout = getLayout(poly{i}, w, h);
        
        I = double(gt ~= 0);
        match = (layout == gt) .* I;
        acc = length(find(match)) / length(find(I));
        
        check_swap = 0;
        if isempty(poly{i}{3}) && ~isempty(poly{i}{4})
            p = poly{i};
            p{3} = poly{i}{2};
            p{2} = poly{i}{4};
            p{4} = [];
            check_swap = 1;
        elseif isempty(poly{i}{4}) && ~isempty(poly{i}{3})
            p = poly{i};
            p{4} = poly{i}{2};
            p{2} = poly{i}{3};
            p{3} = [];
            check_swap = 1;
        end
            
        if check_swap
            l = getLayout(p, w, h);
            m = (l == gt) .* I;
            a = length(find(m)) / length(find(I));
            if a > acc
                acc = a;
                match = m;
                layout = l;                
            end
        end
                        
        if ~isempty(poly{i}{4}) && ~isempty(poly{i}{3}) && ~isempty(poly{i}{2})
            % Try to switch gt
            check_swap = 0;
            gt3 = isempty(find(gt == 3, 1));
            gt4 = isempty(find(gt == 4, 1));
            if gt3 && ~gt4
                g = gt;
                g(gt == 2) = 3;
                g(gt == 4) = 2;
                check_swap = 1;
            elseif gt4 && ~gt3
                g = gt;
                g(gt == 2) = 4;
                g(gt == 3) = 2;
                check_swap = 1;
            end
            
            if check_swap
                m = (layout == g) .* I;
                a = length(find(m)) / length(find(I));
                if a > acc
                    gt = g;
                    acc = a;
                    match = m;               
                end
            end
        end               

        accuracy = accuracy + acc;
        
%         figure(1)
%         imagesc(double(gt) + (double(gt == 0) * 6)); caxis([1, 6]);
%         figure(2)
%         imagesc(layout); caxis([1, 6]);
%         figure(3)
%         imagesc(match);
%         pause
    end    
    
    accuracy = accuracy / n;
end