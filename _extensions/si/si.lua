si_prefix = {Q = "Q", R = "R", Y = "Y", Z="Z", E = "E", P="P", T="T", G="G", M="M", k="k", h="h", d="d", c="c", m="m", u="\u{03BC}",  n="n", p="p", f="f", a="a", z="z", y="y", r="r", q="q"}

si_units = {m="m", l="l", L="L", g="g", V="V", A="A", ohm="\u{03A9}", ang="\u{212B}"}

SPACE = "\u{202F}"
TIMES = "\u{00D7}"
DOT = "\u{00B7}"


local function concatenateTables(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

function identify_block(arg)
	if arg == "." then
		return "DOT"
	end

	if arg == "x" then
		return "TIMES"
	end 


	if arg == "/" then
		return "SLASH"
	end 

	if string.match(arg, "^[a-zA-Z_°]+[-0-9]-$") then

		return "UNIT"
	end
	
	num_start = string.match(arg, "^[%d.,Eeij()+-°]+$")

	if num_start then
		return "NUMERIC"
	end

	

	return nil
end 


parsers = {}



function parse_numeric(arg)
	arg = string.gsub(arg, "%+%-", "\u{00B1}")
	-- add exponents
	outtab = {}
	while string.find(arg, "[eE][+-]?%d+") do
		idx_start, idx_stop = string.find(arg, "[eE][+-]?%d+")
		before_substr = string.sub(arg, 1, idx_start-1)..TIMES.."10"
		table.insert(outtab, before_substr)
		table.insert(outtab, pandoc.Superscript(string.sub(arg,idx_start+1,idx_stop)))
		arg = string.sub(arg, idx_stop+1)
	end
	if string.len(arg)>0 then
		table.insert(outtab, arg)
	end
	return outtab
end

parsers["NUMERIC"] = parse_numeric

function parse_dot(arg)

	return {DOT}

end
parsers["DOT"] = parse_dot

function parse_slash(arg)

	return {"/"}

end


parsers["SLASH"] = parse_slash


function parse_times(arg)
	return {TIMES}
end

parsers["TIMES"] = parse_times


function parse_unit(arg)

	-- check for exponent and remove

	exponent_start = string.find(arg, "%-?%d+$")
	exponent = nil
	if exponent_start then
		exponent = pandoc.Superscript(string.sub(arg, exponent_start))
		arg = string.sub(arg, 0, exponent_start-1)
	end

	-- there may be a subscript in the unit, check and remove
	subscript_start = string.find(arg, "_[a-zA-Z%d]+")

	subscript = nil
	if subscript_start then
		subscript = pandoc.Subscript(string.sub(arg, subscript_start+1))
		arg = string.sub(arg, 0, subscript_start-1)
	end

	-- if the remaining part is longer than one character, the first character may be a prefix
	prefix=nil
	if string.len(arg)>1 then

		if si_prefix[string.sub(arg,0,1)] ~=nil and si_units[arg] == nil then
			prefix = si_prefix[string.sub(arg,0,1) ]
			arg = string.sub(arg,2)
		end
	end 
	-- check whether the remaining part is a shortcut unit and replace 
	if si_units[arg] ~= nil then 
		arg = si_units[arg]
	end

	-- assemble
	outtab = {}

	if prefix then
	table.insert(outtab, prefix)
	end
	table.insert(outtab, arg)
	if subscript then
		table.insert(outtab, subscript)
	end
	if exponent then
		table.insert(outtab, exponent)

	end
	return outtab
end

parsers["UNIT"] = parse_unit


return {
  ['si'] = function(args, kwargs, meta) 
    outtab = {}
    for idx, arg in ipairs(args) do
    	block_type = identify_block(arg)

		if idx>1 then
			table.insert(outtab, SPACE)
		end
		if block_type then
			
			outtab=concatenateTables(outtab, parsers[block_type](arg))
		else
			table.insert(outtab, arg)
		end

	end

    return outtab
  end
}
