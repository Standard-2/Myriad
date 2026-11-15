--!nocheck
--!nolint

return {
	global = "getcallingscript",
	dependencies = {
		globals = {
			{ name = "checkcaller", message = "Dependency 'checkcaller' not found" },
			{ name = "hookmetamethod", message = "Dependency 'hookmetamethod' not found" },
		},
	},
	cases = {
		{
			id = "executor call",
			run = function(self)
				--// Functionality test
				local original
				original = hookmetamethod(game, "__index", function(self, index)
					if not checkcaller() then
						local caller = getcallingscript()

						hookmetamethod(game, "__index", original)
					end

					return original(self, index)
				end) -- https://docs.sunc.su/Scripts/getcallingscript/#example

				if getcallingscript() then
					return {
						status = 500,
						message = "Executor call assumed to be a game call",
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
