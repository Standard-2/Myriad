--!nocheck
--!nolint

return {
	global = "setscriptable",
	cases = {
		{
			id = "initial",
			run = function(self)
				local originalPart = Instance.new("Part")
				self._part = originalPart

				if pcall(function()
					local _ = originalPart.MaterialVariantSerialized
				end) then
					return {
						status = 500,
						message = "Unaccessible property accessible",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "scriptable",
			run = function(self)
				local originalPart = self._part
				if originalPart == nil then
					return { status = 200, message = "Passed" }
				end

				setscriptable(originalPart, "MaterialVariantSerialized", true)
				if not pcall(function()
					local _ = originalPart.MaterialVariantSerialized
				end) then
					return {
						status = 500,
						message = "MaterialVariantSerialized inaccessible after being set as scriptable",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "unscriptable",
			run = function(self)
				local originalPart = self._part
				if originalPart == nil then
					return { status = 200, message = "Passed" }
				end

				setscriptable(originalPart, "MaterialVariantSerialized", false)
				if pcall(function()
					local _ = originalPart.MaterialVariantSerialized
				end) then
					return {
						status = 500,
						message = "MaterialVariantSerialized accessible after being set as unscriptable",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
