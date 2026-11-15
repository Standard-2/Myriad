--!nocheck
--!nolint

return {
	global = "checkcaller",
	dependencies = {
		globals = {
			{ name = "hookmetamethod", message = "Dependency 'hookmetamethod' missing" },
		},
	},
	cases = {
		{
			id = "thread",
			run = function(self)
				local callerFromThread = checkcaller()

				local fromHook
				local original
				original = hookmetamethod(game, "__namecall", function(...)
					if fromHook == nil then
						fromHook = checkcaller()
					end
					return original(...)
				end)

				tostring(game)

				task.wait(0.1)

				hookmetamethod(game, "__namecall", original)

				self._callerFromThread = callerFromThread
				self._fromHook = fromHook
				self._checked = true

				if callerFromThread ~= true then
					return {
						status = 500,
						message = "Returned false in executor thread",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "hook",
			run = function(self)
				if not self._checked then
					return { status = 200, message = "Passed" }
				end

				if self._fromHook ~= false then
					return {
						status = 500,
						message = "Did not return false in a hook",
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
