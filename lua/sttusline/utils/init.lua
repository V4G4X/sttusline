local color_utils = require("sttusline.utils.color")
local M = {}

M.eval_func = function(func, ...)
	if type(func) == "function" then return func(...) end
end

M.eval_component_func = function(component, func_name, ...)
	local configs = type(component.configs) == "table" and component.configs or {}
	local override_colors = component.override_glob_colors or {}
	local space = nil

	if type(component.space) == "function" then
		space = component.space(configs, vim.tbl_deep_extend("force", color_utils, override_colors))
	elseif type(component.space) == "table" then
		space = component.space
	end

	return M.eval_func(
		component[func_name],
		configs,
		vim.tbl_deep_extend("force", color_utils, override_colors),
		space,
		...
	)
end

M.add_padding = function(str, value)
	if #str == 0 then return str end
	value = value or 1

	if type(value) == "number" then
		if value <= 0 then return str end
		local padding = (" "):rep(value)

		local startpos = str:find([[#([^#%%]+)%%%*]])
		if not startpos then return padding .. str .. padding end

		return str:sub(1, startpos) .. padding .. str:sub(startpos + 1, #str - 2) .. padding .. "%*"
	elseif type(value) == "table" then
		local left_padding = type(value.left) == "number" and value.left >= 0 and (" "):rep(value.left)
			or " "
		local right_padding = type(value.right) == "number" and value.left >= 0 and (" "):rep(value.right)
			or " "

		local startpos = str:find([[#([^#%%]+)%%%*]])
		if not startpos then return left_padding .. str .. right_padding end
		return str:sub(1, startpos)
			.. left_padding
			.. str:sub(startpos + 1, #str - 2)
			.. right_padding
			.. "%*"
	end
end

M.add_highlight_name = function(str, highlight_name)
	vim.validate { str = { str, "string" }, highlight_name = { highlight_name, "string" } }
	return "%#" .. highlight_name .. "#" .. str .. "%*"
end

M.is_color = function(color) return type(color) == "string" and color:match("^#%x%x%x%x%x%x$") end

M.is_disabled = function(opts)
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	local buftype = vim.api.nvim_buf_get_option(0, "buftype")
	if
		vim.tbl_contains(opts.disabled.filetypes or {}, filetype)
		or vim.tbl_contains(opts.disabled.buftypes or {}, buftype)
	then
		return true
	end
	return false
end

return M
