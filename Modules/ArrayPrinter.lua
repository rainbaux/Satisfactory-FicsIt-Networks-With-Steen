---@param div string @Divisor
---@param str string @String to be split
---@return string[]|boolean
function explode(div, str)
	if div == "" then
		return false
	end

	local arr = {}
	for match in (str .. div):gmatch("(.-)" .. div) do
		table.insert(arr, match)
	end

	return arr
end

---@param string string
---@param length number
---@param char string
---@return string
function lpad(string, length, char)
	char = char or " "
	return string.rep(char, length - #string) .. string
end

---@param string string
---@param length number
---@param char string
---@return string
function rpad(string, length, char)
	char = char or " "
	return string .. string.rep(char, length - #string)
end

---@param string string
---@param length number
---@param char string
---@return string
function pad(string, length, char)
	char = char or " "
	local leftPadding = math.floor((length - #string) / 2)
	local rightPadding = math.ceil((length - #string) / 2)
	return leftPadding .. string .. rightPadding
end

---@class OutputStream
local OutputStream = {}

---@class File
---@field close fun(self: File): boolean
---@field write fun(self: File, data: string): boolean

---@class FileOutputStream:OutputStream
---@field file File
---@field filename string
local FileOutputStream = {}

---@return table
function OutputStream.new()
	---@type OutputStream
	local obj = {}
	setmetatable(obj, OutputStream)
	OutputStream.__index = OutputStream
	return obj
end

---@param filename string
---@return FileOutputStream
function FileOutputStream.new(filename)
	---@type File
	local file = filesystem.open(filename, "w")
	---@type FileOutputStream
	local obj = {
		file = file,
		filename = filename,
	}
	setmetatable(obj, FileOutputStream)
	FileOutputStream.__index = FileOutputStream
	return obj
end

---@param text string
function OutputStream.write(text)
	print(text)
end

function OutputStream.close() end

---@param text string
function FileOutputStream:write(text)
	self.file:write(text .. "\n")
end

function FileOutputStream:close()
	self.file:close()
end

---@class ArrayPrinter
---@field private array string[]
---@field private depth number
---@field private highIndex number
---@field private history number[]
---@field private output OutputStream
---@field private arrayName string
local ArrayPrinter = {}

---@param array string[]
---@param depth number
---@return ArrayPrinter
function ArrayPrinter.new(array, depth, arrayName)
	---@type ArrayPrinter
	local obj = {
		array = array,
		depth = depth,
		highIndex = 1,
		history = {},
		output = OutputStream.new(),
		arrayName = arrayName,
	}
	setmetatable(obj, ArrayPrinter)
	ArrayPrinter.__index = ArrayPrinter
	return obj
end

---@param array string[]
---@param level number
function ArrayPrinter:print(array, level)
	if self.array == nil then
		print("nil")
		return
	end

	local spaces1 = rpad("", level * 2, " ")
	local spaces2 = rpad("", (level + 1) * 2, " ")
	self.output.write(spaces1 .. "[" .. self.arrayName .. "] <" .. tostring(self.highIndex) .. "> {")
	self.history[array] = self.highIndex
	self.highIndex = self.highIndex + 1

	local sortedKeys = {}
	for k, _ in pairs(array) do
		table.insert(sortedKeys, k)
	end

	table.sort(sortedKeys)
	for _, k in ipairs(sortedKeys) do
		local v = array[k]
		if v == nil then
			self.output.write(spaces2 .. "[" .. tostring(k) .. "] = nil")
		elseif type(v) == "string" then
			self.output.write(spaces2 .. "[" .. tostring(k) .. '] = "' .. v .. '"')
		elseif type(v) == "table" then
			if self.history[v] ~= nil then
				self.output.write(
					spaces2 .. "[" .. tostring(k) .. "] = <Reference#" .. tostring(self.history[v]) .. ">"
				)
			else
				if self.depth < 0 or level < self.depth then
					self.output.write(spaces2 .. "[" .. tostring(k) .. "] = ")
					self:print(v, level + 1)
				else
					self.output.write(spaces2 .. "[" .. tostring(k) .. "] = <limited by depth>")
				end
			end
		else
			self.output.write(spaces2 .. "[" .. tostring(k) .. "] = " .. tostring(v))
		end
	end

	self.output.write(spaces1 .. "}")
end

function ArrayPrinter:reset()
	self.history = {}
	self.highIndex = 1
end

function ArrayPrinter:printToConsole()
	self:reset()
	self.output = OutputStream.new()
	self:print(self.array, 0)
end

---@param filename string
function ArrayPrinter:printToFile(filename)
	self:reset()
	self.output = FileOutputStream.new(filename)
	self:print(self.array, 0)
	self.output:close()
end

---@param array string[]
---@param depth number
function printArray(array, depth, arrayName)
	arrayName = arrayName or "Array"
	local printer = ArrayPrinter.new(array, depth, arrayName)
	printer:printToConsole()
end

---@param array string[]
---@param depth number
---@param filename string
function printArrayToFile(array, depth, filename)
	local printer = ArrayPrinter.new(array, depth)
	printer:printToFile(filename)
end
