---@class StockPile
---@field public resource string
---@field public amount number
---@field public reference ComponentReference | nil
local StockPile = {
	resource = "",
	amount = 0,
	reference = nil,
}

---@type table<string, StockPile>
local resourceStock = {}
local resourceStorageCache = {}

local CONSTANTS = {
	FILE_PATH = "/Files/StockPile.txt",
}

---@param resource string
---@return StockPile
function StockPile.new(resource)
	return setmetatable({ resource = resource }, { __index = StockPile })
end

function buildResourceStorageCache()
	for _, id in pairs(component.findComponent("")) do
		local comp = component.proxy(id)
		local name = comp.nick
		local p = explode("_", name)
		if p then
			if p[1] == "Storage" then
				resourceStorageCache[p[2]] = comp
			end
		end
	end
end

---@param resource string
---@param obj StockPile
---@return boolean, string | nil
function findAndUpdateResourceStorage(resource, obj)
	local cache = resourceStorageCache[resource]
	if cache then
		obj.reference = createReference(cache.id)
		local store = obj.reference:get()
		if store then
			obj.amount = store:getInventories()[1].ItemCount
			return true
		else
			return false, "No storage for resource: " .. resource
		end
	else
		return false, "No cache for resource: " .. resource
	end
end

---@param resource StockPile
---@param file File | nil
function resourceSummary(resource, file)
	local resourceStorage = resourceStock[resource]

	if resourceStorage then
		local summary = tostring(resourceStorage.resource) .. ": has " .. tostring(resourceStorage.amount)

		if file then
			file:write(summary .. "\n")
		else
			print(summary)
		end
	else
		print("Error: ResourceStock[" .. resource .. "] is nil")
	end
end

---@param file File | nil
function processResourceSummaryForAll(file)
	local sortedResources = {}
	for resource, _ in pairs(resourceStorageCache) do
		table.insert(sortedResources, resource)
	end

	table.sort(sortedResources)
	for _, resource in ipairs(sortedResources) do
		resourceSummary(resource, file)
	end
end

function updateResourceTotals()
	local errors = {}

	local sortedResources = {}
	for resource, _ in pairs(resourceStorageCache) do
		table.insert(sortedResources, resource)
	end

	table.sort(sortedResources)

	for _, resource in ipairs(sortedResources) do
		local resourceStorage = resourceStock[resource] or StockPile.new(resource)

		if not findAndUpdateResourceStorage(resource, resourceStorage) then
			table.insert(errors, "No storage for resource: " .. resource)
		end

		if resourceStorage.reference == nil then
			table.insert(errors, "No reference for resource: " .. resource)
		end

		resourceStock[resource] = resourceStorage
		local success, errorMsg = findAndUpdateResourceStorage(resource, resourceStorage)
		if not success then
			table.insert(errors, errorMsg)
		end
	end

	if #errors > 0 then
		printArray(errors, 2)
		return false
	end

	return true
end

function InvLoop()
	buildResourceStorageCache()

	if not updateResourceTotals() then
		print("Error updating resource totals")
	end

	local resourceFile = filesystem.open(CONSTANTS.FILE_PATH, "w")
	if resourceFile then
		processResourceSummaryForAll(resourceFile)
		resourceFile:close()
	end
end
