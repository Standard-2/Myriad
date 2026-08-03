--!nocheck
--!nolint

-- Please reference our manual tests to properly verify your implementation.
-- https://docs.myriad.tools/spec/File%20Dialog/openfiledialog/

--[[
	Example
	
	```luau
		print("Pick a config to use")

		local config
		local configFile = openfiledialog({
			extensionFilter = { "json" },
		})

		if configFile then
			config = configFile:Read()
		else
			print("No config selected.")
		end
	```
]]

return function()
	if not openfiledialog then
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
