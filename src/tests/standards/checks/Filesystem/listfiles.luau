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
			id = "write",
			run = function(self)
				self._guid = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
				self._guid2 = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
				writefile(self._guid, "")
				self._wrote = true
				writefile(self._guid2, "")
				self._wrote2 = true
				task.wait(0.2)
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "list",
			run = function(self)
				if not self._wrote2 then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				local found1 = false
				local found2 = false
				for _, file in listfiles("") do
					if file == self._guid then
						found1 = true
					end
					if file == self._guid2 then
						found2 = true
					end
				end
				if not found1 and found2 then
					return {
						status = 500,
						message = "Didn't find the expected files",
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
				if self._wrote then
					delfile(self._guid)
				end
				if self._wrote2 then
					delfile(self._guid2)
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
