--!nocheck
--!nolint

-- Please reference our manual tests to properly verify your implementation.
-- https://docs.myriad.tools/spec/File%20Dialog/openfiledialog/

--[[
	Example (ONLY reference the docs above for all methods and properties.)

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

return {
	global = "openfiledialog",
}
