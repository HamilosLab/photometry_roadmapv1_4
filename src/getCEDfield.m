function [times, values] = getCEDfield(Matfile, varlist, fieldname)
	varlist = who(Matfile);
	field2load = varlist(contains(varlist,fieldname));
	s7s = Matfile.(field2load{:});
	times = s7s.times;

	if isfield(s7s, 'values')
		values = s7s.values;
	else
		values = 'Digital I/O';
	end
end