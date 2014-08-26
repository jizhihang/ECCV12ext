function poly = readPoly(file)
    fid = fopen(file, 'r');
     
    poly = cell(1, 5);
    line = fgetl(fid);
    i = 0;
    while ischar(line)  
        i = i + 1;
        if ~isempty(line)
            xy = textscan(line, '%f');
            x = xy{1}(1 : 2 : end);
            y = xy{1}(2 : 2 : end);              

            poly{i} = [x y];
        end
        
        line = fgetl(fid);
    end
    
    assert(i == 5);
end