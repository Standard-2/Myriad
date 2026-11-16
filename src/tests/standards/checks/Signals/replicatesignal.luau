--!nocheck
--!nolint

return {
	global = "replicatesignal",
	type = "function",
	cases = {
		{
			id = "replicate",
			run = function(self)
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
