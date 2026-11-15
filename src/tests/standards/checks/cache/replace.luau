--!nocheck
--!nolint

return {
	global = "cache.replace",
	cases = {
		{
			id = "distinct",
			run = function(self)
				--// Functionality test
				local inst1 = game:GetService("BadgeService")
				local inst2 = game:GetService("Stats")

				if inst1 == inst2 then
					return {
						status = 500,
						message = "Did a cosmic ray just hit your computer? This should never evaluate",
					}
				end

				self._inst1 = inst1
				self._inst2 = inst2
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "replaced",
			run = function(self)
				if self._inst1 == nil or self._inst2 == nil then
					return { status = 200, message = "Passed" }
				end

				cache.replace(self._inst1, self._inst2)

				if self._inst1 == self._inst2 then
					return {
						status = 500,
						message = "Reference is old reference",
					}
				end

				self._replaced = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "target",
			run = function(self)
				if not self._replaced then
					return { status = 200, message = "Passed" }
				end

				if self._inst1 == game:GetService("Stats") then
					return {
						status = 500,
						message = "Reference is old references object",
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
