--!nocheck
--!nolint

return {
	global = "getrenderproperty",
	dependencies = {
		globals = {
			{ name = "Drawing.new", message = "Drawing library needed to test this" },
		},
	},
	cases = {
		{
			id = "read",
			run = function(self)
				local drawing = Drawing.new("Line")
				drawing.Thickness = 2
				drawing.Visible = false

				local thickness = getrenderproperty(drawing, "Thickness")
				local visible = getrenderproperty(drawing, "Visible")

				if thickness ~= 2 or visible ~= false then
					return {
						status = 500,
						message = "Property not found or mismatch",
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
