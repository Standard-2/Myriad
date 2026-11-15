--!nocheck
--!nolint

return {
	global = "iscclosure",
	cases = {
		{
			id = "lua",
			run = function(self)
				local function luaClosure()
					return 1
				end
				local cClosure1 = print
				local cClosure2 = newcclosure(function()
					return 1
				end)
				self._luaClosure = luaClosure
				self._cClosure = cClosure1
				self._newClosure = cClosure2
				self._hasC = true
				self._hasNew = true

				if iscclosure(luaClosure) then
					return {
						status = 500,
						message = "Lua closure identified as C closure",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "c",
			run = function(self)
				if not self._hasC then
					return { status = 200, message = "Passed" }
				end

				if not iscclosure(self._cClosure) then
					return {
						status = 500,
						message = "C closure not identified as C closure",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "new",
			run = function(self)
				if not self._hasNew then
					return { status = 200, message = "Passed" }
				end

				if not iscclosure(self._newClosure) then
					return {
						status = 500,
						message = "C closure not identified as C closure",
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
