--!nocheck
--!nolint

return {
	global = "cache.invalidate",
	cases = {
		{
			id = "identity",
			run = function(self)
				--// Functionality test
				local badgeService = game:GetService("BadgeService")

				if badgeService ~= game:GetService("BadgeService") then
					return {
						status = 500,
						message = "Did a cosmic ray just hit your computer? This should never evaluate",
					}
				end

				self._badgeService = badgeService
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "retained",
			run = function(self)
				local badgeService = self._badgeService
				if badgeService == nil then
					return { status = 200, message = "Passed" }
				end

				cache.invalidate(badgeService)

				if badgeService == game:GetService("BadgeService") then
					return {
						status = 500,
						message = "Reference to service object retained",
					}
				end

				self._invalidated = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "type",
			run = function(self)
				if not self._invalidated then
					return { status = 200, message = "Passed" }
				end

				if typeof(self._badgeService) ~= "Instance" then
					return {
						status = 500,
						message = "Reference type wasn't retained",
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
