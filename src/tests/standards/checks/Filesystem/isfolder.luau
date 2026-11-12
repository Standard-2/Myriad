--!nocheck
--!nolint

return {
	global = "isfolder",
	dependencies = {
		globals = {
			{ name = "makefolder", message = "Dependency 'makefolder' not found" },
			{ name = "delfolder", message = "Dependency 'delfolder' not found" },
		},
	},
	cases = {
		{
			id = "missing folder",
			run = function(self)
				self._guid = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
				if
					isfolder(self._guid) --[[ isfolder("lebron james") -- always true ]]
				then
					return {
						status = 500,
						message = `Nonexistent folder returned true`,
					}
				end
				self._clear = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "existing folder",
			run = function(self)
				if not self._clear then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				self._made = true
				makefolder(self._guid)
				task.wait(0.2)
				if not isfolder(self._guid) then
					return {
						status = 500,
						message = `Existing folder returned false`,
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "delete",
			run = function(self)
				if not self._made then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				delfolder(self._guid)
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
