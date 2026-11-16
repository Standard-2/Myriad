--!nocheck
--!nolint

return {
	global = "cansignalreplicate",
	type = "function",
	cases = {
		{
			id = "boolean",
			run = function(self)
				local gameRefs = require("@gameRefs")
				local valid = gameRefs.Baseplate.Touched
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
