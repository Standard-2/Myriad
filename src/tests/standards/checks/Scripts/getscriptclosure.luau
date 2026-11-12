--!nocheck
--!nolint

return {
	global = "getscriptclosure",
	aliases = {
		"getscriptfunction",
	},
	cases = {
		{
			id = "closure",
			run = function(self)
				local cryptReference = require("@dependencies/crypt/crypt.luau")

				--// Functionality test
				local originalScript = game.Players.LocalPlayer.Character.Character:FindFirstChild("maybeisdtc")
				local closure = getscriptclosure(originalScript)
				self._closure = closure

				if typeof(closure) ~= "function" then
					return {
						status = 500,
						message = "Expected a closure",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "return value",
			run = function(self)
				if typeof(self._closure) ~= "function" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if self._closure() ~= "GOT A DROP ON THIS FLEXING FELLA" then
					return {
						status = 500,
						message = "Closure did not return the expected value",
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
