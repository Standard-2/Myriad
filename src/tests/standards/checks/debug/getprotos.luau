--!nocheck
--!nolint

return {
	global = "debug.getprotos",
	aliases = {
		"getprotos",
	},
	cases = {
		{
			id = "count",
			run = function(self)
				--// Functionality test
				local function originalFunction()
					return function()
						return "MYRI1"
					end, function()
						return "MYRI2"
					end
				end

				self._fn = originalFunction

				local protos = debug.getprotos(originalFunction)
				self._protos = protos
				if #protos ~= 2 then
					return { status = 500, message = "Incorrect proto count" }
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "unique",
			run = function(self)
				if type(self._protos) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				local protos = self._protos
				if protos[1] == protos[2] then
					return { status = 500, message = "Protos aren't unique." }
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
