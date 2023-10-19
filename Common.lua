require("/Modules/ArrayPrinter")
require("/Modules/InvFuncs")
require("/Modules/PowerFuncs")
require("/Modules/GpuFuncs")
require("/Modules/Reference")

local CONSTANTS = {
	SLEEP_DURATION = 5,
}

function main()
	while true do
		InvLoop()
		PowerLoop()

		sleep(CONSTANTS.SLEEP_DURATION)
	end
end
