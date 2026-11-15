--!nocheck
--!nolint

return {
	global = "getthreadidentity",
	aliases = {
		"getidentity",
		"getthreadcontext",
	},
	cases = {
		{
			id = "number",
			run = function(self)
				--// Functionality test
				if typeof(getthreadidentity()) ~= "number" then
					return {
						status = 500,
						message = "Did not return a number",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
