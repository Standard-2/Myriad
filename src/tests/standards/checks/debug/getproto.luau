--!nocheck
--!nolint

return {
	global = "debug.getproto",
	aliases = {
		"getproto",
	},
	cases = {
		{
			id = "introspect",
			run = function(self)
				--// Functionality test
				local originalFunction = loadstring([[
		return function()
			local function MYRIAD(_, _, ...) return "MYRI_1" end
			return function() return "MYRI_2" end
		end
	]])()

				self._fn = originalFunction

				local firstProto = debug.getproto(originalFunction, 1)
				local success, errorOrName, numberOfArgs, isVariableArgs = pcall(debug.info, firstProto, "na")
				if success then
					self._info = true
					self._errorOrName = errorOrName
					self._numberOfArgs = numberOfArgs
					self._isVariableArgs = isVariableArgs
				end

				if not success then
					return {
						status = 500,
						message = "Proto is not introspectable via debug.info",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "signature",
			run = function(self)
				if not self._info then
					return { status = 200, message = "Passed" }
				end

				local errorOrName = self._errorOrName
				local numberOfArgs = self._numberOfArgs
				local isVariableArgs = self._isVariableArgs
				if errorOrName ~= "MYRIAD" or numberOfArgs ~= 2 or not isVariableArgs then
					return {
						status = 500,
						message = "The information from Proto does not match",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "first-proto",
			run = function(self)
				if type(self._fn) ~= "function" then
					return { status = 200, message = "Passed" }
				end

				local firstProtoActive = debug.getproto(self._fn, 1, true)
				if type(firstProtoActive) ~= "table" or not firstProtoActive[1] then
					return { status = 500, message = "getproto did not return proto" }
				end

				self._first = firstProtoActive
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "first-callable",
			run = function(self)
				if type(self._first) ~= "table" or not self._first[1] then
					return { status = 200, message = "Passed" }
				end

				local firstProtoActive = self._first
				if type(firstProtoActive[1]) ~= "function" then
					return { status = 500, message = "getproto(active=true) result[1] is not callable" }
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "first-call",
			run = function(self)
				if type(self._first) ~= "table" or type(self._first[1]) ~= "function" then
					return { status = 200, message = "Passed" }
				end

				local firstProtoActive = self._first
				if firstProtoActive[1]() ~= "MYRI_1" then
					return { status = 500, message = "Proto returned incorrect value when called" }
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "second-proto",
			run = function(self)
				if type(self._fn) ~= "function" then
					return { status = 200, message = "Passed" }
				end

				local secondProtoActive = debug.getproto(self._fn, 2, true)
				if type(secondProtoActive) ~= "table" or not secondProtoActive[1] then
					return { status = 500, message = "getproto did not return proto" }
				end

				self._second = secondProtoActive
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "second-callable",
			run = function(self)
				if type(self._second) ~= "table" or not self._second[1] then
					return { status = 200, message = "Passed" }
				end

				local secondProtoActive = self._second
				if type(secondProtoActive[1]) ~= "function" then
					return { status = 500, message = "getproto(active=true) result[1] is not callable" }
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "second-call",
			run = function(self)
				if type(self._second) ~= "table" or type(self._second[1]) ~= "function" then
					return { status = 200, message = "Passed" }
				end

				local secondProtoActive = self._second
				if secondProtoActive[1]() ~= "MYRI_2" then
					return { status = 500, message = "Proto returned incorrect value when called" }
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "cclosure",
			run = function(self)
				if pcall(debug.getproto, print, 1, true) then
					return { status = 500, message = "getproto should error when given a C closure" }
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
