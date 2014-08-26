function accuracy = evalScore(map, poly)
    accuracy = 0;
    n = size(map{1}, 1);
    nvalid = 0;
    for i = 1 : n
        if isempty(poly{i})
            continue;
        end
        nvalid = nvalid + 1;
        
        img = imread(sprintf('../dataset/images/%s.jpg', map{1}{i}));
        gt = imread(sprintf('../dataset/gt/%s.png', map{1}{i}));
        
        [h, w, d] = size(img);
        [gth, gtw] = size(gt);
        layout = imresize(getLayout(poly{i}, w, h), [gth gtw], 'nearest');
        
        I = double(gt >= 1 & gt <= 5);
        nvalidgt = length(find(I));
        match = (layout == gt) .* I;
        acc = length(find(match)) / nvalidgt;
               
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
            l = imresize(getLayout(p, w, h), [gth gtw], 'nearest');
            m = (l == gt) .* I;
            a = length(find(m)) / nvalidgt;
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
                a = length(find(m)) / nvalidgt;
                if a > acc
                    gt = g;
                    acc = a;
                    match = m;               
                end
            end
        end               

        accuracy = accuracy + acc;
%         fprintf('%s %0.2f\n', map{1}{i}, acc * 100);

%         figure(1);
%         imagesc(double(gt) + (double(gt == 0) * 6)); caxis([1, 6]);
%         figure(2);
%         imagesc(layout); caxis([1, 6]);
%         figure(3);
%         imagesc(match);
%         pause
    end    
    
    accuracy = accuracy / nvalid;
end