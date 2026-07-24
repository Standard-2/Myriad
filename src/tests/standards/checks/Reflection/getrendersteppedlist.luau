--!nocheck
--!nolint

local RunService = game:GetService("RunService")

return function()
	if type(getrendersteppedlist) ~= "function" then
		return { status = 400, message = "Global not found" }
	end

	local s, list = pcall(getrendersteppedlist)
	if not s then
		return { status = 0, message = `Ambiguous error: {list}` }
	elseif type(list) ~= "table" then
		return { status = 500, message = "Return type is not a table" }
	end

	local testName = "MyriadTest_RenderStep"
	local priority = 200

	local bindSuccess, bindErr = pcall(function()
		RunService:BindToRenderStep(testName, priority, function() end)
	end)
	if not bindSuccess then
		return { status = 500, message = `Failed to bind render step: {bindErr}` }
	end

	local function cleanup()
		pcall(function()
			RunService:UnbindFromRenderStep(testName)
		end)
	end

	local fetchSuccess, newMatches = pcall(getrendersteppedlist)
	if not fetchSuccess or type(newMatches) ~= "table" then
		cleanup()
		return { status = 500, message = "Failed to retrieve render step list after binding" }
	end

	local foundEntry
	for _, entry in ipairs(newMatches) do
		if type(entry) == "table" and entry.Name == testName then
			foundEntry = entry
			break
		end
	end

	if not foundEntry then
		cleanup()
		return { status = 500, message = "Bound render step was not found in getrendersteppedlist" }
	end

	local expectedTypes = {
		Name = "string",
		Priority = "number",
		Function = "function",
		Thread = "thread",
	}

	for prop, expectedType in pairs(expectedTypes) do
		local val = foundEntry[prop]
		if type(val) ~= expectedType then
			cleanup()
			return {
				status = 500,
				message = `Expected {prop} property to be {expectedType}, got {type(val)}`,
			}
		end
	end

	if foundEntry.Priority ~= priority then
		cleanup()
		return { status = 500, message = `Expected Priority to be {priority}, got {foundEntry.Priority}` }
	end

	cleanup()

	local _, afterUnbind = pcall(getrendersteppedlist)
	if type(afterUnbind) == "table" then
		for _, entry in ipairs(afterUnbind) do
			if type(entry) == "table" and entry.Name == testName then
				return { status = 500, message = "Unbound render step was still present in getrendersteppedlist" }
			end
		end
	end

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({})
	if not envIndex then
		return { status = 501, message = `Alias not found: {failedIndex}` }
	end

	return { status = 200, message = "Passed" }
end
