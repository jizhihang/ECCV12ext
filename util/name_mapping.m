function name_mapping = name_mapping()

fid = fopen('../dataset/namechange');
name_mapping = textscan(fid, '%s%s');
fclose(fid);

end