function savePolygon(filename, Polyg)
    f = fopen(filename, 'w');
    for i=1:5
        polyg = Polyg{i};
        for j=1:size(Polyg{i},1)
            fprintf(f, '%f %f ',polyg(j,1), polyg(j,2));
        end
        fprintf(f,'\n');
    end
    fclose(f);
end