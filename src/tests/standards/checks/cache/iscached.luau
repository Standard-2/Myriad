--!nocheck
--!nolint

return {
	global = "cache.iscached",
	dependencies = {
		globals = {
			{ name = "cache.invalidate", message = "Dependency 'cache.invalidate' missing" },
		},
	},
	cases = {
		{
			id = "part",
			run = function(self)
				--// Functionality test
				local part = Instance.new("Part")
				local part2 = Instance.new("Part", game)
				self._part = part
				self._part2 = part2

				if not cache.iscached(part) then
					return {
						status = 500,
						message = "Cached part assumed uncached",
					}
				end

				self._partCached = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "workspace",
			run = function(self)
				if self._part2 == nil then
					return { status = 200, message = "Passed" }
				end

				if not cache.iscached(self._part2) then
					return {
						status = 500,
						message = "Cached part in Workspace assumed uncached",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "invalidated",
			run = function(self)
				if not self._partCached then
					return { status = 200, message = "Passed" }
				end

				cache.invalidate(self._part)

				if cache.iscached(self._part) then
					return {
						status = 500,
						message = "Uncached part assumed cached",
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
