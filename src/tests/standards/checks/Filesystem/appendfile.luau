--!nocheck
--!nolint

return {
	global = "appendfile",
	dependencies = {
		checks = {
			{ id = "Filesystem.writefile", message = "Dependency 'writefile' dosen't work properly." },
			{ id = "Filesystem.readfile", message = "Dependency 'readfile' dosen't work properly." },
			{ id = "Filesystem.delfile", message = "Dependency 'delfile' dosen't work properly." },
		},
	},
	cases = {
		{
			id = "write",
			run = function(self)
				self._guid = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
				writefile(self._guid, "Hello, ")
				self._wrote = true
				task.wait(0.2)
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "append",
			run = function(self)
				if not self._wrote then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				appendfile(self._guid, "World!")
				self._appended = true
				task.wait(0.2)
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "read",
			run = function(self)
				if not self._appended then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if readfile(self._guid) ~= "Hello, World!" then
					return {
						status = 500,
						message = "File did not read the expected value",
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
				if not self._guid then
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
