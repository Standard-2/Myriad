--!nocheck
--!nolint

return {
	global = "getsignalarguments",
	type = "function",
	cases = {
		{
			id = "call",
			run = function(self)
				local Event = Instance.new("Part").Touched
				local s, args = pcall(function()
					return getsignalarguments(Event)
				end)

				if not s then
					return {
						status = 0,
						message = `Ambiguous error: {args}`,
					}
				end

				self._args = args
				self._called = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "type",
			run = function(self)
				if not self._called then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if type(self._args) ~= "table" then
					return {
						status = 500,
						message = "Return type is not a table",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "populated",
			run = function(self)
				if not self._called or type(self._args) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local args = self._args
				if #args == 0 then
					return {
						status = 500,
						message = "Returned array should be populated.",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "strings",
			run = function(self)
				if not self._called or type(self._args) ~= "table" or #self._args == 0 then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local args = self._args
				if type(args[1]) ~= "string" then
					return {
						status = 500,
						message = "Members of the returned array are not strings.",
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
