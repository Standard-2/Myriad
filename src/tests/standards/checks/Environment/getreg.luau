--!nocheck
--!nolint

return {
	global = "getreg",
	cases = {
		{
			id = "table",
			run = function(self)
				local registry = getreg()

				if type(registry) ~= "table" then
					return {
						status = 500,
						message = "Did not return a table",
					}
				end

				self._registry = registry

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "items",
			run = function(self)
				if type(self._registry) ~= "table" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local registry = self._registry
				local foundItems = false
				for k, v in pairs(registry) do
					foundItems = true
					break
				end

				if not foundItems then
					return {
						status = 500,
						message = "Registry is empty",
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
