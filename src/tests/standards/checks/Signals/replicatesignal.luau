--!nocheck
--!nolint

return {
	cases = {
		{
			id = "global",
			run = function(self)
				if type(replicatesignal) ~= "function" then
					return {
						status = 400,
						message = "Global not found",
					}
				end

				self._fn = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "replicate",
			run = function(self)
				if not self._fn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local s, err = pcall(function()
					replicatesignal(Instance.new("ProximityPrompt").Triggered, game:GetService("Players").LocalPlayer)
				end)

				if not s and not string.find(string.lower(tostring(err)), "replicate") then
					return {
						status = 0,
						message = `Ambiguous error: {err}`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
	},
}
