--!nocheck
--!nolint

return {
	global = "isscriptable",
	cases = {
		{
			id = "Name",
			run = function(self)
				local originalPart = Instance.new("Part")
				self._part = originalPart

				if not isscriptable(originalPart, "Name") then
					return {
						status = 500,
						message = "Accessible property 'Name' assumed inaccessible",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "MaterialVariantSerialized",
			run = function(self)
				local originalPart = self._part
				if originalPart == nil then
					return { status = 200, message = "Passed" }
				end

				if isscriptable(originalPart, "MaterialVariantSerialized") then
					return {
						status = 500,
						message = "Inaccessible property 'MaterialVariantSerialized' assumed accessible",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
