--!nocheck
--!nolint

return {
	global = "filtergc",
	cases = {
		{
			id = "function",
			run = function(self)
				local tempTable = {}
				local upvalue, tempTable = `MYRIAD_{tempTable}`, nil
				local function originalFunction()
					return "MYRIAD", upvalue
				end

				local originalTable = setmetatable({
					MYRIAD = "MYRI",
				}, {
					__index = function() end,
				})

				local _1 = originalTable.MYRIAD -- Localize
				local _2 = upvalue
				local _3 = originalFunction()

				task.wait(0.1)

				local foundFunc = filtergc("function", {
					Constants = { "MYRIAD" },
					Upvalues = { upvalue },
					IgnoreExecutor = false,
				}, true)

				local foundTable = filtergc("table", {
					KeyValuePairs = { MYRIAD = "MYRI" },
					Metatable = getmetatable(originalTable),
				}, true)

				self._foundTable = foundTable
				self._originalTable = originalTable
				self._keep = { _1, _2, _3, originalFunction, originalTable, upvalue }
				self._ready = true

				if foundFunc ~= originalFunction then
					return {
						status = 500,
						message = "filtergc failed to retrieve the original function",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "table",
			run = function(self)
				if not self._ready then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if self._foundTable ~= self._originalTable then
					return {
						status = 500,
						message = "filtergc failed to retrieve the original table",
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
