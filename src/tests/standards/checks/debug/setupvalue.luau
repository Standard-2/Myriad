--!nocheck
--!nolint

--// Private Methods
local function capture()
	local hue = "amber"
	local mark = "slate"

	local function step()
		hue ..= "-live"
		mark ..= "-live"
		return hue, mark
	end

	return step
end

local function upvalueIndex(fn, expected)
	local index = 1

	while true do
		local ok, value = pcall(debug.getupvalue, fn, index)
		if not ok then
			return nil
		end

		if value == expected then
			return index
		end

		index += 1
	end
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
				local step = capture()
				local index = upvalueIndex(step, "amber")
				if index == nil then
					return {
						status = 500,
						message = "Expected upvalue was not found: amber",
					}
				end

				debug.setupvalue(step, index, "copper")
				local current = debug.getupvalue(step, index)
				if current ~= "copper" then
					return {
						status = 500,
						message = `Upvalue was {current} after debug.setupvalue`,
					}
				end

				local sibling = upvalueIndex(step, "slate")
				if sibling == nil then
					return {
						status = 500,
						message = "Expected upvalue was not found: slate",
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
				local step = capture()
				local firstHue, firstMark = step()
				if firstHue ~= "amber-live" or firstMark ~= "slate-live" then
					return {
						status = 500,
						message = `Function returned {firstHue}, {firstMark} before debug.setupvalue`,
					}
				end

				local index = upvalueIndex(step, "amber-live")
				if index == nil then
					return {
						status = 500,
						message = "Expected upvalue was not found: amber-live",
					}
				end

				debug.setupvalue(step, index, "copper")
				local secondHue, secondMark = step()
				if secondHue ~= "copper-live" or secondMark ~= "slate-live-live" then
					return {
						status = 500,
						message = `Function returned {secondHue}, {secondMark} after debug.setupvalue`,
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
				local step = capture()
				local invalidIndex = boundsIndex(step)
				if pcall(debug.setupvalue, step, invalidIndex, "overflow") then
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
				local step = capture()
				if pcall(debug.setupvalue, step, 0, "nope") then
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
				if pcall(debug.setupvalue, print, 1, "nope") then
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
