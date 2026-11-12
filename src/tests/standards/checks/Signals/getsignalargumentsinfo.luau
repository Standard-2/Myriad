--!nocheck
--!nolint

return {
	cases = {
		{
			id = "global",
			run = function(self)
				if type(getsignalargumentsinfo) ~= "function" then
					return {
						status = 400,
						message = "Global not found",
					}
				end

				self._fn = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "call",
			run = function(self)
				if not self._fn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local Event = Instance.new("Part").Touched
				local s, info = pcall(function()
					return getsignalargumentsinfo(Event)
				end)

				if not s then
					return {
						status = 0,
						message = `Ambiguous error: {info}`,
					}
				end

				self._info = info
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

				if type(self._info) ~= "table" then
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
				if not self._called or type(self._info) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local info = self._info
				if #info == 0 then
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
			id = "members",
			run = function(self)
				if not self._called or type(self._info) ~= "table" or #self._info == 0 then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local info = self._info
				if type(info[1]) ~= "table" then
					return {
						status = 500,
						message = "Members of the returned array are not tables.",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "fields",
			run = function(self)
				if
					not self._called
					or type(self._info) ~= "table"
					or #self._info == 0
					or type(self._info[1]) ~= "table"
				then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local info = self._info
				if type(info[1].Type) ~= "string" or type(info[1].Name) ~= "string" then
					return {
						status = 500,
						message = "Members of the returned table do not contain appropriate fields 'Name' and 'Type'.",
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
