--!nocheck
--!nolint

local function missingProperty(instance, objectName, property)
	local success, value = pcall(function()
		return instance[property]
	end)
	if not success or value == nil then
		instance:Destroy()
		return {
			status = 500,
			message = `{objectName} is missing property: {property} (Did you give it a default value?)`,
		}
	end
	return nil
end

local drawings = {
	-- Line
	{
		id = "line",
		className = "Line",
		missing = "Line drawing object not found",
		field = "_line",
		properties = {
			{ id = "visible", name = "Visible" },
			{ id = "zindex", name = "ZIndex" },
			{ id = "transparency", name = "Transparency" },
			{ id = "color", name = "Color" },
			{ id = "object-exists", name = "__OBJECT_EXISTS" },
			{ id = "destroy", name = "Destroy" },
			{ id = "thickness", name = "Thickness" },
			{ id = "from", name = "From" },
			{ id = "to", name = "To" },
		},
	},
	-- Text
	{
		id = "text",
		className = "Text",
		missing = "Text drawing object not found",
		field = "_text",
		properties = {
			{ id = "visible", name = "Visible" },
			{ id = "zindex", name = "ZIndex" },
			{ id = "transparency", name = "Transparency" },
			{ id = "color", name = "Color" },
			{ id = "object-exists", name = "__OBJECT_EXISTS" },
			{ id = "destroy", name = "Destroy" },
			{ id = "text", name = "Text" },
			{ id = "text-bounds", name = "TextBounds" },
			{ id = "center", name = "Center" },
			{ id = "size", name = "Size" },
			{ id = "font", name = "Font" },
			{ id = "outline", name = "Outline" },
			{ id = "outline-color", name = "OutlineColor" },
			{ id = "position", name = "Position" },
		},
	},
	-- Image
	{
		id = "image",
		className = "Image",
		missing = "Image drawing object not found",
		field = "_image",
		properties = {
			{ id = "visible", name = "Visible" },
			{ id = "zindex", name = "ZIndex" },
			{ id = "transparency", name = "Transparency" },
			{ id = "color", name = "Color" },
			{ id = "object-exists", name = "__OBJECT_EXISTS" },
			{ id = "destroy", name = "Destroy" },
			{ id = "data", name = "Data" },
			{ id = "size", name = "Size" },
			{ id = "position", name = "Position" },
		},
	},
	-- Circle
	{
		id = "circle",
		className = "Circle",
		missing = "Circle drawing object not found",
		field = "_circle",
		properties = {
			{ id = "visible", name = "Visible" },
			{ id = "zindex", name = "ZIndex" },
			{ id = "transparency", name = "Transparency" },
			{ id = "color", name = "Color" },
			{ id = "object-exists", name = "__OBJECT_EXISTS" },
			{ id = "destroy", name = "Destroy" },
			{ id = "num-sides", name = "NumSides" },
			{ id = "radius", name = "Radius" },
			{ id = "position", name = "Position" },
			{ id = "thickness", name = "Thickness" },
			{ id = "filled", name = "Filled" },
		},
	},
	-- Square
	{
		id = "square",
		className = "Square",
		missing = "Square drawing object not found",
		field = "_square",
		properties = {
			{ id = "visible", name = "Visible" },
			{ id = "zindex", name = "ZIndex" },
			{ id = "transparency", name = "Transparency" },
			{ id = "color", name = "Color" },
			{ id = "object-exists", name = "__OBJECT_EXISTS" },
			{ id = "destroy", name = "Destroy" },
			{ id = "size", name = "Size" },
			{ id = "position", name = "Position" },
			{ id = "thickness", name = "Thickness" },
			{ id = "filled", name = "Filled" },
		},
	},
	-- Quad
	{
		id = "quad",
		className = "Quad",
		missing = "Quad drawing object not found",
		field = "_quad",
		properties = {
			{ id = "destroy", name = "Destroy" },
			{ id = "visible", name = "Visible" },
			{ id = "zindex", name = "ZIndex" },
			{ id = "transparency", name = "Transparency" },
			{ id = "color", name = "Color" },
			{ id = "object-exists", name = "__OBJECT_EXISTS" },
			{ id = "point-a", name = "PointA" },
			{ id = "point-b", name = "PointB" },
			{ id = "point-c", name = "PointC" },
			{ id = "point-d", name = "PointD" },
			{ id = "thickness", name = "Thickness" },
			{ id = "filled", name = "Filled" },
		},
	},
	-- Triangle
	{
		id = "triangle",
		className = "Triangle",
		missing = "Triangle drawing object not found",
		field = "_triangle",
		properties = {
			{ id = "destroy", name = "Destroy" },
			{ id = "visible", name = "Visible" },
			{ id = "zindex", name = "ZIndex" },
			{ id = "transparency", name = "Transparency" },
			{ id = "color", name = "Color" },
			{ id = "object-exists", name = "__OBJECT_EXISTS" },
			{ id = "point-a", name = "PointA" },
			{ id = "point-b", name = "PointB" },
			{ id = "point-c", name = "PointC" },
			{ id = "thickness", name = "Thickness" },
			{ id = "filled", name = "Filled" },
		},
	},
}

local cases = {
	{
		id = "api",
		run = function(self)
			if not Drawing or not Drawing.new then
				return {
					status = 400,
					message = "Global Drawing API not found",
				}
			end

			self._api = true

			return {
				status = 200,
				message = "Passed",
			}
		end,
	},
}

for _, drawing in ipairs(drawings) do
	local field = drawing.field
	local className = drawing.className
	local missing = drawing.missing
	local caseId = drawing.id

	table.insert(cases, {
		id = caseId,
		run = function(self)
			if not self._api then
				return {
					status = 200,
					message = "Passed",
				}
			end

			local object = Drawing.new(className)
			if not object then
				return {
					status = 500,
					message = missing,
				}
			end

			self[field] = object

			return {
				status = 200,
				message = "Passed",
			}
		end,
	})

	for _, propertyInfo in ipairs(drawing.properties) do
		local propertyName = propertyInfo.name
		local propertyId = propertyInfo.id

		table.insert(cases, {
			id = caseId .. "-" .. propertyId,
			run = function(self)
				local instance = self[field]
				if not instance then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local objectName = className
				local property = propertyName
				local result = missingProperty(instance, objectName, property)
				if result then
					self[field] = nil
					return result
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		})
	end
end

table.insert(cases, {
	id = "screen-gui",
	run = function(self)
		if not self._api then
			return {
				status = 200,
				message = "Passed",
			}
		end

		-- Lua drawing lib
		local x1, y1, z1 = math.random(1, 255), math.random(1, 255), math.random(1, 255)
		local parent = gethui and gethui() or game:GetService("CoreGui")
		local refObj = Drawing.new("Line")

		refObj.Color = Color3.fromRGB(x1, y1, z1)
		refObj.Transparency = 1 - x1 / 255

		if parent then
			for i, v in pairs(parent:GetDescendants()) do
				if v:IsA("Frame") and v.BackgroundColor3 == refObj.Color then
					local raw = math.abs(v.BackgroundTransparency - refObj.Transparency) < 0.01
					local alpha = math.abs(v.BackgroundTransparency - (1 - refObj.Transparency)) < 0.01

					if raw or alpha then
						return {
							status = 500,
							message = "Drawing library almost certainly depends on ScreenGui",
						}
					end
				end
			end
		end

		return {
			status = 200,
			message = "Passed",
		}
	end,
})

return {
	cases = cases,
}
