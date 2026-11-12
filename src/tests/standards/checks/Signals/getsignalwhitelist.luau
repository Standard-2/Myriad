--!nocheck
--!nolint

return {
	cases = {
		{
			id = "global",
			run = function(self)
				if type(getsignalwhitelist) ~= "function" then
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

				local s, whitelist = pcall(function()
					return getsignalwhitelist()
				end)

				if not s then
					return {
						status = 0,
						message = `Ambiguous error: {whitelist}`,
					}
				end

				self._whitelist = whitelist
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

				if type(self._whitelist) ~= "table" then
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
				if not self._called or type(self._whitelist) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local whitelist = self._whitelist
				if #whitelist == 0 then
					return {
						status = 500,
						message = "Returned filter whitelist array should be populated.",
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
				if not self._called or type(self._whitelist) ~= "table" or #self._whitelist == 0 then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local whitelist = self._whitelist
				if type(whitelist[1]) ~= "table" then
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
					or type(self._whitelist) ~= "table"
					or #self._whitelist == 0
					or type(self._whitelist[1]) ~= "table"
				then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local whitelist = self._whitelist
				if type(whitelist[1].Event) ~= "string" or type(whitelist[1].Parent) ~= "string" then
					return {
						status = 500,
						message = "Members of the returned table do not contain appropriate fields 'Event' and 'Parent'.",
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
