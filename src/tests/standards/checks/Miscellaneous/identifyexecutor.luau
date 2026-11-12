--!nocheck
--!nolint

return {
	global = "identifyexecutor",
	aliases = {
		"getexecutorname",
	},
	cases = {
		{
			id = "values",
			run = function(self)
				--// Functionality Test
				local executor, vers = identifyexecutor()
				if not executor or not vers then
					return {
						status = 500,
						message = `Did not return expected data (executor, version)`,
					}
				end

				self._executor = executor
				self._vers = vers
				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "types",
			run = function(self)
				local executor = self._executor
				local vers = self._vers
				if executor == nil or vers == nil then
					return { status = 200, message = "Passed" }
				end

				if type(executor) ~= "string" or type(vers) ~= "string" then
					return {
						status = 500,
						message = `Expected [string, string] got [{executor}, {vers}]`,
					}
				end

				return {
					status = 200,
					message = `Passed ({executor}, {vers})`,
				}
			end,
		},
	},
}
