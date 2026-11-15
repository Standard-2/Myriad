--!nocheck
--!nolint

return {
	global = "setrenderproperty",
	dependencies = {
		globals = {
			{ name = "Drawing.new", message = "Drawing library needed to test this" },
		},
	},
	cases = {
		{
			id = "write",
			run = function(self)
				local drawing = Drawing.new("Line")
				setrenderproperty(drawing, "Thickness", 2)
				setrenderproperty(drawing, "Visible", false)

				if drawing.Thickness ~= 2 or drawing.Visible ~= false then
					return {
						status = 500,
						message = "Incorrect property value",
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
