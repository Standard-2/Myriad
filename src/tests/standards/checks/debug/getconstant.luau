--!nocheck
--!nolint

return {
	global = "debug.getconstant",
	aliases = {
		"getconstant",
	},
	cases = {
		{
			id = "expected",
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

				local constOrder = {
					"print",
					"A",
					"tostring",
					"Date",
					"now",
				}

				local constants = {}
				local index = 1

				while true do
					local success, const = pcall(debug.getconstant, originalFunction, index)
					if not success then
						break
					end

					if const ~= nil then
						constants[#constants + 1] = const
					end

					index += 1
				end

				self._index = index

				for i, v in ipairs(constOrder) do
					if not table.find(constants, v) then
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
			id = "bounds",
			run = function(self)
				if self._fn == nil or self._index == nil then
					return { status = 200, message = "Passed" }
				end

				local invalidIndexSuccess, _ = pcall(debug.getconstant, self._fn, self._index)
				if invalidIndexSuccess then
					return {
						status = 500,
						message = "Should error when retrieving Out-of-bounds indexes.",
					}
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
				if pcall(debug.getconstant, print, 1) then
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
