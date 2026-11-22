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
		{
			id = "color",
			run = function(self)
				local drawing = Drawing.new("Line")
				local expected = Color3.fromRGB(20, 40, 60)
				drawing.Color = expected

				local color = getrenderproperty(drawing, "Color")
				drawing:Destroy()

				if color ~= expected then
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
		{
			id = "from",
			run = function(self)
				local drawing = Drawing.new("Line")
				local expected = Vector2.new(3, 9)
				drawing.From = expected

				local from = getrenderproperty(drawing, "From")
				drawing:Destroy()

				if from ~= expected then
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
		{
			id = "text",
			run = function(self)
				local drawing = Drawing.new("Text")
				drawing.Text = "cedar-mark"

				local text = getrenderproperty(drawing, "Text")
				drawing:Destroy()

				if text ~= "cedar-mark" then
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
