--!nocheck
--!nolint

return {
	global = "crypt.random",
	cases = {
		{
			id = "call",
			run = function(self)
				local baseSuccess, baseMessage = pcall(function()
					return crypt.random(64)
				end)
				if baseSuccess then
					self._baseOk = true
					self._base = baseMessage
				end

				if not baseSuccess then
					return {
						status = 0,
						message = "Failed: " .. tostring(baseMessage),
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "negative",
			run = function(self)
				local minLimSuccess, minLimMessage = pcall(function()
					return crypt.random(-1)
				end)
				if minLimSuccess then
					return {
						status = 500,
						message = "Arg[1] passed -1, should have failed.",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "maximum",
			run = function(self)
				local maxLimSuccess, maxLimMessage = pcall(function()
					return crypt.random(512)
				end)
				if not maxLimSuccess then
					return {
						status = 500,
						message = "Arg[1] passed 512, should have passed.",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "length",
			run = function(self)
				if not self._baseOk then
					return { status = 200, message = "Passed" }
				end

				local baseMessage = self._base
				if #baseMessage ~= 64 then
					return {
						status = 500,
						message = "Len mismatch. Expected 64, got: " .. tostring(#baseMessage),
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
