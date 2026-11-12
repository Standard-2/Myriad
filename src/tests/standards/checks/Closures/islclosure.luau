--!nocheck
--!nolint

return {
	global = "islclosure",
	cases = {
		{
			id = "lua",
			run = function(self)
				local function luaClosure()
					return 1
				end
				local cClosure = print
				self._luaClosure = luaClosure
				self._cClosure = cClosure

				if not islclosure(luaClosure) then
					return {
						status = 500,
						message = "Failed to identify lua closure",
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
				if self._cClosure == nil then
					return { status = 200, message = "Passed" }
				end

				if islclosure(self._cClosure) then
					return {
						status = 500,
						message = "Identified C closure as lua closure",
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
