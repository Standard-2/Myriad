--!nocheck
--!nolint

--// Private Methods
local function sample()
	local upvalue = 90

	local function originalFunction()
		upvalue += 1
		return upvalue
	end

	return originalFunction
end

local function boundsIndex(fn)
	local index = 1

	while true do
		if not pcall(debug.getupvalue, fn, index) then
			return index
		end

		index += 1
	end
end

--// Publish
return {
	global = "debug.setupvalue",
	dependencies = {
		globals = {
			"debug.getupvalue",
		},
	},
	aliases = {
		"setupvalue",
	},
	cases = {
		{
			id = "read",
			run = function(self)
				local originalFunction = sample()

				debug.setupvalue(originalFunction, 1, 99)
				local current = debug.getupvalue(originalFunction, 1)
				if current ~= 99 then
					return {
						status = 500,
						message = `Upvalue was {current} after debug.setupvalue`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "call",
			run = function(self)
				local originalFunction = sample()
				local first = originalFunction()
				if first ~= 91 then
					return {
						status = 500,
						message = `Function returned {first} before debug.setupvalue`,
					}
				end

				debug.setupvalue(originalFunction, 1, 99)
				local second = originalFunction()
				if second ~= 100 then
					return {
						status = 500,
						message = `Function returned {second} after debug.setupvalue`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "bounds",
			run = function(self)
				local originalFunction = sample()
				local invalidIndex = boundsIndex(originalFunction)
				if pcall(debug.setupvalue, originalFunction, invalidIndex, 0) then
					return {
						status = 500,
						message = "Should error when setting Out-of-bounds indexes.",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "invalid-index",
			run = function(self)
				local originalFunction = sample()
				if pcall(debug.setupvalue, originalFunction, 0, 0) then
					return {
						status = 500,
						message = "Should error when setting invalid upvalue indexes",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "cclosure",
			run = function(self)
				if pcall(debug.setupvalue, print, 1, 0) then
					return {
						status = 500,
						message = "Should error with C closures",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
