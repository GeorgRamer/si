si_prefix = {Q = "Q", R = "R", Y = "Y", Z="Z", E = "E", P="P", T="T", G="G", M="M", k="k", h="h", d="d", c="c", m="m", u="\u{03BC}",  n="n", p="p", f="f", a="a", z="z", y="y", r="r", q="q"}

si_units = {m="m", l="l", L="L", g="g", V="V", A="A", ohm="\u{03A9}", ang="\u{212B}"}

space = "\u{202F}"

function merge(a, b)
    if type(a) == 'table' and type(b) == 'table' then
        for k,v in pairs(b) do if type(v)=='table' and type(a[k] or false)=='table' then merge(a[k],v) else a[k]=v end end
    end
    return a
end




return {
  ['si'] = function(args, kwargs, meta) 
    outtab = {}
    for idx, arg in ipairs(args) do
		print(arg)
    	if idx == 1 then
			exponent_start = string.find(arg, "[eE][-]?%d+")
			if exponent_start then
				exponent = string.sub(arg, exponent_start+1)
				arg = string.sub(arg,0, exponent_start-1)
			end 
    		outtab = {arg}
			if exponent_start ~= nil then
				table.insert(outtab, space.."\u{2715}"..space .."10")
				table.insert(outtab, pandoc.Superscript(exponent))
			end
		elseif arg == "." then 
			
			table.insert(outtab, "\u{2219}" )
		else
    	-- check for exponent and remove
    	
    		exponent_start = string.find(arg, "[-]?%d+$")
    		exponent = nil
    		if exponent_start then
    			exponent = pandoc.Superscript(string.sub(arg, exponent_start))
    			arg = string.sub(arg, 0, exponent_start-1)
    		end
    	-- if the remaining part is longer than one character, the first character may be a prefix
    	prefix=nil
    	if string.len(arg)>1 then

    		if si_prefix[string.sub(arg,0,1)] ~=nil and si_units[arg] == nil then
    			prefix = si_prefix[string.sub(arg,0,1) ]
    			arg = string.sub(arg,2)
    		end
    	end 
		print(prefix)
		print(arg)
		if si_units[arg] ~= nil then 
			arg = si_units[arg]
		end
		

    	table.insert(outtab, space )
    	table.insert(outtab, prefix )
		table.insert(outtab, arg )
		table.insert(outtab, exponent )
    	end

    end
	print(pandoc.Inlines(table.unpack(outtab)))
    return outtab
  end
}
