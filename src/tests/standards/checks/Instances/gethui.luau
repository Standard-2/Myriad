--!nocheck
--!nolint

return {
	global = "gethui",
	aliases = {
		"get_hidden_gui",
	},
	cases = {
		{
			id = "class",
			run = function(self)
				local container = gethui()
				self._container = container
				self._checked = true
				if not (container:IsA("ScreenGui") or container:IsA("BasePlayerGui") or container:IsA("Folder")) then
					return {
						status = 500,
						message = "Container is not a ScreenGui, BasePlayerGui, or Folder",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "coregui",
			run = function(self)
				if not self._checked then
					return { status = 200, message = `Passed` }
				end

				if self._container == game:GetService("CoreGui") then
					return {
						status = 500,
						message = "Container cannot be an uncloned reference to CoreGui",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
