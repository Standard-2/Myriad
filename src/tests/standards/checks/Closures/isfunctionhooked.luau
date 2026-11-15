--!nocheck
--!nolint

return {
	global = "isfunctionhooked",
	dependencies = {
		checks = {
			{
				id = "Closures.hookfunction",
				message = "Dependency 'hookfunction' not found, or doesn't work properly.",
			},
		},
	},
	cases = {
		{
			id = "unhooked",
			run = function(self)
				local function originalFunc1()
					return 1
				end

				local function1 = originalFunc1

				if isfunctionhooked(function1) then
					return {
						status = 500,
						message = "Non-hooked function is hooked",
					}
				end

				self._function1 = function1
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "hooked",
			run = function(self)
				local function1 = self._function1
				if function1 == nil then
					return { status = 200, message = "Passed" }
				end

				local function function2()
					return 2
				end

				local original = hookfunction(function1, function2)
				self._original = original

				if not isfunctionhooked(function1) then
					return {
						status = 500,
						message = "Hooked function is not hooked",
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
