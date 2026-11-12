--!nocheck
--!nolint

return {
	global = "sethiddenproperty",
	dependencies = {
		globals = {
			"gethiddenproperty",
		},
	},
	cases = {
		{
			id = "shape",
			run = function(self)
				local originalPart = Instance.new("Part")
				self._part = originalPart

				local shapeOptions = { "CornerWedge", "Wedge", "Ball", "Cylinder" }
				local shapeOption = shapeOptions[math.random(1, #shapeOptions)]
				local shapeSetOk, shapeSetErr =
					pcall(sethiddenproperty, originalPart, "shape", Enum.PartType[shapeOption])
				if not shapeSetOk then
					return {
						status = 500,
						message = `Failed to set shape: {shapeSetErr}`,
					}
				end

				local shapeValue, shapeHidden = gethiddenproperty(originalPart, "shape")
				if shapeValue ~= Enum.PartType[shapeOption] then
					return {
						status = 500,
						message = "Hidden property's value was incorrectly set",
					}
				elseif shapeHidden ~= true then
					return {
						status = 500,
						message = "Hidden property Part.shape was reported scriptable after set",
					}
				elseif originalPart.Shape ~= Enum.PartType[shapeOption] then
					return {
						status = 500,
						message = "It changed .shape but not .Shape, it should change accordingly, weird",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "size",
			run = function(self)
				local originalPart = self._part
				if originalPart == nil then
					return { status = 200, message = "Passed" }
				end

				local sized = Vector3.new(3.25, 7.5, 0.5)
				local sizeSetOk, sizeSetErr = pcall(sethiddenproperty, originalPart, "size", sized)
				if not sizeSetOk then
					return {
						status = 500,
						message = `Failed to set size: {sizeSetErr}`,
					}
				end

				local sizeValue, sizeHidden = gethiddenproperty(originalPart, "size")
				if sizeValue ~= sized then
					return {
						status = 500,
						message = "Hidden property BasePart.size was incorrectly set",
					}
				elseif sizeHidden ~= true then
					return {
						status = 500,
						message = "Hidden property BasePart.size was reported scriptable after set",
					}
				elseif originalPart.Size ~= sized then
					return {
						status = 500,
						message = "It changed .size but not .Size",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "size_xml",
			run = function(self)
				local fire = Instance.new("Fire")
				self._fire = fire

				local xmlSetOk, xmlSetErr = pcall(sethiddenproperty, fire, "size_xml", 11)
				if not xmlSetOk then
					return {
						status = 500,
						message = `Failed to set size_xml: {xmlSetErr}`,
					}
				end

				local xmlValue, xmlHidden = gethiddenproperty(fire, "size_xml")
				if xmlValue ~= 11 then
					return {
						status = 500,
						message = "Hidden property Fire.size_xml was incorrectly set",
					}
				elseif xmlHidden ~= true then
					return {
						status = 500,
						message = "Hidden property Fire.size_xml was reported scriptable after set",
					}
				elseif fire.Size ~= 11 then
					return {
						status = 500,
						message = "It changed .size_xml but not .Size",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "TrussPart shape",
			run = function(self)
				local truss = Instance.new("TrussPart")
				self._truss = truss

				local trussShapeOk = pcall(sethiddenproperty, truss, "shape", Enum.PartType.Ball)
				if trussShapeOk then
					return {
						status = 500,
						message = "Part.shape was set on a TrussPart",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "siz",
			run = function(self)
				local originalPart = self._part
				if originalPart == nil then
					return { status = 200, message = "Passed" }
				end

				local sized = Vector3.new(3.25, 7.5, 0.5)
				local sizOk = pcall(sethiddenproperty, originalPart, "siz", sized)
				if sizOk then
					return {
						status = 500,
						message = "BasePart.siz was removed",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "nil",
			run = function(self)
				local nilOk = pcall(sethiddenproperty, nil, "Name", "x")
				if nilOk then
					return {
						status = 500,
						message = "Missing instance was accepted",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "number",
			run = function(self)
				local originalPart = self._part
				if originalPart == nil then
					return { status = 200, message = "Passed" }
				end

				local numberOk = pcall(sethiddenproperty, originalPart, 1, "x")
				if numberOk then
					return {
						status = 500,
						message = "Property name was coerced from a number",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "signal",
			run = function(self)
				local signalOk = pcall(sethiddenproperty, game.Close, "Name", "x")
				if signalOk then
					return {
						status = 500,
						message = "RBXScriptSignal was accepted as an Instance",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "proxy",
			run = function(self)
				local proxy = newproxy(true)
				getmetatable(proxy).__type = "Instance"
				local spoofOk = pcall(sethiddenproperty, proxy, "Name", "x")
				if spoofOk then
					return {
						status = 500,
						message = 'A userdata with __type = "Instance" was accepted',
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "cleanup",
			run = function(self)
				if self._part then
					self._part:Destroy()
				end
				if self._fire then
					self._fire:Destroy()
				end
				if self._truss then
					self._truss:Destroy()
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
