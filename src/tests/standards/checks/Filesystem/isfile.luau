--!nocheck
--!nolint

return {
	global = "isfile",
	dependencies = {
		globals = {
			{ name = "writefile", message = "Dependency 'writefile' not found" },
			{ name = "delfile", message = "Dependency 'delfile' not found" },
		},
	},
	cases = {
		{
			id = "missing file",
			run = function(self)
				self._guid = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
				if isfile(self._guid) then
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
				self._wrote = true
				writefile(self._guid, "")
				task.wait(0.2)
				if not isfile(self._guid) then
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
			id = "delete",
			run = function(self)
				if not self._wrote then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				delfile(self._guid)
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
