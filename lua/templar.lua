-- in templar.lua

local api = vim.api
local templates = {}

local function parse_field(field, values)
	local value
	if string.match(field, '^%d+$') then
		value = values[tonumber(field)]
	else
		value = vim.fn.eval(field)
		values[#values] = value
	end

	return value
end

local function debug_print(...)
  if vim.g.templar_debug_print == 1 then
    print(...)
  end
end

local function parse_template(file)
	-- Get content of the template
	local filename = vim.fn.expand(file)
	local lines = vim.fn.readfile(filename)

	-- Content of the future file
	local evaluated = {}
	local actual_cursor = api.nvim_win_get_cursor(0)
	local future_cursor = nil
	local values = {}

	for index, line in ipairs(lines) do
		local tag = vim.fn.matchstr(line, '%{\\zs.\\+\\ze}')

		if not tag or tag:len() == 0 then
			evaluated[index] = line
		elseif tag == 'CURSOR' then
			future_cursor = {actual_cursor[1] + index - 1, line:find("CURSOR") - 3}
			evaluated[index] = line:gsub('%%{.+}', '')
		elseif tag:match('INCLUDE %g+') then
			-- Special INCLUDE tag
			-- Includes the content of a templte into current
			local fname = vim.fn.matchstr(tag, 'INCLUDE \\zs\\f*\\ze')
			local path = vim.fn.fnamemodify(filename, ':p:h') .. '/' .. fname
			debug_print(path)

			local _, output = parse_template(path)

			debug_print(vim.inspect(evaluated))
			vim.list_extend(evaluated, output)
			debug_print(vim.inspect(evaluated))
		else
			evaluated[index] = line:gsub('%%{.+}', parse_field(tag, values))
		end
	end
	future_cursor = future_cursor or actual_cursor
	return future_cursor, evaluated
end

local function use_template(file)
	local cursor, lines = parse_template(file)
	api.nvim_buf_set_lines(0, 0, -1, false, lines)
	api.nvim_win_set_cursor(0, cursor)
end

-- searches the correct template for the current file
local function search_template()
	local curfile = vim.fn.expand('%:p')

    for fname, temppath in pairs(templates) do
        debug_print(fname, temppath)
        if curfile:find(fname) ~= nil then
            local files = api.nvim_get_runtime_file(temppath, false)
            return files[1]
        end
    end

	return nil
end

local function source()
	local template_file = search_template()

	if template_file then
		use_template(template_file)
	end
end

-- registers a new file extension to use the template with
local function register(filename, alias)
    -- Generate template path from filename or alias
    -- This is basically replacing each * in the filename by template
    -- If alias is provided it is appended with extension from filename
    local fileroot = alias or string.gsub(vim.fn.fnamemodify(filename,':r'), "%*", "template")
    local temppath = 'templates/' .. fileroot .. '.' .. vim.fn.fnamemodify(filename, ':e')
    local fname_regex = string.gsub(filename, "%*", ".*") .. "$"
    templates[fname_regex] = temppath
end

return {
	source=source,
	register=register
}
