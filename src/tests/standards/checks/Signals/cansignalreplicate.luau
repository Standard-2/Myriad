--!nocheck
--!nolint

return {
	cases = {
		{
			id = "global",
			run = function(self)
				local gameRefs = require("@gameRefs")
				self._gameRefs = gameRefs

				if type(cansignalreplicate) ~= "function" then
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
			id = "boolean",
			run = function(self)
				if not self._fn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local valid = self._gameRefs.Baseplate.Touched
				local isReplicating = cansignalreplicate(valid)
				self._isReplicating = isReplicating
				self._called = true

				if type(isReplicating) ~= "boolean" then
					return {
						status = 500,
						message = "Return type is not a boolean",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "baseplate",
			run = function(self)
				if not self._called or type(self._isReplicating) ~= "boolean" then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if self._isReplicating then
					return {
						status = 500,
						message = "Expected false for Baseplate Touched event",
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
