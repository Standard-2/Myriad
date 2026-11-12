--!nocheck
--!nolint

return {
	global = "getactors",
	cases = {
		{
			id = "actor",
			run = function(self)
				--// Functionality test
				local found = false
				local gameRefs = require("@gameRefs")
				local actor = gameRefs.PMOVON

				for i, v in pairs(getactors()) do
					if v == actor then
						found = true
					end
				end

				if not found then
					return {
						status = 500,
						message = "Didn't find a game actor",
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
