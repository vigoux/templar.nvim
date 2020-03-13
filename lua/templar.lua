-- in templar.lua

local api = vim.api

local function parse_field(field, values)
	if string.match(field, '^%d+$') then
		value = values[tonumber(field)]
	else
		value = vim.fn.eval(field)
		values[#values] = value
	end

	return value
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
		tag = vim.fn.matchstr(line, '%{\\zs.\\+\\ze}')
		
		if not tag or tag:len() == 0 then
			evaluated[index] = line
		elseif tag == 'CURSOR' then
			future_cursor = {actual_cursor[1] + index - 1, 0}
			evaluated[index] = line:gsub('%%{.+}', '')
		elseif tag:match('INCLUDE %g+') then
			-- Special INCLUDE tag
			-- Includes the content of a templte into current
			fname = vim.fn.matchstr(tag, 'INCLUDE \\zs\\f*\\ze')
			path = vim.fn.fnamemodify(filename, ':p:h') .. '/' .. fname
			print(path)

			_, output = parse_template(path)

			print(vim.inspect(evaluated))
			vim.list_extend(evaluated, output)
			print(vim.inspect(evaluated))
		else
			evaluated[index] = line:gsub('%%{.+}', parse_field(tag, values))
		end
	end
	future_cursor = future_cursor or actual_cursor
	return future_cursor, evaluated
end

local function use_template(file)
	cursor, lines = parse_template(file)
	api.nvim_buf_set_lines(0, 0, -1, false, lines)
	api.nvim_win_set_cursor(0, cursor)
end

-- searches the correct template for the current file
local function search_template()
	local extension = vim.fn.expand('%:e')

	local files = api.nvim_call_function('globpath',
		{ table.concat(api.nvim_list_runtime_paths(), ','), 'templates/template.' .. extension, false, true }
	)

	return files[1]
end

local function source()
	local template_file = search_template()

	if template_file then
		use_template(template_file)
	end
end

-- registers a new file extension to use the template with
local function register(extension)
	api.nvim_command(string.format("autocmd Templar BufNewFile %s lua require'templar'.source()", extension))
end

return {
	source=source,
	register=register
}
