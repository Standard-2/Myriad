--!nocheck

--// Functions
local function now()
	return DateTime.now().UnixTimestampMillis / 1000 -- We do it this way in case an executor freezes time()
end

--// Publish
local stopwatch = {}

function stopwatch.start()
	local origin = now()

	return function()
		return math.max(0, now() - origin)
	end
end

return stopwatch
