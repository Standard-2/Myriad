--!nocheck
--!nolint

return {
	global = "isexecutorclosure",
	aliases = {
		"checkclosure",
		"isourclosure",
	},
	cases = {
		{
			id = "executor",
			run = function(self)
				local function luaClosure()
					return 1
				end
				self._luaClosure = luaClosure

				if not isexecutorclosure(isexecutorclosure) then
					return {
						status = 500,
						message = "Failed to identify an executor closure",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "lua",
			run = function(self)
				if self._luaClosure == nil then
					return { status = 200, message = "Passed" }
				end

				if not isexecutorclosure(self._luaClosure) then
					return {
						status = 500,
						message = "Did not identify an lua closure as an executor closure",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "standard",
			run = function(self)
				if isexecutorclosure(print) then
					return {
						status = 500,
						message = "Identified a lua standard closure as an executor closure",
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
