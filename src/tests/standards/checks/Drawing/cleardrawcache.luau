--!nocheck
--!nolint

return {
	global = "cleardrawcache",
	dependencies = {
		globals = {
			{ name = "Drawing.new", message = "Drawing library needed to test this" },
		},
	},
	cases = {
		{
			id = "cleared",
			run = function(self)
				local drawing = Drawing.new("Line")
				drawing.Visible = false
				drawing.Thickness = 2

				task.defer(cleardrawcache)
				task.wait(0.1)
				if drawing.__OBJECT_EXISTS then
					return {
						status = 500,
						message = "Drawing exists after draw clear",
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
