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
		{
			id = "color",
			run = function(self)
				local drawing = Drawing.new("Line")
				local expected = Color3.fromRGB(11, 22, 33)
				setrenderproperty(drawing, "Color", expected)

				local color = drawing.Color
				drawing:Destroy()

				if color ~= expected then
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
		{
			id = "from",
			run = function(self)
				local drawing = Drawing.new("Line")
				local expected = Vector2.new(8, 5)
				setrenderproperty(drawing, "From", expected)

				local from = drawing.From
				drawing:Destroy()

				if from ~= expected then
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
		{
			id = "text",
			run = function(self)
				local drawing = Drawing.new("Text")
				setrenderproperty(drawing, "Text", "brine-mark")

				local text = drawing.Text
				drawing:Destroy()

				if text ~= "brine-mark" then
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
