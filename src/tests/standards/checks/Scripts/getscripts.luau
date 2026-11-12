--!nocheck
--!nolint

return {
	global = "getscripts",
	cases = {
		{
			id = "LocalScript",
			run = function(self)
				--// Functionality test
				local localScript = Instance.new("LocalScript")
				local moduleScript = Instance.new("ModuleScript")
				local serverScript = Instance.new("Script")
				local clientRunContextScript = Instance.new("Script")
				clientRunContextScript.RunContext = Enum.RunContext.Client
				local scripts = getscripts()
				self._scripts = scripts
				self._localScript = localScript
				self._moduleScript = moduleScript
				self._serverScript = serverScript
				self._clientScript = clientRunContextScript

				if not table.find(scripts, localScript) then
					return {
						status = 500,
						message = "LocalScript not found in returned table",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "ModuleScript",
			run = function(self)
				if self._scripts == nil then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if not table.find(self._scripts, self._moduleScript) then
					return {
						status = 500,
						message = "ModuleScript not found in returned table",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "client runcontext",
			run = function(self)
				if self._scripts == nil then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if not table.find(self._scripts, self._clientScript) then
					return {
						status = 500,
						message = "ServerScript w/ client runcontext not found in returned table",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "ServerScript",
			run = function(self)
				if self._scripts == nil then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if table.find(self._scripts, self._serverScript) then
					return {
						status = 500,
						message = "ServerScript found in returned table",
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
