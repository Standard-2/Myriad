--!nocheck
--!nolint

return {
	global = "delfolder",
	dependencies = {
		globals = {
			{ name = "makefolder", message = "Dependency 'makefolder' not found" },
			{ name = "isfolder", message = "Dependency 'isfolder' not found" },
		},
	},
	cases = {
		{
			id = "missing file",
			run = function(self)
				self._guid = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
				if isfolder(self._guid) then
					return {
						status = 500,
						message = `Nonexistent file returned true`,
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
			id = "existing file",
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
						message = `Existing file returned false`,
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "removed",
			run = function(self)
				if not self._made then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				delfolder(self._guid)
				task.wait(0.2)
				if isfolder(self._guid) then
					return {
						status = 500,
						message = `Nonexistent file returned true`,
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
