--!nocheck
--!nolint

return {
	global = "isrenderobj",
	dependencies = {
		globals = {
			{ name = "Drawing.new", message = "Drawing library needed to test this" },
		},
	},
	cases = {
		{
			id = "render",
			run = function(self)
				local drawing = Drawing.new("Line")
				drawing.Visible = false

				if not isrenderobj(drawing) then
					return {
						status = 500,
						message = "Didn't return true for a render object",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "non-render",
			run = function(self)
				if isrenderobj({}) or isrenderobj(game:GetService("Workspace")) then
					return {
						status = 500,
						message = "Returned true for a non-render object",
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
