--!nocheck
--!nolint

local function listed(result, expected)
	if type(result) ~= "table" then
		return false
	end

	for _, value in pairs(result) do
		if value == expected then
			return true
		end
	end

	return false
end

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
		{
			id = "list",
			run = function(self)
				local function brineList()
					return "brine"
				end

				task.wait(0.1)

				local result = filtergc("function", {
					Name = "brineList",
					IgnoreExecutor = false,
				})

				if not listed(result, brineList) then
					return {
						status = 500,
						message = "filtergc did not return a list containing the named function",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "one",
			run = function(self)
				local function brineOne()
					return "brine"
				end

				task.wait(0.1)

				local result = filtergc("function", {
					Name = "brineOne",
					IgnoreExecutor = false,
				}, true)

				if result ~= brineOne then
					return {
						status = 500,
						message = "filtergc did not return the named function",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "ignored",
			run = function(self)
				local function brineHide()
					return "brine"
				end

				task.wait(0.1)

				local result = filtergc("function", {
					Name = "brineHide",
				}, true)

				if result == brineHide or listed(result, brineHide) then
					return {
						status = 500,
						message = "filtergc included an executor function when IgnoreExecutor was omitted",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "hash",
			run = function(self)
				local function quartzHash()
					return "quartz-hash"
				end

				if type(getfunctionhash) ~= "function" then
					return {
						status = 401,
						message = "Dependant global 'getfunctionhash' not found",
					}
				end

				task.wait(0.1)

				local hash = getfunctionhash(quartzHash)
				local result = filtergc("function", {
					Hash = hash,
					IgnoreExecutor = false,
				}, true)

				if result ~= quartzHash then
					return {
						status = 500,
						message = "filtergc did not return the function for its hash",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "constants",
			run = function(self)
				local function kelpConst()
					return "kelp-const"
				end

				task.wait(0.1)

				local result = filtergc("function", {
					Constants = { "kelp-const" },
					IgnoreExecutor = false,
				})

				if not listed(result, kelpConst) then
					return {
						status = 500,
						message = "filtergc did not return the function for its constant",
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
				local hue = "amber"
				local function amberUp()
					hue ..= "-live"
					return hue
				end

				amberUp()
				task.wait(0.1)

				local result = filtergc("function", {
					Upvalues = { hue },
					IgnoreExecutor = false,
				}, true)

				if result ~= amberUp then
					return {
						status = 500,
						message = "filtergc did not return the function for its upvalue",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "keys",
			run = function(self)
				local token = tostring({})
				local pocket = {
					[token] = "slate",
				}

				task.wait(0.1)

				local result = filtergc("table", {
					Keys = { token },
				})

				if not listed(result, pocket) then
					return {
						status = 500,
						message = "filtergc did not return the table for its key",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "values",
			run = function(self)
				local token = tostring({})
				local pocket = {
					mark = token,
				}

				task.wait(0.1)

				local result = filtergc("table", {
					Values = { token },
				})

				if not listed(result, pocket) then
					return {
						status = 500,
						message = "filtergc did not return the table for its value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "metatable",
			run = function(self)
				local meta = {
					__index = function() end,
				}
				local pocket = setmetatable({}, meta)

				task.wait(0.1)

				local result = filtergc("table", {
					Metatable = meta,
				})

				if not listed(result, pocket) then
					return {
						status = 500,
						message = "filtergc did not return the table for its metatable",
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
