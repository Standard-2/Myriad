--!nocheck
--!nolint

return function()
	if not sethiddenproperty then
		return {
			status = 400,
			message = "Global not found",
		}
	elseif not gethiddenproperty then
		return {
			status = 401,
			message = "Dependant global 'gethiddenproperty' not found",
		}
	end

	local originalPart = Instance.new("Part")

	local shapeOptions = { "CornerWedge", "Wedge", "Ball", "Cylinder" }
	local shapeOption = shapeOptions[math.random(1, #shapeOptions)]
	local shapeSetOk, shapeSetErr = pcall(sethiddenproperty, originalPart, "shape", Enum.PartType[shapeOption])
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

	local fire = Instance.new("Fire")
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

	local truss = Instance.new("TrussPart")
	local trussShapeOk = pcall(sethiddenproperty, truss, "shape", Enum.PartType.Ball)
	if trussShapeOk then
		return {
			status = 500,
			message = "Part.shape was set on a TrussPart",
		}
	end

	local sizOk = pcall(sethiddenproperty, originalPart, "siz", sized)
	if sizOk then
		return {
			status = 500,
			message = "BasePart.siz was removed",
		}
	end

	local nilOk = pcall(sethiddenproperty, nil, "Name", "x")
	if nilOk then
		return {
			status = 500,
			message = "Missing instance was accepted",
		}
	end

	local numberOk = pcall(sethiddenproperty, originalPart, 1, "x")
	if numberOk then
		return {
			status = 500,
			message = "Property name was coerced from a number",
		}
	end

	local signalOk = pcall(sethiddenproperty, game.Close, "Name", "x")
	if signalOk then
		return {
			status = 500,
			message = "RBXScriptSignal was accepted as an Instance",
		}
	end

	local proxy = newproxy(true)
	getmetatable(proxy).__type = "Instance"
	local spoofOk = pcall(sethiddenproperty, proxy, "Name", "x")
	if spoofOk then
		return {
			status = 500,
			message = "A userdata with __type = \"Instance\" was accepted",
		}
	end

	originalPart:Destroy()
	fire:Destroy()
	truss:Destroy()

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({})

	if not envIndex then
		return {
			status = 501,
			message = `Alias not found: {failedIndex}`,
		}
	end

	return {
		status = 200,
		message = `Passed`,
	}
end
