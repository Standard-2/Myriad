--!nocheck
--!nolint

return {
	global = "debug.getconstants",
	aliases = {
		"getconstants",
	},
	cases = {
		{
			id = "table",
			run = function(self)
				--// Functionality test
				local function originalFunction()
					local _1 = 2
					local _2 = "A"

					print(_1)
					tostring(_2)

					Date.now()
				end

				self._fn = originalFunction

				local constants = debug.getconstants(originalFunction)
				if type(constants) ~= "table" then
					return {
						status = 500,
						message = "debug.getconstants did not return a table",
					}
				end

				self._constants = constants
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "expected",
			run = function(self)
				if type(self._constants) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				local constOrder = {
					"print",
					"A",
					"tostring",
					"Date",
					"now",
				}
				local constants = self._constants

				for i, v in ipairs(constOrder) do
					local found = false

					for _, const in pairs(constants) do
						if const == v then
							found = true

							break
						end
					end

					if not found then
						return {
							status = 500,
							message = `Expected constant was not found: {v}`,
						}
					end
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
				if pcall(debug.getconstants, print) then
					return {
						status = 500,
						message = "Should error with C closures",
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
