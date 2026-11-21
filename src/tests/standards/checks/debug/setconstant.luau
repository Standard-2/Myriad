--!nocheck
--!nolint

--// Private Methods
local function sample()
	if type(loadstring) ~= "function" then
		return nil
	end

	local compiled = loadstring([[
		local function originalFunction()
			local _1 = 2
			local _2 = "A"

			tostring(_1)
			tostring(_2)

			return _2
		end

		return originalFunction
	]])
	if type(compiled) ~= "function" then
		return nil
	end

	return compiled()
end

local function constantIndex(fn, expected)
	local index = 1

	while true do
		local success, const = pcall(debug.getconstant, fn, index)
		if not success then
			return nil
		end

		if const == expected then
			return index
		end

		index += 1
	end
end

local function boundsIndex(fn)
	local index = 1

	while true do
		if not pcall(debug.getconstant, fn, index) then
			return index
		end

		index += 1
	end
end

--// Publish
return {
	global = "debug.setconstant",
	dependencies = {
		globals = {
			"debug.getconstant",
			{ name = "loadstring", message = "Dependency 'loadstring' not found" },
		},
	},
	aliases = {
		"setconstant",
	},
	cases = {
		{
			id = "read",
			run = function(self)
				local originalFunction = sample()
				if type(originalFunction) ~= "function" then
					return {
						status = 500,
						message = "Failed to compile test function with loadstring",
					}
				end

				local index = constantIndex(originalFunction, "A")
				if index == nil then
					return {
						status = 500,
						message = "Expected constant was not found: A",
					}
				end

				debug.setconstant(originalFunction, index, "MYRIAD")
				local current = debug.getconstant(originalFunction, index)
				if current ~= "MYRIAD" then
					return {
						status = 500,
						message = `Constant was {current} after debug.setconstant`,
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
				if type(originalFunction) ~= "function" then
					return {
						status = 500,
						message = "Failed to compile test function with loadstring",
					}
				end

				local index = constantIndex(originalFunction, "A")
				if index == nil then
					return {
						status = 500,
						message = "Expected constant was not found: A",
					}
				end

				debug.setconstant(originalFunction, index, "MYRIAD")
				local result = originalFunction()
				if result ~= "MYRIAD" then
					return {
						status = 500,
						message = `Function returned {result} after debug.setconstant`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "type",
			run = function(self)
				local originalFunction = sample()
				if type(originalFunction) ~= "function" then
					return {
						status = 500,
						message = "Failed to compile test function with loadstring",
					}
				end

				local index = constantIndex(originalFunction, "A")
				if index == nil then
					return {
						status = 500,
						message = "Expected constant was not found: A",
					}
				end

				if pcall(debug.setconstant, originalFunction, index, 123) then
					return {
						status = 500,
						message = "Should error when the constant type does not match.",
					}
				end

				local current = debug.getconstant(originalFunction, index)
				if current ~= "A" then
					return {
						status = 500,
						message = `Constant was {current} after a type mismatch`,
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
				if type(originalFunction) ~= "function" then
					return {
						status = 500,
						message = "Failed to compile test function with loadstring",
					}
				end

				local invalidIndex = boundsIndex(originalFunction)
				if pcall(debug.setconstant, originalFunction, invalidIndex, "Z") then
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
			id = "cclosure",
			run = function(self)
				if pcall(debug.setconstant, print, 1, "A") then
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
