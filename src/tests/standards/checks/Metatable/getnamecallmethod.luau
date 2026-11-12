--!nocheck
--!nolint

return {
	global = "getnamecallmethod",
	cases = {
		{
			id = "method",
			run = function(self)
				local method1, method2
				local simpleTable = Color3.new()

				pcall(function()
					simpleTable:MYRIAD1()
				end)

				task.spawn(function()
					method2 = getnamecallmethod()

					pcall(function()
						simpleTable.MYRIAD1(simpleTable)
					end)

					method2 = method2 or getnamecallmethod()
				end)

				task.wait()

				method1 = getnamecallmethod()
				self._method1 = method1
				self._method2 = method2
				self._ready = true

				if method1 ~= "MYRIAD1" then
					return {
						status = 500,
						message = "Didn't return the correct method",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "leak",
			run = function(self)
				if not self._ready then
					return { status = 200, message = "Passed" }
				end

				if self._method2 ~= nil then
					return {
						status = 500,
						message = "Namecall method leaked into a new thread",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
