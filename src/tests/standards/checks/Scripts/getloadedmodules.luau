--!nocheck
--!nolint

return {
	cases = {
		{
			id = "empty module",
			run = function(self)
				local network = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
				local module = network and network:FindFirstChild("emptyModule")

				if not module then
					return {
						status = 401,
						message = "Testing dependency 'Network.emptyModule' not found.",
					}
				end

				self._module = module
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "global",
			run = function(self)
				if not getloadedmodules then
					return {
						status = 400,
						message = "Global not found",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "require",
			run = function(self)
				if self._module == nil then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				--// Functionality test
				local module = self._module
				local requireOk, requireResult = pcall(require, module)
				if not requireOk then
					return {
						status = 500,
						message = `Failed to require 'Network.emptyModule': {requireResult}`,
					}
				end

				self._required = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "loaded",
			run = function(self)
				if self._module == nil or self._required ~= true or not getloadedmodules then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local unloadedModule = Instance.new("ModuleScript")
				local loadedModules = getloadedmodules()
				self._unloadedModule = unloadedModule
				self._loadedModules = loadedModules

				if not table.find(loadedModules, self._module) then
					return {
						status = 500,
						message = "Loaded module not found in returned table",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "unloaded",
			run = function(self)
				if self._loadedModules == nil then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if table.find(self._loadedModules, self._unloadedModule) then
					return {
						status = 500,
						message = "Unloaded module found in returned table",
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
