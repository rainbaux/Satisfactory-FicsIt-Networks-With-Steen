local REFRESH_DELAY = 60000

---@class ComponentReference
---@field id string
---@field lastUpdate number
---@field object Actor | nil
local ComponentReference = {}

---@class Actor
---@field getInventories function
---@field powerStore number
---@field powerStorePercent number

---@return Actor
function ComponentReference:get()
	if self.object == nil or computer.millis() - self.lastUpdate > REFRESH_DELAY then
		self.object = component.proxy(self.id)
		self.lastUpdate = computer.millis()
	end

	return self.object
end

---@param networkID string
---@return ComponentReference
function ComponentReference.new(networkID)
	---@type ComponentReference
	local obj = {
		id = networkID,
		lastUpdate = 0,
		object = nil,
	}
	setmetatable(obj, ComponentReference)
	ComponentReference.__index = ComponentReference
	return obj
end

---@param networkID string
---@return ComponentReference
function createReference(networkID)
	return ComponentReference.new(networkID)
end

---@param reference ComponentReference
---@return Actor
function getReference(reference)
	if reference.object == nil or computer.millis() - reference.lastUpdate > REFRESH_DELAY then
		reference.object = component.proxy(reference.id)
		reference.lastUpdate = computer.millis()
	end

	return reference.object
end
