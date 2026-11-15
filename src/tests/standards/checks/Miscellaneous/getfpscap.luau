--!nocheck
--!nolint

return {
	global = "getfpscap",
	cases = {
		{
			id = "number",
			run = function(self)
				--// Functionality Test
				if typeof(getfpscap()) ~= "number" then
					return {
						status = 500,
						message = `Did not return a number`,
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
