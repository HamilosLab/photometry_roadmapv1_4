function Matfile = findTaggedFile(Tag)
	filenames = {dir().name};
    filenames = filenames(3:end);
	CEDfile = contains(filenames, Tag);
    try
    	Matfile = matfile(filenames{CEDfile});
    catch
        if strcmpi(Tag, 'CED')
            CEDfile = contains(filenames, '.mat') & ~contains(filenames, 'training') & ~contains(filenames, 'MBI') & ~contains(filenames, 'ZigZagTimeWindows')& ~contains(filenames, 'sObj') & ~contains(filenames, 'exclusions') & ~contains(filenames, 'gfit') & ~contains(filenames, 'snpObj') & ~contains(filenames, 'STIMNPHOT') & ~contains(filenames, 'REVISED') & ~contains(filenames, 'SloshingModel') & ~contains(filenames, 'header');
            Matfile = matfile(filenames{CEDfile});
        end
    end
end