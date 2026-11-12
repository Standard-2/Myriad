--!nocheck
--!nolint

return {
	global = "loadfile",
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
				self._a, self._b = math.random(1, 100), math.random(1, 100)
				self._guid = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
				writefile(self._guid, "return function(...) return select(1, ...) + select(2, ...) end")
				self._wrote = true
				task.wait(0.2)
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "load",
			run = function(self)
				if not self._wrote then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				local f = loadfile(self._guid)
				if not f then
					return {
						status = 500,
						message = "Failed to load file",
					}
				end
				self._f = f
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "result",
			run = function(self)
				if not self._f then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				local f = self._f
				local a = self._a
				local b = self._b
				if f()(a, b) ~= a + b then
					return {
						status = 500,
						message = "File did not return the expected value",
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
