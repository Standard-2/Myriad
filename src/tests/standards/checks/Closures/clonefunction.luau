--!nocheck
--!nolint

return {
	global = "clonefunction",
	cases = {
		{
			id = "identity",
			run = function(self)
				local dInfo, tWait = debug.info, task.wait
				local randomEnv, validYield = {}, false

				local function originalFunction(...)
					local Stacks = 0
					for i = 1, 20 do
						if dInfo(i, "f") then
							Stacks += 1
						end
					end

					tWait()
					validYield = true

					return 1, Stacks, ...
				end

				setfenv(originalFunction, randomEnv)

				local clonedFunction = clonefunction(originalFunction)

				if clonedFunction == originalFunction then
					return {
						status = 500,
						message = "Cloned function is the same as the original",
					}
				end

				self._original = originalFunction
				self._cloned = clonedFunction
				self._env = randomEnv
				self._readYield = function()
					return validYield
				end
				self._resetYield = function()
					validYield = false
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "yield",
			run = function(self)
				if
					self._cloned == nil
					or self._original == nil
					or self._readYield == nil
					or self._resetYield == nil
				then
					return { status = 200, message = "Passed" }
				end

				local _, orgStacks = self._original()
				self._resetYield()

				local result = table.pack(self._cloned(nil))

				if not self._readYield() then
					return {
						status = 500,
						message = "Cloned function is not yielding",
					}
				end

				self._result = result
				self._orgStacks = orgStacks
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "first",
			run = function(self)
				local result = self._result
				if result == nil then
					return { status = 200, message = "Passed" }
				end

				if result[1] ~= 1 then
					return {
						status = 500,
						message = "Cloned function is changing the first argument",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "second",
			run = function(self)
				local result = self._result
				if result == nil or result[1] ~= 1 then
					return { status = 200, message = "Passed" }
				end

				if result[3] ~= nil then
					return {
						status = 500,
						message = "Cloned function is changing the second argument",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "trim",
			run = function(self)
				local result = self._result
				if result == nil or result[1] ~= 1 or result[3] ~= nil then
					return { status = 200, message = "Passed" }
				end

				if result.n < 3 then
					return {
						status = 500,
						message = "Cloned function is trimming the second argument",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "extra",
			run = function(self)
				local result = self._result
				if result == nil or result[1] ~= 1 or result[3] ~= nil or result.n < 3 then
					return { status = 200, message = "Passed" }
				end

				if result.n > 3 then
					return {
						status = 500,
						message = "Cloned function is adding extra arguments",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "stack",
			run = function(self)
				local result = self._result
				if result == nil or result[1] ~= 1 or result[3] ~= nil or result.n < 3 or result.n > 3 then
					return { status = 200, message = "Passed" }
				end

				if result[2] ~= self._orgStacks then
					return {
						status = 500,
						message = "Cloned function is changing the stack count",
					}
				end

				self._shapeOk = true
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "info",
			run = function(self)
				if not self._shapeOk then
					return { status = 200, message = "Passed" }
				end

				local orgSource, orgName, orgLine, orgNArgs, orgIsVararg = debug.info(self._original, "snla")
				local copSource, copName, copLine, copNArgs, copIsVararg = debug.info(self._cloned, "snla")

				if
					orgSource ~= copSource
					or orgName ~= copName
					or orgLine ~= copLine
					or orgNArgs ~= copNArgs
					or orgIsVararg ~= copIsVararg
				then
					return {
						status = 500,
						message = "Cloned function is changing info",
					}
				end

				self._infoOk = true
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "env",
			run = function(self)
				if not self._infoOk then
					return { status = 200, message = "Passed" }
				end

				if getfenv(self._cloned) ~= self._env then
					return {
						status = 500,
						message = "Cloned function is changing the environment",
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
