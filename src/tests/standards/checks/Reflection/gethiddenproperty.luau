--!nocheck
--!nolint

return function()
	if not gethiddenproperty then
		return {
			status = 400,
			message = "Global not found",
		}
	end

	--// Functionality test
	local part = Instance.new("Part")
	part.Name = "Part"
	local sized = Vector3.new(3.25, 7.5, 0.5)
	part.Size = sized
	part.Color = Color3.fromRGB(12, 34, 56)
	part.Shape = Enum.PartType.Ball

	local prop1Value, prop1Hidden = gethiddenproperty(part, "Name")
	local prop2Value, prop2Hidden = gethiddenproperty(part, "PropertyStatusStudio")
	local prop3Value, prop3Hidden = gethiddenproperty(workspace, "DataModelPlaceVersion")
	local prop4Success, prop4Value, prop4Hidden = pcall(gethiddenproperty, workspace, "CollisionGroups")

	-- Name
	if prop1Hidden ~= false then
		return {
			status = 500,
			message = "Non-hidden property assumed hidden",
		}
	elseif prop1Value ~= "Part" then
		return {
			status = 500,
			message = "Non-hidden property value incorrect, ensure you still return values for non-hidden properties.",
		}

		-- PropertyStatusStudio
	elseif prop2Hidden ~= true then
		return {
			status = 500,
			message = "Hidden property assumed non-hidden",
		}
	elseif prop2Value ~= Enum.PropertyStatus.Ok then
		return {
			status = 500,
			message = "Hidden property value incorrect",
		}
	elseif prop3Hidden ~= true then
		return {
			status = 500,
			message = "Hidden property assumed non-hidden in workspace",
		}
	elseif prop3Value ~= game.PlaceVersion then
		-- Some exploits just wait for the values to be the defaults
		return {
			status = 500,
			message = "Hidden property value incorrect in workspace",
		}
	elseif prop4Success and prop4Hidden ~= true then
		return {
			status = 500,
			message = "Write-only hidden property assumed non-hidden",
		}
	elseif prop4Success and prop4Value ~= nil then
		return {
			status = 500,
			message = "Write-only hidden property value incorrect",
		}
	elseif not prop4Success and string.find(tostring(prop4Value), "can't get value", 1, true) == nil then
		return {
			status = 500,
			message = "Failed to get Write-only hidden property",
		}
	end

	local scriptSize, scriptSizeHidden = gethiddenproperty(part, "Size")
	if scriptSizeHidden ~= false then
		return {
			status = 500,
			message = "Scriptable property Size was reported hidden",
		}
	elseif typeof(scriptSize) ~= "Vector3" or scriptSize ~= sized then
		return {
			status = 500,
			message = "Scriptable property Size returned the wrong Vector3",
		}
	end

	-- BasePart.size
	local aliasValue, aliasHidden = gethiddenproperty(part, "size")
	if aliasHidden ~= true then
		return {
			status = 500,
			message = "Hidden property BasePart.size was reported scriptable",
		}
	elseif typeof(aliasValue) ~= "Vector3" or aliasValue ~= part.Size then
		return {
			status = 500,
			message = "Hidden property BasePart.size did not track Size",
		}
	end

	local truss = Instance.new("TrussPart")
	truss.Size = Vector3.new(2, 8.5, 2)
	local trussSize, trussHidden = gethiddenproperty(truss, "size")
	if trussHidden ~= true then
		return {
			status = 500,
			message = "Inherited BasePart.size was reported scriptable on TrussPart",
		}
	elseif typeof(trussSize) ~= "Vector3" or trussSize ~= truss.Size then
		return {
			status = 500,
			message = "Inherited BasePart.size did not track TrussPart.Size",
		}
	end

	local shapeOnTruss = pcall(gethiddenproperty, truss, "shape")
	if shapeOnTruss then
		return {
			status = 500,
			message = "Part.shape resolved on a TrussPart",
		}
	end

	local shapeValue, shapeHidden = gethiddenproperty(part, "shape")
	if shapeHidden ~= true then
		return {
			status = 500,
			message = "Hidden property Part.shape was reported scriptable",
		}
	elseif shapeValue ~= part.Shape then
		return {
			status = 500,
			message = "Hidden property Part.shape did not track Shape",
		}
	end

	-- formFactor
	local formValue, formHidden = gethiddenproperty(part, "FormFactor")
	if formHidden ~= false then
		return {
			status = 500,
			message = "Scriptable property FormFactor was reported hidden",
		}
	elseif formValue ~= Enum.FormFactor.Brick then
		return {
			status = 500,
			message = "FormFactor did not return Enum.FormFactor.Brick",
		}
	end

	local legacyForm, legacyFormHidden = gethiddenproperty(part, "formFactor")
	if legacyFormHidden ~= false then
		return {
			status = 500,
			message = "Deprecated property formFactor was reported hidden",
		}
	elseif legacyForm ~= formValue then
		return {
			status = 500,
			message = "formFactor did not track FormFactor",
		}
	end

	local rawValue, rawHidden = gethiddenproperty(part, "formFactorRaw")
	if rawHidden ~= true then
		return {
			status = 500,
			message = "Hidden property formFactorRaw was reported scriptable",
		}
	elseif rawValue ~= formValue then
		return {
			status = 500,
			message = "formFactorRaw did not track FormFactor",
		}
	end

	local rawOnTruss = pcall(gethiddenproperty, truss, "formFactorRaw")
	if rawOnTruss then
		return {
			status = 500,
			message = "FormFactorPart.formFactorRaw resolved on a TrussPart",
		}
	end

	part.Archivable = false
	local legacyArchivable, legacyArchivableHidden = gethiddenproperty(part, "archivable")
	if legacyArchivableHidden ~= false then
		return {
			status = 500,
			message = "Deprecated property archivable was reported hidden",
		}
	elseif legacyArchivable ~= part.Archivable then
		return {
			status = 500,
			message = "archivable did not track Archivable",
		}
	end

	part.Name = "MyriadPart"
	local className, classNameHidden = gethiddenproperty(part, "className")
	if classNameHidden ~= false then
		return {
			status = 500,
			message = "Deprecated property className was reported hidden",
		}
	elseif className ~= part.ClassName then
		return {
			status = 500,
			message = "className did not track ClassName",
		}
	end

	local fire = Instance.new("Fire")
	fire.Size = 11
	fire.Heat = -4

	local fireSize, fireSizeHidden = gethiddenproperty(fire, "size")
	if fireSizeHidden ~= false then
		return {
			status = 500,
			message = "Scriptable property Fire.size was reported hidden",
		}
	elseif fireSize ~= fire.Size then
		return {
			status = 500,
			message = "Fire.size did not track Size",
		}
	end

	local fireXml, fireXmlHidden = gethiddenproperty(fire, "size_xml")
	if fireXmlHidden ~= true then
		return {
			status = 500,
			message = "Hidden property Fire.size_xml was reported scriptable",
		}
	elseif fireXml ~= fire.Size then
		return {
			status = 500,
			message = "Fire.size_xml did not track Size",
		}
	end

	local heatXml, heatHidden = gethiddenproperty(fire, "heat_xml")
	if heatHidden ~= true then
		return {
			status = 500,
			message = "Hidden property Fire.heat_xml was reported scriptable",
		}
	elseif heatXml ~= fire.Heat then
		return {
			status = 500,
			message = "Fire.heat_xml did not track Heat",
		}
	end

	local xmlOnPart = pcall(gethiddenproperty, part, "size_xml")
	if xmlOnPart then
		return {
			status = 500,
			message = "Fire.size_xml resolved on a Part",
		}
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.Health = 37.25
	local healthXml, healthXmlHidden = gethiddenproperty(humanoid, "Health_XML")
	if healthXmlHidden ~= true then
		return {
			status = 500,
			message = "Hidden property Health_XML was reported scriptable",
		}
	elseif healthXml ~= 37.25 then
		return {
			status = 500,
			message = "Health_XML did not track Health",
		}
	end

	local colorOk, colorValue, colorHidden = pcall(gethiddenproperty, part, "Color3uint8")
	if not colorOk then
		return {
			status = 500,
			message = `Color3uint8 read failed: {colorValue}`,
		}
	elseif colorHidden ~= true then
		return {
			status = 500,
			message = "Hidden property Color3uint8 was reported scriptable",
		}
	elseif typeof(colorValue) ~= "Color3" or colorValue ~= part.Color then
		return {
			status = 500,
			message = "Color3uint8 did not come back as the part Color3",
		}
	end

	local tagged = Instance.new("Part")
	tagged:AddTag("myriad-alpha")
	tagged:AddTag("myriad-beta")
	local tagsValue, tagsHidden = gethiddenproperty(tagged, "Tags")
	local tagsText = if typeof(tagsValue) == "buffer" then buffer.tostring(tagsValue) else tagsValue
	if tagsHidden ~= true then
		return {
			status = 500,
			message = "Hidden property Tags was reported scriptable",
		}
	elseif typeof(tagsText) ~= "string" then
		return {
			status = 500,
			message = `Tags should be a SharedString, got {typeof(tagsValue)}`,
		}
	elseif tagsText == "<write only>" or tagsText == "<blob>" or tagsText == "<faulted>" or tagsText == "<server only>" or tagsText == "<not printable>" then
		return {
			status = 500,
			message = "Tags came back as a display stub",
		}
	elseif string.find(tagsText, "myriad-alpha", 1, true) == nil or string.find(tagsText, "myriad-beta", 1, true) == nil or string.find(tagsText, "\0", 1, true) == nil then
		return {
			status = 500,
			message = "Tags shared string dropped a tag or its NUL separator",
		}
	end

	local attributed = Instance.new("Part")
	attributed:SetAttribute("MyriadAttr", true)
	local attrValue, attrHidden = gethiddenproperty(attributed, "AttributesSerialize")
	local attrText = if typeof(attrValue) == "buffer" then buffer.tostring(attrValue) else attrValue
	if attrHidden ~= true then
		return {
			status = 500,
			message = "Hidden property AttributesSerialize was reported scriptable",
		}
	elseif typeof(attrText) ~= "string" or attrText == "" or attrText == "<blob>" or attrText == "<write only>" or attrText == "<faulted>" or attrText == "<server only>" or attrText == "<not printable>" then
		return {
			status = 500,
			message = "AttributesSerialize was empty or a display stub",
		}
	elseif string.find(attrText, "MyriadAttr", 1, true) == nil then
		return {
			status = 500,
			message = "AttributesSerialize did not contain the attribute name",
		}
	end

	local nilPhys, nilPhysHidden = gethiddenproperty(part, "CustomPhysicalProperties")
	if nilPhysHidden ~= false then
		return {
			status = 500,
			message = "Scriptable property CustomPhysicalProperties was reported hidden",
		}
	elseif nilPhys ~= nil then
		return {
			status = 500,
			message = "CustomPhysicalProperties should be nil before it is assigned",
		}
	end

	part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
	local physValue, physHidden = gethiddenproperty(part, "CustomPhysicalProperties")
	if physHidden ~= false then
		return {
			status = 500,
			message = "CustomPhysicalProperties was reported hidden after assign",
		}
	elseif typeof(physValue) ~= "PhysicalProperties" then
		return {
			status = 500,
			message = `CustomPhysicalProperties should be PhysicalProperties, got {typeof(physValue)}`,
		}
	elseif physValue.Density ~= part.CustomPhysicalProperties.Density or physValue.Friction ~= part.CustomPhysicalProperties.Friction or physValue.Elasticity ~= part.CustomPhysicalProperties.Elasticity then
		return {
			status = 500,
			message = "CustomPhysicalProperties did not round-trip",
		}
	end

	local groupOk, groupValue, groupHidden = pcall(gethiddenproperty, workspace, "CollisionGroupData")
	local groupText = if typeof(groupValue) == "buffer" then buffer.tostring(groupValue) else groupValue
	if not groupOk then
		return {
			status = 500,
			message = `CollisionGroupData read failed: {groupValue}`,
		}
	elseif groupHidden ~= true then
		return {
			status = 500,
			message = "Hidden property CollisionGroupData was reported scriptable",
		}
	elseif typeof(groupText) ~= "string" or groupText == "" or groupText == "<blob>" or groupText == "<write only>" or string.find(groupText, "Default", 1, true) == nil then
		return {
			status = 500,
			message = "CollisionGroupData did not contain the Default collision group",
		}
	end

	local commandBin = Instance.new("HopperBin")
	local commandOk, commandValue, commandHidden = pcall(gethiddenproperty, commandBin, "Command")
	if commandOk and commandHidden ~= true then
		return {
			status = 500,
			message = "Write-only property HopperBin.Command was reported scriptable",
		}
	elseif commandOk and commandValue ~= nil then
		return {
			status = 500,
			message = "Write-only property HopperBin.Command returned a value",
		}
	elseif not commandOk and string.find(tostring(commandValue), "can't get value", 1, true) == nil then
		return {
			status = 500,
			message = "Failed to get Write-only hidden property HopperBin.Command",
		}
	end

	local sizOk = pcall(gethiddenproperty, part, "siz")
	if sizOk then
		return {
			status = 500,
			message = "BasePart.siz was removed",
		}
	end

	local lowerNameOk = pcall(gethiddenproperty, part, "name")
	if lowerNameOk then
		return {
			status = 500,
			message = "Property name lookup was case-insensitive",
		}
	end

	local shapOk = pcall(gethiddenproperty, part, "shap")
	if shapOk then
		return {
			status = 500,
			message = "Part.shap was removed",
		}
	end

	local missingOk = pcall(gethiddenproperty, part, "MyriadNoSuchProperty")
	if missingOk then
		return {
			status = 500,
			message = "Unknown property returned a value",
		}
	end

	local numberOk = pcall(gethiddenproperty, part, 1)
	if numberOk then
		return {
			status = 500,
			message = "Property name was coerced from a number",
		}
	end

	local nilOk = pcall(gethiddenproperty, nil, "Name")
	if nilOk then
		return {
			status = 500,
			message = "Missing instance was accepted",
		}
	end

	local signalOk = pcall(gethiddenproperty, game.Close, "Name")
	if signalOk then
		return {
			status = 500,
			message = "RBXScriptSignal was accepted as an Instance",
		}
	end

	local proxy = newproxy(true)
	getmetatable(proxy).__type = "Instance"
	local spoofOk = pcall(gethiddenproperty, proxy, "Name")
	if spoofOk then
		return {
			status = 500,
			message = "A userdata with __type = \"Instance\" was accepted",
		}
	end

	part:Destroy()
	truss:Destroy()
	fire:Destroy()
	humanoid:Destroy()
	tagged:Destroy()
	attributed:Destroy()
	commandBin:Destroy()

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
