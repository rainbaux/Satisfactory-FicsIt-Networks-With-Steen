event.ignoreAll()
event.clear()

scriptInfo = {
	name = "Power Storage",
	gpu = computer.getPCIDevices(findClass("GPU_T1_C"))[1],
	sign = component.proxy(component.findComponent("Power Storage Sign"))[1],
}

filesystem.initFileSystem("/dev")

drive = ""
for _, f in pairs(filesystem.childs("/dev")) do
	if not (f == "serial") then
		drive = f
		break
	end
end

filesystem.mount("/dev/" .. drive, "/")

filesystem.doFile("/Modules/Require.lua")

filesystem.doFile("Common.lua")

main()
