--!nocheck
--!nolint

return {
	global = "debug.getstack",
	aliases = {
		"getstack",
	},
	cases = {
		{
			id = "result",
			run = function(self)
				return {
					status = 200,
					message = message or `Passed`,
				}
			end,
		},
	},
}
