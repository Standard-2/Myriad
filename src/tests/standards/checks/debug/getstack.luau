--!nocheck
--!nolint

--// Private Methods
local function stackIndex(stack, expected)
	if type(stack) ~= "table" then
		return nil
	end

	for index, value in pairs(stack) do
		if value == expected then
			return index
		end
	end

	return nil
end

--// Publish
return {
	global = "debug.getstack",
	aliases = {
		"getstack",
	},
	cases = {
		{
			id = "list",
			run = function(self)
				local function frame()
					local slot = "mica"
					slot ..= "-mark"

					local stack = debug.getstack(1)
					if type(stack) ~= "table" then
						return {
							status = 500,
							message = "debug.getstack did not return a table",
						}
					end

					if stackIndex(stack, slot) == nil then
						return {
							status = 500,
							message = "Expected stack value was not found: mica-mark",
						}
					end

					return {
						status = 200,
						message = `Passed`,
					}
				end

				return frame()
			end,
		},
		{
			id = "index",
			run = function(self)
				local function frame()
					local slot = "mica"
					slot ..= "-mark"

					local stack = debug.getstack(1)
					local index = stackIndex(stack, slot)
					if index == nil then
						return {
							status = 500,
							message = "Expected stack value was not found: mica-mark",
						}
					end

					local current = debug.getstack(1, index)
					if current ~= slot then
						return {
							status = 500,
							message = `Stack value was {current} at index {index}`,
						}
					end

					return {
						status = 200,
						message = `Passed`,
					}
				end

				return frame()
			end,
		},
		{
			id = "caller",
			run = function(self)
				local anchor = "brine"
				anchor ..= "-mark"

				local function nested()
					return debug.getstack(2)
				end

				local stack = nested()
				if stackIndex(stack, anchor) == nil then
					return {
						status = 500,
						message = "Expected stack value was not found: brine-mark",
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
				local function frame()
					local slot = "mica"
					slot ..= "-mark"

					if pcall(debug.getstack, 2, 256) then
						return {
							status = 500,
							message = "Should error when retrieving an invalid stack index.",
						}
					end

					return {
						status = 200,
						message = `Passed`,
					}
				end

				return frame()
			end,
		},
		{
			id = "level",
			run = function(self)
				if pcall(debug.getstack, 0) then
					return {
						status = 500,
						message = "Should error when the level points at a C closure",
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
