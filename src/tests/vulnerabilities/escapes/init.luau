local parentVectors = require("@self/vectors")
local result = require("@vulnerabilities/result")

local function hasFunction(name)
	return type(getgenv and getgenv()[name] or _G[name]) == "function"
end

local function parentTraversalCheck(vector)
	return {
		id = `escapes.parent.{vector.id}`,
		name = vector.name,
		category = "Parent Traversal Escapes",
		run = function()
			local success, root = pcall(vector.getter)
			if not success then
				return result.secured("Getter was rejected")
			end

			if root == nil then
				return result.secured("Getter returned nil")
			end

			local opened = pcall(function()
				return root:OpenScreenshotsFolder()
			end)

			if opened then
				return result.vulnerable("Vector reached the DataModel and executed a blocked method")
			end

			return result.secured("Vector did not execute a blocked DataModel method")
		end,
	}
end

return function()
	local checks = {}

	for _, vector in ipairs(parentVectors) do
		table.insert(checks, parentTraversalCheck(vector))
	end

	return checks
end
