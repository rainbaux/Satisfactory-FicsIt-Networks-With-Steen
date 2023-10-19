package = {
	path = { "/lib" },
	loaded = {},
	preload = {},
}

---@param modelname string
---@return any
function require(modelname)
	if package.loaded[modelname] then
		return package.loaded[modelname]
	end

	local searched_paths = {}
	if string.find(modelname, ".+/.+%.lua") then
		if filesystem.isFile(modelname) == true then
			package.loaded[modelname] = filesystem.loadFile(modelname)()
			return package.loaded[modelname]
		end

		error(string.format("Module '%s' not found!", modelname))
	end

	local module_path = modelname:gsub("\\.", "/")
	for _, v in ipairs(package.path) do
		local file = string.format("%s/%s.lua", v, module_path)
		if filesystem.isFile(file) == true then
			package.loaded[modelname] = filesystem.loadFile(file)()
			return package.loaded[modelname]
		end

		table.insert(searched_paths, file)

		local mod = string.format("%s/%s/init.lua", v, module_path)
		if filesystem.isFile(mod) == true then
			package.loaded[modelname] = filesystem.loadFile(mod)()
			return package.loaded[modelname]
		end

		table.insert(searched_paths, mod)
	end

	local cwd = debug.getinfo(2, "S").source
	if string.find(cwd, "@") then
		cwd = string.sub(cwd, 2)
	else
		cwd = "."
	end

	local file = string.format("%s/%s.lua", cwd, module_path)
	if filesystem.isFile(file) == true then
		package.loaded[modelname] = filesystem.loadFile(file)
		return package.loaded[modelname]
	end

	table.insert(searched_paths, file)

	local mod = string.format("%s/init.lua", cwd, module_path)
	if filesystem.isFile(mod) == true then
		package.loaded[modelname] = filesystem.loadFile(mod)
		return package.loaded[modelname]
	end

	table.insert(searched_paths, file)

	local msg_fmt = "Module '%s' not found! Searched paths:\n%s"
	local file_msg = ""
	for _, v in ipairs(searched_paths) do
		file_msg = file_msg .. string.format("No file! '%s'\n", v)
	end

	local error_msg = string.format(msg_fmt, modelname, modelname) .. file_msg
	error(error_msg)
end
