--!nocheck
--!nolint

return {
	global = "getrunningscripts",
	cases = {
		{
			id = "LocalScript",
			run = function(self)
				--// Functionality test
				local animate = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
				local runningScript = game.Players.LocalPlayer.Character.Character:FindFirstChild("whysoud")
				local disabledScript = game.Players.LocalPlayer.Character.Character:FindFirstChild("whysodtc")
				local nonrunningScript = game.Players.LocalPlayer.Character.Character:FindFirstChild("maybeisdtc")
				-- Having all of these are not neccessary, but might as well keep them (This was cloned from ./getscripts.luau)
				local localScript = Instance.new("LocalScript")
				local moduleScript = Instance.new("ModuleScript")
				local serverScript = Instance.new("Script")
				local clientRunContextScript = Instance.new("Script")
				clientRunContextScript.RunContext = Enum.RunContext.Client
				local runningScripts = getrunningscripts()
				self._scripts = runningScripts
				self._animate = animate
				self._runningScript = runningScript
				self._disabledScript = disabledScript
				self._nonrunningScript = nonrunningScript
				self._localScript = localScript
				self._moduleScript = moduleScript
				self._serverScript = serverScript
				self._clientScript = clientRunContextScript

				if table.find(runningScripts, localScript) then
					return {
						status = 500,
						message = "LocalScript found in returned table",
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

				if table.find(self._scripts, self._moduleScript) then
					return {
						status = 500,
						message = "ModuleScript found in returned table",
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

				if table.find(self._scripts, self._clientScript) then
					return {
						status = 500,
						message = "ServerScript w/ client runcontext found in returned table",
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
		{
			id = "disabled",
			run = function(self)
				if self._scripts == nil then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if table.find(self._scripts, self._disabledScript) then
					return {
						status = 500,
						message = "Disabled script found in returned table",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "non-running",
			run = function(self)
				if self._scripts == nil then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if table.find(self._scripts, self._nonrunningScript) then
					return {
						status = 500,
						message = "Non-running script found in returned table",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "running",
			run = function(self)
				if self._scripts == nil then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if
					not table.find(self._scripts, self._animate) or not table.find(self._scripts, self._runningScript)
				then
					return {
						status = 500,
						message = "Didn't find a running script in the returned table",
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
