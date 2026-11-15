--!nocheck
--!nolint

return {
	cases = {
		{
			id = "Animate",
			run = function(self)
				local indexedAnimate, Animate = pcall(function()
					return game.Players.LocalPlayer.Character.Animate
				end)
				if not indexedAnimate then
					return {
						status = 401,
						message = "Testing dependency 'Animate' not found.",
					}
				end

				self._animateOk = true
				self._animate = Animate
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "global",
			run = function(self)
				if not getsenv then
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
			id = "disabled script",
			run = function(self)
				local nonRunningScript = game.Players.LocalPlayer.Character.Character:FindFirstChild("whysodtc")
				if not nonRunningScript then
					return {
						status = 500,
						message = "Disabled script not found",
					}
				end

				self._disabled = nonRunningScript
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "custom environment",
			run = function(self)
				local customENVScript = game.Players.LocalPlayer.Character.Character:FindFirstChild("Miku!")
				if not customENVScript then
					return {
						status = 500,
						message = "Custom environment script not found",
					}
				end

				self._customScript = customENVScript
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "not running",
			run = function(self)
				if self._disabled == nil or not getsenv then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local success, errorMessage = pcall(getsenv, self._disabled)
				if success and errorMessage ~= nil then
					return {
						status = 500,
						message = "Should not be able to obtain the ENV from a script that is not running",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "custom env",
			run = function(self)
				if self._customScript == nil or not getsenv then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local success, result = pcall(getsenv, self._customScript)
				if not success or type(result) ~= "table" then
					return {
						status = 500,
						message = "The custom ENV could not be found",
					}
				end

				self._env = result
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "extra keys",
			run = function(self)
				local result = self._env
				if type(result) ~= "table" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local KeysCount = 0
				for _ in result do
					KeysCount += 1
				end

				if KeysCount ~= 2 then
					return {
						status = 500,
						message = "The returned ENV has extra keys",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "same env",
			run = function(self)
				local result = self._env
				if type(result) ~= "table" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if result.Loaded ~= "MyriadLoaded" or tostring(result) ~= result.inString then
					return {
						status = 500,
						message = "The returned ENV is not the same as the one in the custom environment script",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "on swimming",
			run = function(self)
				if not self._animateOk or not getsenv then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				--// Functionality test
				local Animate = self._animate
				local enironment = getsenv(Animate)
				if type(enironment.onSwimming) ~= "function" then
					return {
						status = 500,
						message = "Global in test script wasn't found, or didn't return the right type",
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
