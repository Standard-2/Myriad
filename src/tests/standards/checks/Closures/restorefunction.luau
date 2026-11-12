--!nocheck
--!nolint

return {
	global = "restorefunction",
	dependencies = {
		globals = {
			{ name = "hookfunction", message = "'hookfunction' needed to test this" },
		},
	},
	aliases = {
		"restorefunc",
	},
	cases = {
		{
			id = "baseline",
			run = function(self)
				local function originalFunc1()
					return 1
				end

				local function1 = originalFunc1

				local function function2()
					return 2
				end

				if function1() ~= 1 then
					return {
						status = 500,
						message = "This should never evaluate. Did a cosmic ray hit your computer and flip a bit?",
					}
				end

				self._function1 = function1
				self._function2 = function2
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "hook",
			run = function(self)
				if self._function1 == nil or self._function2 == nil then
					return { status = 200, message = "Passed" }
				end

				local original = hookfunction(self._function1, self._function2)
				self._original = original

				if self._function1() ~= 2 then
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "old",
			run = function(self)
				if self._original == nil then
					return { status = 200, message = "Passed" }
				end

				if self._original() ~= 1 then
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "restore",
			run = function(self)
				if self._function1 == nil or self._original == nil then
					return { status = 200, message = "Passed" }
				end

				restorefunction(self._function1)

				if self._function1() ~= 1 then
					hookfunction(self._function1, self._original)
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "upvalues",
			run = function(self)
				local up1, up2 = {}, {}
				local function upvals()
					return up1
				end

				local function extraUpvals()
					return up1, up2
				end

				hookfunction(upvals, extraUpvals)
				restorefunction(upvals)

				if upvals() ~= up1 then
					return {
						status = 500,
						message = "Restored function did not restore upvalues",
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
