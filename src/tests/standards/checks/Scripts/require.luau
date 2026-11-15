--!nocheck
--!nolint

return {
	cases = {
		{
			id = "test module",
			run = function(self)
				local gameRefs = require("@gameRefs")
				local testModule = gameRefs.mutable

				if not testModule then
					return {
						status = 401,
						message = "Test ModuleScript not found in ReplicatedStorage",
					}
				end

				self._module = testModule
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "require",
			run = function(self)
				if self._module == nil then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local testModule = self._module
				local success, result = pcall(function()
					return require(testModule)
				end)

				if not success then
					return {
						status = 500,
						message = `Failed to require the ModuleScript: {result}`,
					}
				end

				self._resultOk = true
				self._result = result
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "table",
			run = function(self)
				if not self._resultOk then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local result = self._result
				if type(result) ~= "table" then
					return {
						status = 500,
						message = `Expected table from ModuleScript, got {type(result)}`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "shared state",
			run = function(self)
				if type(self._result) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local result = self._result
				if result.Original == true then
					return {
						status = 500,
						message = "ModuleScript state was not shared with the game (returned original unmutated state)",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "data",
			run = function(self)
				if type(self._result) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local result = self._result
				if result.Data ~= "ChangedByGame" then
					return {
						status = 500,
						message = `ModuleScript returned unexpected data: {result.Data}`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "same instance",
			run = function(self)
				if not self._resultOk or self._module == nil then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local testModule = self._module
				local result = self._result
				local success2, result2 = pcall(function()
					return require(testModule)
				end)

				if result ~= result2 then
					return {
						status = 500,
						message = "require returned a different table instance on subsequent calls",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
	},
}
