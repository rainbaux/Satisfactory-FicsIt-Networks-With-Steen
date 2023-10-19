---@class PowerStorage
---@field public location string
---@field public stored number
---@field public percent number
---@field public reference ComponentReference | nil
local PowerStorage = {
	location = "",
	stored = 0,
	percent = 0,
	reference = nil,
}

---@type table<string, PowerStorage>
local powerStock = {}
local powerStorageCache = {}

local CONSTANTS = {
	FILE_PATH = "/Files/Power.txt",
	MAX_PERCENT_CONVERSION = 6,
}

---@param location string
---@return PowerStorage
function PowerStorage.new(location)
	return setmetatable({ location = location }, { __index = PowerStorage })
end

function buildPowerStorageCache()
	for _, id in pairs(component.findComponent("")) do
		local comp = component.proxy(id)
		local name = comp.nick
		local p = explode("_", name)
		if p[1] == "Power Storage" then
			powerStorageCache[p[2]] = comp
		end
	end
end

---@param location string
---@param obj PowerStorage
---@return boolean, string | nil
function findAndUpdatePowerStorage(location, obj)
	local cache = powerStorageCache[location]
	if cache then
		obj.reference = createReference(cache.id)
		local store = obj.reference:get()
		if store then
			obj.stored, obj.percent = store.powerStore, store.powerStorePercent
			return true
		else
			return false, "No storage for power location: " .. location
		end
	else
		return false, "No cache for power location: " .. location
	end
end

---@param location PowerStorage
---@param file File | nil
function powerSummary(location, file)
	local powerStorage = powerStock[location]

	if powerStorage then
		local summary = string.format(
			"%s: has %.2f MWh stored at %.2f%%",
			location,
			powerStorage.stored,
			powerStorage.percent * 100
		)

		if file then
			file:write(summary .. "\n")
		else
			print(summary)
		end
	else
		print("Error: PowerStock[" .. location .. "] is nil")
	end
end

---@param file File | nil
function processPowerSummaryForAll(file)
	local sortedLocations = {}
	for location, _ in pairs(powerStorageCache) do
		table.insert(sortedLocations, location)
	end

	table.sort(sortedLocations)
	for _, location in ipairs(sortedLocations) do
		powerSummary(location, file)
	end
end

---@return boolean
function updatePowerTotals()
	local powerSummaryTotal = {
		stored = 0,
		percent = 0,
	}
	local errors = {}

	local sortedLocations = {}
	for location, _ in pairs(powerStorageCache) do
		table.insert(sortedLocations, location)
	end

	table.sort(sortedLocations)

	for _, location in ipairs(sortedLocations) do
		local powerStorage = powerStock[location] or PowerStorage.new(location)

		if not findAndUpdatePowerStorage(location, powerStorage) then
			table.insert(errors, "No storage for power location: " .. location)
		end

		if powerStorage.reference == nil then
			table.insert(errors, "No reference for power location: " .. location)
		end

		powerStock[location] = powerStorage
		local success, errorMsg = findAndUpdatePowerStorage(location, powerStorage)
		if not success then
			table.insert(errors, errorMsg)
		end

		powerSummaryTotal = {
			stored = powerSummaryTotal.stored + powerStorage.stored,
			percent = powerSummaryTotal.percent + (powerStorage.percent * 100) / CONSTANTS.MAX_PERCENT_CONVERSION,
		}
	end

	if #errors > 0 then
		printArray(errors, 2)
		return false
	end

	PowerStoredTotal = powerSummaryTotal
	return true
end

function PowerLoop()
	buildPowerStorageCache()

	if not updatePowerTotals() then
		print("Error updating power totals")
	end

	local powerFile = filesystem.open(CONSTANTS.FILE_PATH, "w")
	if powerFile then
		processPowerSummaryForAll(powerFile)
		powerFile:close()
	end

	setPowerTotalSignText()
end
