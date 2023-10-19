---@param time number
function sleep(time)
	event.ignoreAll()
	event.pull(time)
end

function setPowerTotalSignText()
	local sign = scriptInfo.sign
	sign:Element_SetText(tostring(math.floor(PowerStoredTotal.stored)), 0)
	sign:Element_SetText(tostring(math.floor(PowerStoredTotal.percent)) .. "%", 1)
end
