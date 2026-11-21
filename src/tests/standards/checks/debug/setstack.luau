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
	global = "debug.setstack",
	dependencies = {
		globals = {
			"debug.getstack",
		},
	},
	aliases = {
		"setstack",
	},
	cases = {
		{
			id = "read",
			run = function(self)
				local function frame()
					local slot = "quartz"
					slot ..= "-slot"

					local index = stackIndex(debug.getstack(1), slot)
					if index == nil then
						return {
							status = 500,
							message = "Expected stack value was not found: quartz-slot",
						}
					end

					debug.setstack(1, index, "quartz-moved")
					local current = debug.getstack(1, index)
					if current ~= "quartz-moved" then
						return {
							status = 500,
							message = `Stack value was {current} after debug.setstack`,
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
			id = "local",
			run = function(self)
				local function frame()
					local slot = "quartz"
					slot ..= "-slot"

					local index = stackIndex(debug.getstack(1), slot)
					if index == nil then
						return {
							status = 500,
							message = "Expected stack value was not found: quartz-slot",
						}
					end

					debug.setstack(1, index, "quartz-moved")
					if slot ~= "quartz-moved" then
						return {
							status = 500,
							message = `Local was {slot} after debug.setstack`,
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
				local anchor = "cedar"
				anchor ..= "-slot"

				local function nested()
					local index = stackIndex(debug.getstack(2), anchor)
					if index == nil then
						return nil
					end

					debug.setstack(2, index, "cedar-moved")
					return true
				end

				if not nested() then
					return {
						status = 500,
						message = "Expected stack value was not found: cedar-slot",
					}
				end

				if anchor ~= "cedar-moved" then
					return {
						status = 500,
						message = `Caller local was {anchor} after debug.setstack`,
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
					local slot = "quartz"
					slot ..= "-slot"

					if pcall(debug.setstack, 2, 256, "overflow") then
						return {
							status = 500,
							message = "Should error when setting an invalid stack index.",
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
				if pcall(debug.setstack, 0, 1, "nope") then
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
