--!nocheck
--!nolint

-- Please reference our manual tests to properly verify your implementation.
-- https://docs.myriad.tools/spec/File%20Dialog/savefiledialog/

--[[
	Example (ONLY reference the docs above for all methods and properties.)

	```luau
		print("Save your config")

		local config = "{ aimbot = true }"
		local configFile = savefiledialog(config, {
			extensionFilter = { "json" },
		})

		if configFile then
			print("Save success")
		else
			print("Save cancelled")
		end
	```
]]

return function()
	if not savefiledialog then
		return {
			status = 400,
			message = "Global not found",
		}
	end

	return {
		status = 200,
		message = "Passed",
	}
end
