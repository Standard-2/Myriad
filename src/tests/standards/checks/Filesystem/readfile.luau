--!nocheck
--!nolint

return {
	global = "readfile",
	dependencies = {
		globals = {
			{ name = "delfile", message = "Dependency 'delfile' not found" },
			{ name = "writefile", message = "Dependency 'writefile' not found" },
		},
	},
	cases = {
		{
			id = "write",
			run = function(self)
				self._path = "test1.txt"
				self._content = "Content"
				local writeSuc, writeMsg = pcall(writefile, self._path, self._content)
				if not writeSuc then
					return {
						status = 0,
						message = "Failed to write @ test1.txt: " .. writeMsg,
					}
				end
				self._wrote = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "read",
			run = function(self)
				if not self._wrote then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if readfile(self._path) ~= self._content then
					return {
						status = 500,
						message = "File didn't return the expected content",
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
				delfile(self._path)
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
